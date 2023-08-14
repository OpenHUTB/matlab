function utilRunFix(mdladvObj,check,Pass)





    mode=mdladvObj.UserData.Mode;
    if strcmp(mode,'QuickScan')
        return;
    end


    actionMode=utilCheckActionMode(mdladvObj,check);

    if strfind(actionMode,'Auto')

        taskobj=mdladvObj.getTaskObj(check.getID);
        runAction(taskobj);
    else

        mdladvObj.setActionEnable(~Pass);
    end

end

