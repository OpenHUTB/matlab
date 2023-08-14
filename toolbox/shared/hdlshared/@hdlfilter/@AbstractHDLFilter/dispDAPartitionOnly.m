function dispDAPartitionOnly(this,ffmatrix,lutmatrix)









    topheader='\n  Table of ''DARadix'' values with corresponding values of \n  folding factor and multiple for LUT sets for the given filter.\n\n';
    fprintf(topheader);
    headHorz={'Folding Factor','LUT-Sets Multiple','DARadix'};
    headVert={};
    matxtable=fitintable(this,headHorz,headVert,ffmatrix,{'center','center','center'});

    textstr=mydisp(matxtable);
    fprintf(textstr);

    topheader='\n  Details of LUTs with corresponding ''DALUTPartition'' values.\n\n';
    fprintf(topheader);
    headHorz={'Max Address Width','Size(bits)','LUT Details','DALUTPartition'};
    headVert={};
    matxtable=fitintable(this,headHorz,headVert,lutmatrix,{'center','center','left','left'});

    textstr=mydisp(matxtable);
    fprintf(textstr);

    Notes=['\n',...
    'Notes:\n',...
    '1. LUT Details indicates number of LUTs with their sizes. e.g. 1x1024x18\n',...
    '   implies 1 LUT of 1024 18-bit wide locations.\n'];
    fprintf(Notes);




    function textstr=mydisp(textcell)

        textstr=[];
        for n=1:size(textcell,1)
            textstr=[textstr,textcell{n,:},'\n'];
        end


