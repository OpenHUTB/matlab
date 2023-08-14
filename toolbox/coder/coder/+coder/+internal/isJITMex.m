function[result,bc]=isJITMex(aMexFile)




    [~,~,ext]=fileparts(aMexFile);

    if strcmp(ext(2:end),mexext)~=1
        error('File extension is not a valid mex on current platform.');
    end

    [fid,errmsg]=fopen(aMexFile,'r');

    if~isempty(errmsg)

        error(errmsg);
    end

    if ispc
        data=fread(fid,[1,800],'uint8=>char');
    else
        data=fread(fid,[1,inf],'*uint8');
    end

    fclose(fid);

    if ispc

        result=verifyWindowsMEX(data);
        bc='';
    else
        [result,bc]=verifyUnixMex(data);
    end
end

function result=verifyWindowsMEX(data)



    if~contains(data,'LLVMBC')
        result=false;
    else
        result=true;
    end
end

function[result,bc]=verifyUnixMex(data)
    surrogateMexFunctionPath=coder.internal.getSurrogateMexFunctionPath(Debug=false);
    surrogateMexFunctionDebugPath=coder.internal.getSurrogateMexFunctionPath(Debug=true);
    [result,bc]=verifyUnixMexFromSurrogateMexFunction(data,surrogateMexFunctionPath);
    if~result&&~strcmp(surrogateMexFunctionPath,surrogateMexFunctionDebugPath)

        [result,bc]=verifyUnixMexFromSurrogateMexFunction(data,surrogateMexFunctionDebugPath);
    end
end

function[result,bc]=verifyUnixMexFromSurrogateMexFunction(data,surrogateMexFunctionPath)

    [fid,errmsg]=fopen(surrogateMexFunctionPath);

    if~isempty(errmsg)
        error(errmsg);
    end

    finishup=onCleanup(@()fclose(fid));
    status=fseek(fid,0,'eof');

    if status~=0
        error('fseek error');
    end

    tempfilesize=ftell(fid);

    if length(data)<=tempfilesize
        result=false;
        bc='';
    else

        result=(data(tempfilesize+1)=='B'&&data(tempfilesize+2)=='C');
        bc=data(tempfilesize+1:end);
    end
end
