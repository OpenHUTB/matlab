function isUnsupportedData=timeSeriesUnsupportedCheck(aVar)








    isFi_WordLength_GT_128=~isSimulinkFi(aVar.Data);

    SampleDims=getTSDimension(aVar);



    areDimsSupportedBySDI=prod(SampleDims)<=SlIOFormatUtil.SDI_REPO_CHANNEL_UPPER_LIMIT;

    isUnsupportedData=isstruct(aVar.Data)||...
    (isstring(aVar.Data)&&~isSLString(aVar.Data))||ischar(aVar.Data)||...
    (isfi(aVar.Data)&&isFi_WordLength_GT_128)||...
    (isenum(aVar.Data)&&~isStaSLEnumType(aVar.Data))||...
    ~areDimsSupportedBySDI;


end
