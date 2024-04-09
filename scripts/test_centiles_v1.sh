#!/bin/bash +x

indir='../test/OASIS4/input'
outdir='../test/OASIS4/output'

mkdir -pv $outdir

## Select sample
echo "Selecting sample"
if [ -e ${outdir}/OASIS4_sel_sample.csv ]; then
    echo "Out file exists, skip ..."
else
    python util_select_data.py -i ${indir}/OASIS4_Demog.csv -f${indir}/filter_test.json -o ${outdir}/OASIS4_sel_sample.csv
fi

## Prepare centile input data
echo "Preparing input data for centile calculation"
if [  -e ${outdir}/OASIS4_centiles_input.csv ]; then
    echo "Out file exists, skip ..."    
else
    python util_prep_centile_data.py -i1 ${outdir}/OASIS4_sel_sample.csv -i2 ${indir}/OASIS4_Demog.csv -i3 ${indir}/OASIS4_ROI.csv -k MRID -d Age -o ${outdir}/OASIS4_centiles_input.csv
fi

## Calculate centile values
echo "Calculating centiles"
if [ -e ${outdir}/OASIS4_centiles_output.csv ]; then
    echo "Out file exists, skip"
else
    ./util_calc_centiles.sh -i ${outdir}/OASIS4_centiles_input.csv -o ${outdir}/OASIS4_centiles_output.csv
fi
