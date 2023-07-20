function html=dispSummaryofCoeffsHTML(this)






    [summ,summline]=summaryofCoeffs(this);

    summline=strrep(summline,'\n','');
    html='<P>The following table is the summary of various filter lengths:</P>';
    headHorz={'Coefficients','Total','Zeros','^2s','A/Symm','Effective'};
    for n=1:this.Decimationfactor
        headVert{n}=getString(message('HDLShared:hdlfilter:codegenmessage:polyphasenum',...
        n));%#ok<AGROW>

    end
    html=[html,fitinhtmltable(this,headHorz,headVert,summ,{'center'})];
    html=[html,'<P>',summline,'</P>'];


