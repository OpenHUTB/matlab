function dispSummaryofCoefficientsforDA(this)







    [summ,summline]=summaryofCoeffsforDA(this);


    headHorz={'Coefficients','Total','Zeros','Effective'};
    for n=1:this.phases
        headVert{n}=getString(message('HDLShared:hdlfilter:codegenmessage:polyphasenum',...
        n));%#ok<AGROW>

    end
    lentable=fitintable(this,headHorz,headVert,summ,{'center'});

    fprintf(mydisp(lentable));
    fprintf([summline,'\n']);


    function textstr=mydisp(textcell)

        textstr=[];
        for n=1:size(textcell,1)
            textstr=[textstr,textcell{n,:},'\n'];%#ok<AGROW>
        end



