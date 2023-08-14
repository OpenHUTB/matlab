function mcsFileName=getMCSFileName(obj)


    if obj.isSLRTWorkflow
        if obj.isIPCoreGen
            postfix='';
        else
            postfix=obj.hTurnkey.hBoard.TopLevelNamePostfix;
        end


        mcsFileName=[downstream.tool.createFileNameFromDUTName(obj.getDutName,postfix),'.mcs'];

    else
        mcsFileName='';
    end

end
