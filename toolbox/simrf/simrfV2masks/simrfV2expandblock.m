function simrfV2expandblock(block,dialog)




    if strcmpi(get_param(bdroot(block),'BlockDiagramType'),'library')
        return;
    end


    if(~strcmp(fileparts(get_param(block,'ReferenceBlock')),'simrfV2systems'))
        blkName=regexprep(block,'\n','');
        error(message('simrf:simrfV2errors:NotLinkedToRFSystems',blkName));
    end


    if dialog.hasUnappliedChanges
        blkName=regexprep(block,'\n','');
        error(message('simrf:simrfV2errors:ApplyButton',blkName));
    end



    dialog.setEnabled('EditButton',0)
    [~,blkName]=fileparts(block);
    if(strcmp(get_param(block,'Commented'),'off'))
        answer=questdlg(DAStudio.message('simrf:simrfV2solver:EditSystemQ'),...
        DAStudio.message('simrf:simrfV2solver:EditSystemT',blkName),...
        DAStudio.message('simrf:simrfV2solver:EditSystem'),...
        DAStudio.message('simrf:simrfV2solver:ExpandSystem'),...
        DAStudio.message('simrf:simrfV2solver:Cancel'),...
        DAStudio.message('simrf:simrfV2solver:Cancel'));
    else
        answer=questdlg(DAStudio.message('simrf:simrfV2solver:EditSystemQ'),...
        DAStudio.message('simrf:simrfV2solver:EditSystemT',blkName),...
        DAStudio.message('simrf:simrfV2solver:EditSystem'),...
        DAStudio.message('simrf:simrfV2solver:Cancel'),...
        DAStudio.message('simrf:simrfV2solver:Cancel'));
    end
    dialog.setEnabled('EditButton',1)
    switch answer
    case DAStudio.message('simrf:simrfV2solver:EditSystem')
        try
            dialog.hide;
            EditSystem(block);
        catch ME
            dialog.refresh;
            dialog.apply;
            dialog.show;

            rethrow(ME);
        end
        MaskDisplay=get_param(block,'MaskDisplay');
        dialog.delete;
        set_param(block,'LinkStatus','none')
        set_param(block,'Mask','off')
        set_param(block,'Mask','on')
        set_param(block,'MaskIconRotate','port')
        set_param(block,'MaskIconUnits','normalized')
        set_param(block,'MaskRunInitForIconRedraw','off')
        set_param(block,'MaskDisplay',MaskDisplay)

    case DAStudio.message('simrf:simrfV2solver:ExpandSystem')
        try
            dialog.hide;
            EditSystem(block);
        catch ME
            dialog.refresh;
            dialog.apply;
            dialog.show;

            rethrow(ME);
        end
        dialog.delete;
        set_param(block,'LinkStatus','none')
        set_param(block,'Mask','off')
        Simulink.BlockDiagram.expandSubsystem(block)
    end

end

function EditSystem(block)
    ClassName=get_param(block,'classname');
    ParamName=[ClassName,'Params'];
    MaskObj=get_param(block,'MaskObject');
    MaskParams2Resolve=...
    MaskObj.Parameters(arrayfun(@(x)...
    ((strcmp(x.Evaluate,'on'))&&(strcmp(x.Enabled,'on'))&&...
    (strcmp(x.Visible,'on'))&&(any(strcmp(x.Type,...
    {'min','max','slider','dial','spinbox','edit'})))),...
    MaskObj.Parameters,'UniformOutput',true));
    MaskEvaluatedNames={MaskParams2Resolve.Name};
    MaskEvaluatedVals={MaskParams2Resolve.Value};
    for MaskEvaluatedParamInx=1:length(MaskParams2Resolve)
        try
            ResolvedParam=...
            slResolve(MaskEvaluatedVals{MaskEvaluatedParamInx},block);
        catch ME
            if strcmp(ME.identifier,'Simulink:Data:SlResolveNotResolved')
                error([ME.message(1:end-1),' in parameter '...
                ,MaskEvaluatedNames{MaskEvaluatedParamInx},'.']);
            else
                rethrow(ME);
            end
        end
        if(isnumeric(ResolvedParam))
            ResolvedParam=mat2str(ResolvedParam);
        end
        set_param(block,MaskEvaluatedNames{MaskEvaluatedParamInx},...
        ResolvedParam)
    end
    MaskParams=eval(['simrfV2',ClassName...
    ,'(block, ''simrfInitValidateOnly'')']);%#ok<NASGU>
    eval(['simrfV2_',ClassName,'_params(MaskParams);']);
    set_param(block,'LinkStatus','inactive')
    MaskParams=eval(['simrfV2',ClassName...
    ,'(block, ''simrfInitForcedExp'')']);%#ok<NASGU>
    Params=eval(['simrfV2_',ClassName,'_params(MaskParams)']);
    intBlks=fieldnames(Params);
    for intBlkInd=1:length(intBlks)
        intBlkName=intBlks{intBlkInd};
        intBlkfullNames=find_system(block,'SearchDepth','1',...
        'FollowLinks','on','LookUnderMasks','all',...
        'Name',intBlkName);




        if(~isempty(intBlkfullNames))
            intBlkfullName=intBlkfullNames{1};
            intBlkMaskObj=get_param(intBlkfullName,'MaskObject');
            intBlkParmStruct=Params.(intBlkName);
            intBlksParms=fieldnames(intBlkParmStruct);
            for intBlksParmInd=1:length(intBlksParms)
                intBlksParmName=intBlksParms{intBlksParmInd};
                intBlkParmValue=intBlkParmStruct.(intBlksParmName);
                intBlksParmName=...
                intBlkMaskObj.Parameters(strcmpi(...
                {intBlkMaskObj.Parameters.Value},...
                [ParamName,'.',intBlkName,'.'...
                ,intBlksParmName])).Name;
                if ischar(intBlkParmValue)
                    set_param(intBlkfullName,intBlksParmName,...
                    intBlkParmValue);
                else
                    set_param(intBlkfullName,intBlksParmName,...
                    mat2str(intBlkParmValue));
                end
            end
        end
    end
    open_cir_blks=find_system(block,'SearchDepth','1',...
    'FollowLinks','on','LookUnderMasks','all',...
    'Classname','open_rf');
    for open_cir_blks_ind=1:length(open_cir_blks)
        phtemp=get_param(open_cir_blks{open_cir_blks_ind},'PortHandles');
        simrfV2deletelines(get(phtemp.RConn(1),'Line'));
        simrfV2deletelines(get(phtemp.LConn(1),'Line'));
        delete_block(open_cir_blks{open_cir_blks_ind});
    end
end


