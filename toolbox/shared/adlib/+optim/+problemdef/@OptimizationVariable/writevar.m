function writevar(obj,varargin)






































































    narginchk(1,2);


    defaultFilename=obj.Name;


    fid=optim.internal.problemdef.writeInterfaceHandler(defaultFilename,varargin{:});


    BUFFERSIZE=200;


    varStr=getDisplayStr(obj);

    nLines=numel(varStr);

    buffSize=min(BUFFERSIZE,nLines);

    fprintf(fid,newline);
    for n=1:ceil(nLines./buffSize)
        idxStart=1+(n-1)*BUFFERSIZE;
        idxEnd=idxStart+min(buffSize-1,nLines-idxStart);
        fprintf(fid,join(varStr(idxStart:idxEnd),""));
    end


    fclose(fid);

