function opcslerrorhandler(obj,event,errState)











    errID='opc:simulink:error';
    if isa(event,'MException'),

        origMsg=event.message;
        grpName=obj.Name;
    elseif strcmp(event.Type,'Error')

        allStrs={event.Data.Items.ItemID;event.Data.Items.ErrorMessage};
        origMsg=sprintf('\t%s returned: ''%s''\n',allStrs{:});

        origMsg(end)=[];
        grpName=event.Data.GroupName;
    else

        return;
    end
    errMsg=sprintf('Block ''%s'' reported an error:\n%s',grpName,origMsg);
    if errState.readWrite==1,
        errStruct=MException(errID,errMsg);
        throwAsCaller(errStruct);
    elseif errState.readWrite==2,
        throwwarning(errID,errMsg);
    end
end