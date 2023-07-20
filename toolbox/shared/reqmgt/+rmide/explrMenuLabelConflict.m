function schemas=explrMenuLabelConflict(cbInfo)




    issueStr=cbInfo.userdata{1};
    causes=cbInfo.userdata{2};
    schemas={{@duplicateVarNameWarning,{issueStr,causes}}};

end

function schema=duplicateVarNameWarning(cbInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmide:SameNameDataObject'));
    schema.tag='Simulink:NoLinksForConflictingVars';
    schema.userdata=cbInfo.userdata;
    schema.callback=@duplicateVarNameWarning_callback;
    schema.autoDisableWhen='Busy';
end

function duplicateVarNameWarning_callback(cbInfo)
    errorMessage=cbInfo.userdata(1);
    causes=cbInfo.userdata{2};
    for i=1:length(causes)
        cause=causes{i}.message;
        errorMessage=[errorMessage;stripHtml(cause)];%#ok<AGROW>
    end
    errordlg(errorMessage,getString(message('Slvnv:rmide:RmiLinkingDisabled')),'model');
end

function str=stripHtml(str)
    str=regexprep(str,'<[^>]+>','');
end