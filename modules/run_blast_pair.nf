/*
 *  MODULE: run_blast_pair.nf
 *
 *  Description: 
 *      Uses bash script provided from 
 *      https://github.com/atarashansky/SAMap
 *      on pairs of samples.
 *
 *  Inputs:
 *      run_id:         Timestamp of the nextflow process
 *      val(a):         Map with keys: fasta, type, id2 (Sample A metadata)
 *      val(b):         Map with keys: fasta, type, id2 (Sample B metadata)
 *      data_dir:       Staging the data directory so the script can access it
 *
 *  Outputs:
 *      Two BLAST result text files for each direction and a logfile
 *      results/${run_id}/maps/{pair_id}/[A_to_B.txt, B_to_A.txt]
 */

process RUN_BLAST_PAIR {
    tag "${run_id} - ${a.id2}_vs_${b.id2}"

    publishDir("${outdir}/${run_id}/", mode: 'copy', pattern: "maps/*/*_to_*.txt")
    publishDir("${outdir}/${run_id}/logs", mode: 'copy', pattern: "*.log")

    container 'mdiblbiocore/samap-blast:latest'

    input:
        val run_id
        tuple val(a), val(b)
        path data_dir
        path outdir


    output:
        path "maps/*/*_to_*.txt", emit: maps
        path "${run_id}_${a.id2}${b.id2}_blast.log", emit: logfile

    script:
    """
    LOG="${run_id}_${a.id2}${b.id2}_blast.log"
    map_genes.sh \\
        --threads ${task.cpus} \\
        --tr1 ${a.fasta} --t1 ${a.type} --n1 ${a.id2} \\
        --tr2 ${b.fasta} --t2 ${b.type} --n2 ${b.id2} | \\
        while IFS= read -r line; do
            echo "[\$(date +'%Y-%m-%d %H:%M:%S.%3N')] \$line"
        done 2>&1 | tee -a \$LOG
    """
}
