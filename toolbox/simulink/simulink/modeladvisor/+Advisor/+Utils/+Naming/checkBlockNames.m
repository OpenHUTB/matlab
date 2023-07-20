






function[subStatus,subResult,violations]=checkBlockNames(system,regexpBlockNames,prefix,reservedNames,conventionBlockNames)
    violations=[];

    subStatus=true;


    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubBar(false);
    ft.setColTitles({...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Block'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Name'),...
    Advisor.Utils.Naming.getDASText(prefix,'_ColumnHeader_Reason')});



    blocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'Type','block');


    blocks=filterBlocks(blocks);


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    blocks=mdladvObj.filterResultWithExclusion(blocks);


    for index=1:numel(blocks)
        thisBlock=blocks{index};
        if checkBlock(thisBlock)
            blockName=get_param(thisBlock,'Name');
            [isValid,issue,reason]=Advisor.Utils.Naming.isNameValid(blockName,regexpBlockNames,...
            reservedNames,prefix,conventionBlockNames);
            if~isValid
                subStatus=false;
                ft.addRow({thisBlock,issue,reason});
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',thisBlock);
                vObj.RecAction=issue;
                violations=[violations;vObj];%#ok<AGROW>
            end
        end
    end

    subResult=ft;
end

function newBlockList=filterBlocks(oldBlockList)
    keep=true(size(oldBlockList));

    for index=1:numel(oldBlockList)
        thisBlock=oldBlockList{index};
        maskType=get_param(thisBlock,'MaskType');
        switch maskType
        case 'System Requirements'
            keep(index)=false;
        case 'System Requirement Item'
            keep(index)=false;
        otherwise

        end
    end

    newBlockList=oldBlockList(keep);
end

function result=checkBlock(thisBlock)
    result=true;


    blockType=get_param(thisBlock,'BlockType');
    if strcmp(blockType,'SubSystem')
        maskType=get_param(thisBlock,'MaskType');
        switch maskType
        case 'CMBlock',result=false;return;
        case 'DocBlock',result=false;return;
        end
    end


    blockParent=get_param(thisBlock,'Parent');
    isSFChild=slprivate('is_stateflow_based_block',blockParent);
    if isSFChild
        result=false;
        return;
    end


    blockParent=get_param(thisBlock,'Parent');
    type=get_param(blockParent,'Type');
    if strcmp(type,'block')
        linkStatus=get_param(blockParent,'LinkStatus');
        if strcmp(linkStatus,'resolved')||strcmp(linkStatus,'implicit')
            referenceBlock=get_param(blockParent,'ReferenceBlock');
            libraryName=strtok(referenceBlock,'/');

            switch libraryName
            case 'simulink'
                result=false;
                return;
            otherwise
                libraryPath=which(libraryName);
                toolboxRoot=[matlabroot,filesep,'toolbox'];
                if strncmp(libraryPath,toolboxRoot,numel(toolboxRoot))
                    result=false;
                    return;
                end
            end

        end
    end

end

