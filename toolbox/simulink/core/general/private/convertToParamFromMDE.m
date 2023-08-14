function convertToParamFromMDE(location,var_name,filename,modelName)








    className=Simulink.data.getDefaultClassname('Parameter');
    obj=feval(className);
    obj.StorageClass='Auto';

    switch(location)
    case 'base'
        obj.Value=evalin('base',var_name);
        assignin('base',var_name,obj);
    case 'dictionary'
        dictionaryObj=Simulink.data.dictionary.open(filename);
        context=getSection(dictionaryObj,'Design Data');
        entry=context.getEntry(var_name);
        obj.Value=entry.getValue;
        setValue(entry,obj);
        close(dictionaryObj);
    case 'model'
        context=get_param(filename,'ModelWorkspace');
        previousFlag=context.valueSourceErrorCheckingInCommandLineAPI;




        if slfeature('MWSValueSource')>1
            vm=get_param(filename,'ValueManager');
            vm.backupParameterGroupMembership(var_name);
            context.valueSourceErrorCheckingInCommandLineAPI=false;
        end
        obj.Value=slprivate('modelWorkspaceGetVariableHelper',context,var_name);
        assignin(context,var_name,obj);
        if slfeature('MWSValueSource')>1
            vm.restoreParameterGroupMembership(var_name);
            context.valueSourceErrorCheckingInCommandLineAPI=previousFlag;
        end
    end

    editor=GLUE2.Util.findAllEditors(modelName);
    studio=editor.getStudio;
    label='ModelData';

    ssComp=studio.getComponent('GLUE2:SpreadSheet',label);
    ssComp.update;
end
