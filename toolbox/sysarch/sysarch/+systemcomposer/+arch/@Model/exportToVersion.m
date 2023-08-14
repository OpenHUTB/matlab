function exported_filename=exportToVersion(modelObj,target_filename,...
    version)















    exported_filename='';
    exprToEval="exported_filename = "+"Simulink.exportToVersion('"+...
    string(modelObj.Name)+"','"+string(target_filename)+"','"+...
    string(version)+"');";

    try
        evalc(exprToEval);
    catch ME
        throwAsCaller(ME);
    end

    fprintf("Export successful: '%s' created for use in System Composer %s.\n",...
    exported_filename,version);

end
