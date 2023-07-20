function[status,errmsg]=PreApplyCallback(this,dlg)

    blk=this.getBlock;
    blkH=blk.getFullName;
    source=dlg.getDialogSource;



    paramOwner=source.SelectedParamOwner;
    paramName=source.SelectedParamName;
    if(~isempty(paramOwner)&&~isempty(paramName))
        set_param(blkH,'ParameterOwnerBlock',paramOwner);
        set_param(blkH,'ParameterName',paramName);
        source.TreeSelectedItem=[paramOwner,'/',paramName];
        modelObj=get_param(bdroot(blkH),'Object');
        source.TreeExpandItems=source.getExpandTreeItems(paramOwner,modelObj.Name,0);
        source.WorkspaceVariableName='';
    end



    if(strcmp(get_param(blkH,'AccessWorkspaceVariable'),'on'))
        source.TreeSelectedItem='';
        dlg.setWidgetValue('tree_SystemHierarchy','');
    end


    if slfeature('ParameterWriteToGeneralBlocks')>=2
        paramOwner=get_param(blkH,'ParameterOwnerBlock');
        paramName=get_param(blkH,'ParameterName');
        paramNotSet=~isempty(paramOwner)&&isempty(paramName);
        if paramNotSet
            errmsg=DAStudio.message('Simulink:blocks:ParamWriterParameterNameNotSet',paramOwner);
            status=false;
            return;
        end
    end

    [status,errmsg]=this.preApplyCallback(dlg);
end
