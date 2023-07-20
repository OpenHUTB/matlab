function dispSerialPartitionOnly(this,ffmatrix)








    topheader='\n  Table of ''SerialPartition'' values with corresponding values of \n  folding factor and number of multipliers for the given filter.\n\n';
    fprintf(topheader);
    headHorz={'Folding Factor','Multipliers','SerialPartition'};
    headVert={};
    matxtable=fitintable(this,headHorz,headVert,ffmatrix,{'center','center','left'});

    textstr=mydisp(matxtable);
    fprintf(textstr);

    function textstr=mydisp(textcell)

        textstr=[];
        for n=1:size(textcell,1)
            textstr=[textstr,textcell{n,:},'\n'];
        end


