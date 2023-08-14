function resultJSON=macehelp

    try
        helpview(fullfile(docroot,'slcheck','helptargets.map'),'model_advisor_configuration_editor_window');
    catch
    end

    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','');
    resultJSON=jsonencode(result);

end
