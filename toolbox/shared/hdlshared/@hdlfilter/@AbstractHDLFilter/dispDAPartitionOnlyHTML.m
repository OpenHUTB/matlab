function html=dispDAPartitionOnlyHTML(this,ffmatrix,lutmatrix)










    topheader='Table of valid ''DARadix'' settings';

    headHorz={'Folding Factor','Number of LUT Sets','DARadix'};
    headVert={};

    html=fitinhtmltable(this,headHorz,headVert,ffmatrix,{'center','center','center'},topheader);


    topheader='Table of valid ''DALUTPartition'' settings';

    headHorz={'Max Address Width','Size (bits)','LUT Set Details','DALUTPartition'};
    headVert={};
    html=[html,fitinhtmltable(this,headHorz,headVert,lutmatrix,{'center','center','left','left'},topheader)];

    Note=['<P>Note: ''LUT Set Details'' indicates the number of LUTs of each '...
    ,'dimension in each set. For example ''1x32x17, 1x64x14'' indicates that '...
    ,'there is 1 LUT of 32 x 17-bits and 1 of 64 x 14-bits in each set.</P>'];
    html=[html,Note];


