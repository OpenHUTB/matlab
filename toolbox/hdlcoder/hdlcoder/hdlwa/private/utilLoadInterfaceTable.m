function msg=utilLoadInterfaceTable(mdladvObj,hDI,taskID)






    system=mdladvObj.System;


    msg={};

    try

        msg1=hDI.loadInterfaceTable(system);
        msg=[msg,msg1];
    catch ME
        if strcmp(ME.identifier,'hdlcommon:workflow:TestPointNamesNotUnique')




            hereStr=message('hdlcommon:workflow:here').getString;
            actionLink=sprintf('<a href="matlab:uniquifyTestPointNames(%s, true); hdlturnkey.resetHDLWATask(''%s'');">%s</a>',...
            cleanBlockNameForQuotedDisp(system),taskID,hereStr);
            error(message('hdlcommon:workflow:TestPointNamesUniquification',ME.message,actionLink));
        else
            rethrow(ME);
        end
    end


    utilUpdateInterfaceTable(mdladvObj,hDI);

end