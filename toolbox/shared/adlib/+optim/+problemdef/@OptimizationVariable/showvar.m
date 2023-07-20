function showvar(obj)



























































    if isempty(obj)
        fprintf(newline);
        disp("  "+getString(message('shared_adlib:OptimizationVariable:EmptyVariable')));
        fprintf(newline);
        return;
    end


    BUFFERSIZE=10;

    varStr=getDisplayStr(obj);

    nLines=numel(varStr);

    buffSize=min(BUFFERSIZE,nLines);

    fprintf(newline);
    for n=1:ceil(nLines./buffSize)
        idxStart=1+(n-1)*BUFFERSIZE;
        idxEnd=idxStart+min(buffSize-1,nLines-idxStart);
        fprintf(join(varStr(idxStart:idxEnd),""));
    end