function[bytesperpass,numpasses,countperpass,extracount]=getDataSizeInfo(cc,opt,datatype,count)

    switch opt
    case 'read'
        totalcount=prod(count);
    case 'write'
        data=datatype;
        totalcount=numel(data);
        datatype=class(data);
    otherwise
        error(message('TICCSEXT:util:getDataSizeInfo_InvalidInput'));
    end

    bytesperpass=2^14;
    bytesperval=getbytes(cc,datatype);
    totalbytes=totalcount*bytesperval;
    numpasses=floor(totalbytes/bytesperpass);
    countperpass=bytesperpass/bytesperval;
    extrabytes=mod(totalbytes,bytesperpass);
    extracount=extrabytes/bytesperval;



    function num=getbytes(cc,datatype)
        proc=ticcsext.Utilities.getProcessorType(cc,'family');
        MATLABDataTypes=struct(...
        'double',8,...
        'single',4,...
        'uint8',1,...
        'uint16',2,...
        'uint32',4,...
        'int8',1,...
        'int16',2,...
        'int32',4...
        );
        NumOfBytesInAU=struct(...
        'C6x',1,...
        'C5x',2,...
        'C2x',2,...
        'R1x',1,...
        'R2x',1...
        );
        try
            num=floor(MATLABDataTypes.(datatype)/NumOfBytesInAU.(proc));
            if(num==0),
                num=1;
            end
        catch
            DAStudio.error('TICCSEXT:util:getDataSizeInfo_InvalidInput');
        end

