function html=dispSummaryofCoeffsHTML(this)








    [summ,summline,~,headHorz,headVert]=summaryofCoeffs(this);

    summline=strrep(summline,'\n','');
    html='<P>The following table is the summary of various filter lengths:</P>';

    html=[html,fitinhtmltable(this,headHorz,headVert,summ,{'center'})];
    html=[html,'<P>',summline,'</P>'];


