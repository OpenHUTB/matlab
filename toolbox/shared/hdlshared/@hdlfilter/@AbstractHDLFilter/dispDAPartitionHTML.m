function html=dispDAPartitionHTML(this,ffmatrix,lutmatrix)





    html='<P>Architecture info for this filter:</P>';

    html=[html,dispSummaryofCoeffsforDAHTML(this)];

    html=[html,dispDAPartitionOnlyHTML(this,ffmatrix,lutmatrix)];


