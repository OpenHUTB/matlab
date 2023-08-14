function html=dispSerialPartitionOnlyHTML(this,ffmatrix)






    topheader='Table of folding factors with corresponding number of multipliers for the given filter:';

    headHorz={'Folding Factor','Multipliers'};
    headVert={};

    ffmatrix(:,3)=[];
    html=['<P>',topheader,'</P>'];
    html=[html,fitinhtmltable(this,headHorz,headVert,ffmatrix,{'center','center'})];


