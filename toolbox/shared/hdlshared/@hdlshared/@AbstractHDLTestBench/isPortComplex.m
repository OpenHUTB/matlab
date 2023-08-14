function status=isPortComplex(~,port)



    if isfield(port,'dataIsComplex')
        status=port.dataIsComplex;
    else
        status=0;
    end
end
