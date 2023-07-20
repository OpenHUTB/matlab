


function retVal=evalTLCWithParam(aTLCFileName,aTLCFuncName,aSrcRecord)
    try
        handle=tlc('new');
        tlc('set',handle,'aSrcRecord',aSrcRecord);
        tlc('execcmdline',handle,aTLCFileName);
        getcmd=['FEVAL("tlc","get",',num2str(handle),',"aSrcRecord")'];
        tlc('execstring',handle,['%assign srcRecord = ',getcmd]);
        retVal=tlc('query',handle,[aTLCFuncName,'(srcRecord)']);
    catch err
        tlc('close',handle);
        throw(err);
    end
    tlc('close',handle);
end