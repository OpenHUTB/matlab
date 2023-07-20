function dlgStruct=ParamAccessor_ddg(source,h)



    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,2];





    isAccessingWSVar=slfeature('ParameterWriteToModelWorkspaceVariable')>0&&strcmp(h.AccessWorkspaceVariable,'on');

    paramGrp_1.Items={};
    rowIdx=1;
    maxCol=2;

    if slfeature('ParameterWriteToModelWorkspaceVariable')>0
        accessWorkspaceVariable=create_widget(source,h,'AccessWorkspaceVariable',1,2,2);
        accessWorkspaceVariable.ObjectProperty='';
        accessWorkspaceVariable.RowSpan=[rowIdx,rowIdx];
        accessWorkspaceVariable.ColSpan=[1,maxCol];
        accessWorkspaceVariable.Visible=true;
        accessWorkspaceVariable.Enabled=true;
        accessWorkspaceVariable.DialogRefresh=true;
        paramGrp_1.Items{length(paramGrp_1.Items)+1}=accessWorkspaceVariable;
        rowIdx=rowIdx+1;

        workspaceVariableName=create_widget(source,h,'WorkspaceVariableName',1,2,2);
        workspaceVariableName.ObjectProperty='WorkspaceVariableName';
        workspaceVariableName.RowSpan=[rowIdx,rowIdx];
        workspaceVariableName.ColSpan=[1,maxCol];
        workspaceVariableName.Visible=isAccessingWSVar;
        workspaceVariableName.Enabled=isAccessingWSVar;
        workspaceVariableName.DialogRefresh=true;
        workspaceVariableName.MatlabMethod='slDialogUtil';
        workspaceVariableName.MatlabArgs={source,'sync','%dialog','edit','%tag'};
        workspaceVariableName.AutoCompleteType='Custom';
        workspaceVariableName.AutoCompleteViewColumn={'Variable name','Class'};
        workspaceVariableName.AutoCompleteMatchOption='contains';
        workspaceVariableName.AutoCompleteViewData=getAutoCompleteData(h);
        paramGrp_1.Items{length(paramGrp_1.Items)+1}=workspaceVariableName;
        rowIdx=rowIdx+1;
    end


    paramOwnerBlkLbl.Name=DAStudio.message('Simulink:blkprm_prompts:ParameterOwnerBlock');
    paramOwnerBlkLbl.Type='text';
    paramOwnerBlkLbl.RowSpan=[rowIdx,rowIdx];
    paramOwnerBlkLbl.ColSpan=[1,1];
    paramOwnerBlkLbl.Visible=~isAccessingWSVar;
    paramGrp_1.Items{length(paramGrp_1.Items)+1}=paramOwnerBlkLbl;

    paramOwnerBlkLink.Name=h.ParameterOwnerBlock;
    if(strcmp(paramOwnerBlkLink.Name,'')==0)
        paramOwnerBlkLink.Type='hyperlink';
        paramOwnerBlkLink.MatlabMethod='ParamAccessor_ddg_cb';
        paramOwnerBlkLink.MatlabArgs={source,'hilite',h.handle,paramOwnerBlkLink.Name};
        paramOwnerBlkLink.Visible=~isAccessingWSVar;
    else
        paramOwnerBlkLink.Name='';
        paramOwnerBlkLink.Type='hyperlink';
        paramOwnerBlkLink.Visible=false;
    end
    paramOwnerBlkLink.RowSpan=[rowIdx,rowIdx];
    paramOwnerBlkLink.ColSpan=[maxCol,maxCol];
    paramGrp_1.Items{length(paramGrp_1.Items)+1}=paramOwnerBlkLink;
    rowIdx=rowIdx+1;




    modelObj=get_param(bdroot(h.Handle),'Object');
    accBlkObj=get_param(h.Handle,'Object');
    objPool=getParamOwnerBlkObjs(accBlkObj,modelObj);

    hierTree.Type='tree';
    hierTree.Name=DAStudio.message('Simulink:dialog:ParameterOwnerTree');
    hierTree.Tag='tree_SystemHierarchy';
    hierTree.RowSpan=[rowIdx,rowIdx];
    hierTree.ColSpan=[1,maxCol];
    hierTree.ObjectProperty='TreeSelectedItem';
    source.treeID=0;
    hierTree.TreeModel={getTree(source,h.Handle,objPool,modelObj)};
    hierTree.ExpandTree=false;
    hierTree.MatlabMethod='ParamAccessor_ddg_cb';
    hierTree.MatlabArgs={source,'selectionTree',h.Handle,'%value','%dialog'};

    refreshTree(source,h);

    hierTree.TreeExpandItems=source.TreeExpandItems;
    hierTree.Visible=~isAccessingWSVar;
    hierTree.Enabled=~isAccessingWSVar;
    hierTree.DialogRefresh=true;
    paramGrp_1.Items{length(paramGrp_1.Items)+1}=hierTree;
    rowIdx=rowIdx+1;


    busTree.Type='tree';
    busTree.Visible=(slfeature('ParameterWriteToPartialModelArgument')>0)&&...
    ~isempty(h.ParameterName)&&strcmp(h.AccessBusElement,'on');
    if busTree.Visible
        treeItems=getBusTreeItems(source,h.Handle);
        busTree.Name=DAStudio.message('Simulink:blkprm_prompts:SignalsInTheBus');
        busTree.Type='tree';
        busTree.Graphical=true;
        busTree.TreeItems=treeItems;
        busTree.TreeMultiSelect=0;
        busTree.ObjectProperty='BusTreeSelectedElement';
        busTree.TreeExpandItems=source.BusTreeExpandElements;
        busTree.RowSpan=[rowIdx,rowIdx];
        busTree.ColSpan=[1,maxCol];
        busTree.MinimumSize=[250,250];
        busTree.Tag='busTree';
        busTree.MatlabMethod='ParamAccessor_ddg_cb';
        busTree.MatlabArgs={source,'selectionBusElement',h.Handle,'%value','%dialog'};
    end
    paramGrp_1.Items{length(paramGrp_1.Items)+1}=busTree;

    paramGrp_1.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp_1.Type='group';
    paramGrp_1.LayoutGrid=[rowIdx,1];
    paramGrp_1.ColStretch=[1];
    paramGrp_1.RowStretch=[zeros(1,(rowIdx-2)),0.5,0.5];
    paramGrp_1.RowSpan=[rowIdx,rowIdx];
    paramGrp_1.ColSpan=[1,maxCol];
    paramGrp_1.Source=source;







    dlgStruct.DialogTitle=DAStudio.message('Simulink:blkprm_prompts:BlockParameterDlg',...
    strrep(h.Name,sprintf('\n'),' '));
    if(strcmp(h.BlockType,'ParameterWriter'))
        dlgStruct.DialogTag=['ParameterWriter',num2str(h.handle)];
    else
        assert(strcmp(h.BlockType,'ParameterReader'))
        dlgStruct.DialogTag=['ParameterReader',num2str(h.handle)];
    end

    dlgStruct.Items={descGrp,paramGrp_1};
    dlgStruct.LayoutGrid=[rowIdx+1,maxCol];
    dlgStruct.RowStretch=[zeros(1,rowIdx-1),1,0];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};


    dlgStruct.PreApplyMethod='PreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    dlgStruct.OpenCallback=@initDialog;
    function initDialog(dlg)
        source=dlg.getDialogSource;
        refreshTree(source,h);
        if(~isempty(source.TreeModel{1}.Children))
            dlg.setWidgetValue('tree_SystemHierarchy',source.TreeSelectedItem);
        else
            source.TreeSelectedItem='';
            source.TreeExpandItems={};
            source.SelectedParamOwner='';
            source.BusTreeSelectedElement='';
            source.BusTreeExpandElements={};
        end

        if(strcmp(h.AccessWorkspaceVariable,'on'))
            dlg.setWidgetValue('AccessWorkspaceVariable',true);
            dlg.setWidgetValue('WorkspaceVariableName',h.WorkspaceVariableName);
            source.WorkspaceVariableName=h.WorkspaceVariableName;
        else
            dlg.setWidgetValue('AccessWorkspaceVariable',false);
            source.WorkspaceVariableName='';
        end
        if slfeature('ParameterWriteToGeneralBlocks')>=2&&...
            checkOwnerNoSelectParam(h.handle)


            dlg.enableApplyButton(true);
        else
            dlg.enableApplyButton(false);
        end
    end

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked||source.isHierarchySimulating
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end



function treeNode=getTree(source,paramAccessorBlkH,objPool,obj)
    modelObj=get_param(bdroot(paramAccessorBlkH),'Object');
    source.treeID=source.treeID+1;
    treeNode=Simulink.ParamOwnerTreeModel(source.treeID,obj);
    childrenNames={};
    childrenNodes={};
    children=obj.getChildren;
    chIdx=1;
    findsysFunc=@(mdl)find_system(mdl,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants);
    if~isempty(objPool)
        while chIdx<=length(children)
            childObj=children(chIdx);
            if ismember(childObj,objPool)
                if~isempty(find(strcmp(childObj.getFullName,findsysFunc(modelObj.Name)),1))
                    childrenNames{end+1}=childObj.Name;%#ok
                    childrenNodes{end+1}=getTree(source,paramAccessorBlkH,objPool,childObj);%#ok
                else
                    grandChildren=childObj.getChildren;
                    for cg=1:length(grandChildren)
                        children(end+1)=grandChildren(cg);%#ok
                    end
                end
            elseif(isa(childObj,'DAStudio.WorkspaceNode')||isa(childObj,'DAStudio.WSOAdapter'))
                childrenNames{end+1}=childObj.getFullName;%#ok
                childrenNodes{end+1}=getTree(source,paramAccessorBlkH,objPool,childObj);%#ok         
            end
            chIdx=chIdx+1;
        end
        varNames={};
        if isempty(childrenNames)
            isChildrenNameExist=false;
            if isa(obj,'Simulink.ModelReference')&&strcmp(get_param(obj.getFullName,'Mask'),'off')
                modelparams=get_param(obj.getFullName,'ParameterArgumentInfo');

                varNames=cell(1,length(modelparams));
                for paramIdx=1:length(modelparams)
                    param=modelparams(paramIdx);
                    DisplayName=modelparams(paramIdx).DisplayName;
                    if(~isempty(param.FullPath))
                        for idx=param.FullPath.getLength:-1:1
                            modelPath=param.FullPath.getBlock(idx);
                            [~,modelBlockName]=fileparts(modelPath);
                            DisplayName=[modelBlockName,'.',DisplayName];
                        end
                    end
                    varNames{paramIdx}.DisplayName=DisplayName;
                    varNames{paramIdx}.ArgName=modelparams(paramIdx).ArgName;
                    varNames{paramIdx}.FullBlockPath=modelparams(paramIdx).FullPath;
                end
                isChildrenNameExist=true;
            elseif(slfeature('ParameterWriteToGeneralBlocks')>0)
                if~isa(obj,'struct')&&ismember(obj,objPool)
                    params=get_param(obj.getFullName,'RuntimeParametersDuringEditTime');
                    for paramIdx=1:length(params)
                        varNames{paramIdx}.DisplayName=params{paramIdx};
                        varNames{paramIdx}.ArgName=params{paramIdx};
                        varNames{paramIdx}.FullBlockPath='';
                    end
                    isChildrenNameExist=~isempty(params);
                end
            end
            if isChildrenNameExist
                chIdx=1;
                while(chIdx<=length(varNames))
                    childObjSub.Name=varNames{chIdx}.DisplayName;
                    childObjSub.ArgName=varNames{chIdx}.ArgName;
                    childObjSub.FullBlockPath=varNames{chIdx}.FullBlockPath;
                    childObjSub.getChildren={};
                    childrenNames{end+1}=childObjSub.Name;%#ok
                    childrenNodes{end+1}=getTree(source,paramAccessorBlkH,objPool,childObjSub);%#ok
                    chIdx=chIdx+1;
                end
            end
        end
        [~,sortIndices]=sort(childrenNames);
        treeNode.Children=childrenNodes(sortIndices);
    else
        treeNode=Simulink.ParamOwnerTreeModel(1,slroot);
    end
    source.TreeModel={treeNode};
end

function treeItems=convertSystemHierarchyToTreeFindSys(rootSystemName)
    childSubsystem=find_system(rootSystemName,'SearchDepth',1,...
    'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants,'BlockType','SubSystem');
    paramOwnerBlocks=find_system(rootSystemName,'SearchDepth',1,...
    'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants,'IsParamOwnerBlock','on');

    if~strcmp(bdroot(rootSystemName),rootSystemName)
        childSubsystem=childSubsystem(2:end);
    end
    subtree={};
    paramOwnerBlockNames={};
    for pIdx=1:length(paramOwnerBlocks)
        paramOwnerBlockNames(pIdx)=get_param(paramOwnerBlocks(pIdx),'Name');%#ok
    end
    if~isempty(childSubsystem)
        for i=1:length(childSubsystem)
            subtree=[subtree,paramOwnerBlockNames...
            ,convertSystemHierarchyToTreeFindSys(childSubsystem{i})];%#ok
        end
    else
        subtree=[subtree,paramOwnerBlockNames];
    end
    if isempty(paramOwnerBlocks)
        if(isempty(subtree))
            treeItems={replaceCarriageReturnWithSpace(get_param(rootSystemName,'Name'))};
        else
            treeItems={replaceCarriageReturnWithSpace(get_param(rootSystemName,'Name')),subtree};
        end
    else
        treeItems={replaceCarriageReturnWithSpace(get_param(rootSystemName,'Name')),...
        subtree};
    end
end

function treeItems=getBusTreeItems(source,blkH)
    ownerBlock=get_param(blkH,'ParameterOwnerBlock');
    structInfo=source.isParamBusOrStructType(ownerBlock,source.BusTreeSelectedElement);
    treeItems=structInfo.treeItems;
end

function output=replaceCarriageReturnWithSpace(input)
    output=strrep(input,sprintf('\n'),' ');
end

function expandItems=get_expand_tree_items(startPoint)
    if ischar(startPoint)&&strcmp(startPoint,'Simulink Root')


        parentSystem=[];
    else
        parentSystem=get_param(startPoint,'Parent');
    end
    expandItems={startPoint};
    if~isempty(parentSystem)
        expandItems{end+1}=parentSystem;
        upperLevels=get_expand_tree_items(parentSystem);
        expandItems=[expandItems,upperLevels];
    end
end


function rootSS=findEffectiveRootSS(accBlkObj,modelObj)
    rootSS=modelObj;
    accParentObj=accBlkObj.getParent;
    while(accParentObj~=modelObj)
        if strcmp(get_param(accParentObj.handle,'Mask'),'on')
            rootSS=accParentObj;
            break;
        end
        accParentObj=accParentObj.getParent;
    end
end


function newPool=removeBlocksInSubsysFromPool(subsys,pool)
    ownerInSS=find_system(subsys,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants,'IsParamOwnerBlock','on');


    if(slfeature('ParameterWriteToGeneralBlocks')>1&&...
        strcmp(get_param(subsys,'mask'),'on'))
        params=get_param(subsys,'RuntimeParametersDuringEditTime');
        if~isempty(params)
            ownerInSS=setdiff(ownerInSS,subsys);
        end
    end

    newPool=setdiff(pool,ownerInSS);
end

function objPool=getParamOwnerBlkObjs(accBlkObj,modelObj)
    rootSS=findEffectiveRootSS(accBlkObj,modelObj);
    paramOwnerBlkH=find_system(rootSS.handle,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants,'IsParamOwnerBlock','on');
    maskSS=find_system(rootSS.handle,'LookUnderMasks','all',...
    'FollowLinks','on','MatchFilter',@Simulink.match.allVariants,'Mask','on');
    eventSS=find_system(rootSS.handle,'LookUnderMasks','all',...
    'FollowLinks','on','MatchFilter',@Simulink.match.allVariants,'SystemType','EventFunction');


    for i=1:length(maskSS)
        if maskSS(i)==rootSS.handle
            continue;
        end
        paramOwnerBlkH=removeBlocksInSubsysFromPool(maskSS(i),paramOwnerBlkH);
    end


    for i=1:length(eventSS)
        paramOwnerBlkH=removeBlocksInSubsysFromPool(eventSS(i),paramOwnerBlkH);
    end


    blksToRemove=[];
    for idx=1:length(paramOwnerBlkH)
        if strcmp(get_param(paramOwnerBlkH(idx),'BlockType'),'ModelReference')
            argInfo=get_param(paramOwnerBlkH(idx),'ParameterArgumentInfo');
            if isempty(argInfo)
                blksToRemove(end+1)=paramOwnerBlkH(idx);
            end
        else
            params=get_param(paramOwnerBlkH(idx),'RuntimeParametersDuringEditTime');
            if isempty(params)
                blksToRemove(end+1)=paramOwnerBlkH(idx);
            end
        end
    end
    paramOwnerBlkH=setdiff(paramOwnerBlkH,blksToRemove);

    paramOwnerBlkObjs=[];
    for idx=1:length(paramOwnerBlkH)
        paramOwnerBlkObjs=[paramOwnerBlkObjs;get_param(paramOwnerBlkH(idx),'Object')];
    end
    if~isempty(paramOwnerBlkObjs)
        objPool=[modelObj;paramOwnerBlkObjs];


        for blkIdx=1:length(paramOwnerBlkObjs)
            blkObj=paramOwnerBlkObjs(blkIdx);
            parentObj=blkObj.getParent;
            while(parentObj~=modelObj)
                if~ismember(parentObj,objPool)
                    objPool(end+1)=parentObj;%#ok
                else
                    break;
                end
                parentObj=parentObj.getParent;
            end
        end
    else
        objPool=[];
    end
end

function autoCompleteData=getAutoCompleteData(h)
    autoCompleteData={};
    modelObj=get_param(bdroot(h.Handle),'Object');
    modelWks=modelObj.getWorkspace();


    if~isempty(modelWks)
        data=modelWks.data;
        index=1;
        for i=1:length(data)
            if(isa(data(i).Value,'numeric')||isa(data(i).Value,'Simulink.Parameter'))
                autoCompleteData{1,index}=string(data(i).Name);%#ok
                autoCompleteData{2,index}=string(class(data(i).Value));%#ok
                index=index+1;
            end
        end
    end
end

function refreshTree(source,h)
    if(isempty(source.TreeSelectedItem)||isempty(source.TreeExpandItems))||...
        (strcmp(h.AccessBusElement,'on')&&(isempty(source.BusTreeSelectedElement)||isempty(source.BusTreeExpandElements)))
        ownerBlock=h.ParameterOwnerBlock;
        paramName=h.ParameterName;
        if(~isempty(ownerBlock)&&getSimulinkBlockHandle(ownerBlock)~=-1&&...
            strcmp(get_param(ownerBlock,'Commented'),'off'))
            modelName=get_param(bdroot(ownerBlock),'Object').Name;
            if~isempty(paramName)
                if(strcmp(h.AccessBusElement,'off'))
                    source.TreeSelectedItem=[ownerBlock,'/',paramName];
                    source.TreeExpandItems=source.getExpandTreeItems(ownerBlock,modelName,0);
                elseif slfeature('ParameterWriteToPartialModelArgument')>0
                    [pMainName,elePath]=getParamBusElePath(h);
                    source.TreeSelectedItem=[ownerBlock,'/',pMainName];
                    source.TreeExpandItems=source.getExpandTreeItems(ownerBlock,modelName,0);
                    source.BusTreeSelectedElement=elePath;
                    source.BusTreeExpandElements=source.getExpandTreeItems(elePath,pMainName,1);
                end
            else

                if slfeature('ParameterWriteToGeneralBlocks')>=2
                    source.TreeSelectedItem=ownerBlock;
                    source.TreeExpandItems=source.getExpandTreeItems(ownerBlock,modelName,0);
                end
            end
        end
    end
end

function paramNotSet=checkOwnerNoSelectParam(blkHandle)

    paramOwner=get_param(blkHandle,'ParameterOwnerBlock');
    paramName=get_param(blkHandle,'ParameterName');
    paramNotSet=~isempty(paramOwner)&&isempty(paramName);
end

function[pMainName,elePath]=getParamBusElePath(h)
    paramName=h.ParameterName;
    paramInternalName=h.ParameterInternalName;
    if~strcmp(paramName,paramInternalName)

        indexes1=strfind(paramName,'.');
        indexes2=strfind(paramInternalName,'.');
        prevIdx=1;
        for i=1:length(indexes1)
            if strcmp(paramName(indexes1(i)+1:end),paramInternalName(indexes2(i)+1:end))
                if(i==length(indexes1))
                    pMainName=paramName(prevIdx:end);
                    elePath=pMainName;
                else
                    pMainName=paramName(prevIdx:indexes1(i+1)-1);
                    elePaths=regexprep(paramName(indexes1(i)+1:end),'\.','/');
                    elePath=[paramName(prevIdx:indexes1(i)),elePaths];
                end
                return;
            end
            prevIdx=indexes1(i)+1;
        end
    else

        elePath=regexprep(paramName,'\.','/');
        pMainNameCell=regexp(paramName,'\.','split');
        pMainName=pMainNameCell{1};
    end

end
