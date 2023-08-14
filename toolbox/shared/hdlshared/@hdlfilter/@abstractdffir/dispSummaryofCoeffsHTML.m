function html=dispSummaryofCoeffsHTML(this)







    [summ,summline,~,headHorz,headVert]=summaryofCoeffs(this);

    summline=strrep(summline,'\n','');
    html=fitinhtmltable(this,headHorz,headVert,summ,{'center'},'Summary of filter length(s)');
    html=[html,'<P>',summline,'</P>'];


