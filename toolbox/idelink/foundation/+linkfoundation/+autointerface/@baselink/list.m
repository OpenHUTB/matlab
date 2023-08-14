function resp=list(h,ltype,~)



















    narginchk(2,3);

    ltype=convertStringsToChars(ltype);

    linkfoundation.util.errorIfArray(h);

    if~ischar(ltype),
        error(message('ERRORHANDLER:autointerface:List_InvalidTypeParam'));
    end

    resp=[];

