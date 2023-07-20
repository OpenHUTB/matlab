function dispSummaryofCoefficients(this)







    [summ,summline,~,headHorz,headVert]=summaryofCoeffs(this);


    lentable=fitintable(this,headHorz,headVert,summ,{'center'});

    fprintf(mydisp(lentable));
    fprintf([summline,'\n']);


    function textstr=mydisp(textcell)

        textstr=[];
        for n=1:size(textcell,1)
            textstr=[textstr,textcell{n,:},'\n'];
        end



