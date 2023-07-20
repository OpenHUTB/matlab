function visit_simplenode_implementation(thisVisitor,aSimpleNode)







    hParent=thisVisitor.SLHandle(aSimpleNode.Parent.NodeID);
    if~ishandle(hParent)
        pm_error('sm:sli:librarybuildingvisitor:InvalidParentHandle',aSimpleNode.Info.SLBlockProperties.Name)
    end

    blkInfo=aSimpleNode.Info;


    defInfo=simmechanics.sli.internal.BlockInfo;
    if(strcmp(blkInfo.InitialVersion,defInfo.InitialVersion))
        pm_error('sm:sli:librarybuildingvisitor:BlockInitialVersionNotSet',...
        aSimpleNode.NodeID);
    end


    blkName=blkInfo.SLBlockProperties.Name;
    if isempty(blkName)
        pm_error('sm:sli:librarybuildingvisitor:BlockNameNotSet',aSimpleNode.NodeID);
    end

    fullBlkName=[getfullname(hParent),'/',blkName];
    hBlk=add_block('built-in/SimscapeMultibodyBlock',fullBlkName);


    slProps=properties(blkInfo.SLBlockProperties);
    for idx=1:length(slProps)
        set_param(hBlk,slProps{idx},blkInfo.SLBlockProperties.(slProps{idx}));
    end

    set_param(hBlk,'Name',blkName);
    set_param(hBlk,'DialogController','MultibodyDialog.SlimDialogSource');


    maskParams=blkInfo.MaskParameters;

    maskParams(end+1)=pm.sli.MaskParameter;
    maskParams(end).VarName=pm_message('mech2:messages:parameters:block:blockFunction:ParamName');
    maskParams(end).Value=func2str(pm.util.function_handle(aSimpleNode.NodeID));
    maskParams(end).ReadOnly='on';

    maskObj=[];
    if(strcmpi(get_param(hBlk,'Mask'),'on'))
        maskObj=Simulink.Mask.get(hBlk);
    else
        maskObj=Simulink.Mask.create(hBlk);
    end

    maskObj.Type=blkName;
    for mIdx=1:length(maskParams)
        if strcmpi(maskParams(mIdx).ReadOnly,'on')
            maskObj.addParameter('Type',maskParams(mIdx).Type,...
            'Prompt',maskParams(mIdx).Prompt,...
            'Name',maskParams(mIdx).VarName,...
            'Value',maskParams(mIdx).Value,...
            'Evaluate',maskParams(mIdx).Evaluate,...
            'Tunable',maskParams(mIdx).Tunable,...
            'Visible',maskParams(mIdx).Visible,...
            'Hidden',maskParams(mIdx).Hidden,...
            'ReadOnly',maskParams(mIdx).ReadOnly,...
            'TypeOptions',maskParams(mIdx).PopupChoices);
        else
            maskObj.addParameter('Type',maskParams(mIdx).Type,...
            'Prompt',maskParams(mIdx).Prompt,...
            'Name',maskParams(mIdx).VarName,...
            'Value',maskParams(mIdx).Value,...
            'Evaluate',maskParams(mIdx).Evaluate,...
            'Tunable',maskParams(mIdx).Tunable,...
            'Enabled',maskParams(mIdx).Enable,...
            'Visible',maskParams(mIdx).Visible,...
            'Hidden',maskParams(mIdx).Hidden,...
            'ReadOnly',maskParams(mIdx).ReadOnly,...
            'TypeOptions',maskParams(mIdx).PopupChoices);
        end
    end




    set_param(hBlk,'Mask',get_param(hBlk,'Mask'));


    thisVisitor.SLHandle(aSimpleNode.NodeID)=hBlk;


    currentPath=strrep([get_param(hBlk,'Parent'),'/',blkName],sprintf('\n'),' ');


    n=length(aSimpleNode.Info.ForwardingTableEntries);
    for idx=1:n
        aSimpleNode.Info.ForwardingTableEntries(idx).NewPath=currentPath;
        oldPath=aSimpleNode.Info.ForwardingTableEntries(idx).OldPath;
        if isempty(oldPath)||strcmp(oldPath,currentPath)
            aSimpleNode.Info.ForwardingTableEntries(idx).OldPath=currentPath;
        end

    end
    if n>0
        thisVisitor.ForwardingTableEntries(end+1:end+n)=...
        aSimpleNode.Info.ForwardingTableEntries;
    end
end


