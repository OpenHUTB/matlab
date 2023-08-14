function html=dispSerialPartitionOnlyHTML(this,ffmatrix)






    topheader='Table of valid ''SerialPartition'' settings';

    headHorz={'Folding Factor','Multipliers','SerialPartition'};
    headVert={};
    html=fitinhtmltable(this,headHorz,headVert,ffmatrix,{'center','center','left'},topheader);


