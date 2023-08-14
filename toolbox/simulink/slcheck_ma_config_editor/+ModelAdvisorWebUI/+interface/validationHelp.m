function resultJSON=validationHelp
    helpview(fullfile(docroot,'slcheck','helptargets.map'),'view_validation_summary_results');
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','');
    resultJSON=jsonencode(result);
end