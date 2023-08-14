function name=getDefaultName(harnessOwnerPath,harnessOwnerModel,hCreateCustomizerObj)
    if ismember("Name",hCreateCustomizerObj.userDefinedProps)&&...
        strip(string(hCreateCustomizerObj.Name))~=""
        componentName=get_param(harnessOwnerPath,'Name');

        componentName=regexprep(componentName,'[\n\r\t\v]+','');
        componentName=strrep(componentName,' ','');



        ownerPathRepStr=regexprep(harnessOwnerPath,'[\n\r\t\v]+','');
        ownerPathRepStr=strrep(ownerPathRepStr,' ','');
        ownerPathRepStr=strrep(ownerPathRepStr,'/','_');





        name=regexprep(hCreateCustomizerObj.Name,"\$component\$",componentName,'ignorecase');
        name=regexprep(name,"\$modelName\$",harnessOwnerModel,'ignorecase');
        name=regexprep(name,"\$ownerPath\$",ownerPathRepStr,'ignorecase');


        name=Simulink.harness.internal.getUniqueName(harnessOwnerModel,name);
    else
        name=Simulink.harness.internal.getDefaultName(...
        harnessOwnerModel,harnessOwnerPath,[]);
    end

end