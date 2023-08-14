function html=dispSerialPartitionHTML(this,ffmatrix)






    html='<P>Architecture info for this filter:</P>';

    html=[html,dispSummaryofCoeffsHTML(this)];

    html=[html,dispSerialPartitionOnlyHTML(this,ffmatrix)];


