function dispSerialPartitionOnly(this,ffmatrix)







    topheader=getString(message('HDLShared:hdlfilter:codegenmessage:serialparitiontopheader'));
    fprintf('\n  %s\n\n',topheader);
    headHorz={getString(message('HDLShared:hdlfilter:codegenmessage:foldingfactor')),...
    getString(message('HDLShared:hdlfilter:codegenmessage:multipliers'))};

    headVert={};

    ffmatrix(:,3)=[];
    matxtable=fitintable(this,headHorz,headVert,ffmatrix,{'center','center'});



    textstr=mydisp(matxtable);
    fprintf(textstr);

    function textstr=mydisp(textcell)

        textstr=[];
        for n=1:size(textcell,1)
            textstr=[textstr,textcell{n,:},'\n'];
        end
