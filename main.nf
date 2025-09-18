#!/usr/bin/env nextflow
nextflow.enable.dsl=2


params.blast_db = "" // Path to the BLAST database
params.blast_num_seq = 500 // Number of sequences to retrieve from BLAST results
params.blast_db_type = "prot" // Type of the BLAST database (e.g., nucl, prot)
params.cd_hit = false // Whether to run CD-HIT clustering or not
params.cd_hit_ident = 0.9 // Identity threshold for CD-HIT clustering (e.g., 0.9 for 90% identity)
params.combine = false // Whether to combine original and clustered sequences
params.phylogeny = false // Whether to run the phylogeny step or not

/*
 * Run BLASTp searches for all input FASTA in 'query_inputs' against a specified database.
 * Output files are named <original>.blast and copied to 'results/blast'.
 */


process BLASTP {
    publishDir 'results/blast', mode: 'copy'

    input:
        file query_file
        val db_path
        val db_type
        val num_seq

    output:
        file "${query_file.simpleName}.blast"
        file "${query_file.simpleName}.faa"

    script:
    """
    blastp -query ${query_file} -db ${db_path} -out ${query_file.simpleName}.blast -evalue 0.001 -max_target_seqs ${num_seq} -num_threads 20 -outfmt '6 qaccver saccver pident evalue length qlen slen staxid'
    awk -F '\\t' '{print \$2}' ${query_file.simpleName}.blast | awk '!seen[\$1]++' | \\
      blastdbcmd -db ${db_path} -dbtype ${db_type} -entry_batch - -outfmt '%a %s' -target_only | \\
      perl -pe 's/(\w+.[0-9])\s(.*)/>$1\n$2/g' > ${query_file.simpleName}.faa
    """
}

/*
* Cluster sequences using CD-HIT to reduce redundancy.
* Output files are named <original>_ident.faa and copied to 'results/cdhit'.
*/

process CDHIT {
    publishDir 'results/cdhit', mode: 'copy'

    input:
        file faa_file
        val identity

    output:
        file "${faa_file.simpleName}_${identity}.faa"

    script:
    """
    cd-hit -i ${faa_file} -o ${faa_file.simpleName}_${identity}.faa -c ${identity}
    """
}

/*
 * Combine original FASTA and CD-HIT clustered FASTA into a single file if needed.
 * Output files are named <original>_combined.faa and copied to 'results/cdhit'.
 */

process COMBINE_CDHIT_INPUT {
    publishDir 'results/cdhit', mode: 'copy'

    input:
        file input_faa
        file cd_hit_faa
    
    output:
        file "${input_faa.simpleName}_combined.faa"

    script:
    """
    cat ${input_faa} ${cd_hit_faa} > ${input_faa.simpleName}_combined.faa
    """
}

/*
 * Align all FASTA files in 'fasta_inputs' using MAFFT.
 * Output files are named <original>.mafft and copied to 'results/mafft'.
 */

process ALIGNMENT {
    publishDir 'results/mafft', mode: 'copy'

    input:
        file fasta_file

    output:
        file "${fasta_file.simpleName}.mafft"

    script:
    """
    mafft ${fasta_file} > ${fasta_file.simpleName}.mafft
    """
}

/*
 * Trimming all MAFFT output files using trimAl.
 * Output files are named <original>.trimal and copied to 'results/trimal'.
 */

process TRIMMING {
    publishDir 'results/trimal', mode: 'copy'

    input:
        file mafft_file

    output:
        file "${mafft_file.simpleName}.trimal"

    script:
    """
    trimal -in ${mafft_file} -out ${mafft_file.simpleName}.trimal -gt 0.5
    """
}

process PHYLO_TREE {
    publishDir 'results/iqtree', mode: 'copy'

    input:
        file trimal_file

    output:
        file "${trimal_file}.treefile"

    script:
    """
    iqtree2 -s ${trimal_file} -m MFP -bb 1000 --alrt 1000 -T AUTO
    """

} 

// Define the main workflow
workflow {
    // Create a channel with all files in 'fasta_inputs'
    input_ch = Channel.fromPath('inputs/*')

    // Run BLAST for each file
    blast_results = BLASTP(input_ch, params.blast_db, params.blast_db_type, params.blast_num_seq)
    faa_ch = blast_results.map { it[1] }

    // Optionally run CD-HIT, otherwise use BLASTP output directly
    filtered_faa_ch = params.cd_hit ? CDHIT(faa_ch, params.cd_hit_ident) : faa_ch

    // Optionally combine original and CD-HIT output
    if (params.cd_hit && params.combine) {
        // Zip original and cd-hit output for combining
        to_align_ch = COMBINE_CDHIT_INPUT(faa_ch, filtered_faa_ch)
    } else {
        to_align_ch = filtered_faa_ch
    }

    // Optionally run phylogeny steps
    if (params.phylogeny) {
        aligned = ALIGNMENT(to_align_ch)
        trimmed = TRIMMING(aligned)
        PHYLO_TREE(trimmed)
    }
}