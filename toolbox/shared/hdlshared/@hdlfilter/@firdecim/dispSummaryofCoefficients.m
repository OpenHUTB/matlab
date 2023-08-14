function dispSummaryofCoefficients(this)







    [summ,summline]=summaryofCoeffs(this);


    headHorz={'Coefficients','Total','Zeros','^2s','A/Symm','Effective'};
    for n=1:this.Decimationfactor
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



