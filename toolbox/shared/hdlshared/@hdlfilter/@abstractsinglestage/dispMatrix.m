function dispMatrix(this,damtrix,headHorz,headVert,justifies)





    matxtable=fitintable(this,headHorz,headVert,damtrix,justifies);
    textstr=mydisp(matxtable);
    fprintf(textstr);


    function textstr=mydisp(textcell)

        textstr=[];
        for n=1:size(textcell,1)
            textstr=[textstr,textcell{n,:},'\n'];
        end

