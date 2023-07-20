

function[jsonString,jsonStruct,jsongStringForRootLevelFolders]=exportJSON(maObj,TreeSelection)




    jsonStruct=[];
    jsongStringForRootLevelFolders=[];

    am=Advisor.Manager.getInstance;

    if~isfield(am.slCustomizationDataStructure,'checkCellArray')
        am.loadslCustomization;
    end

    checkCellArray=am.slCustomizationDataStructure.checkCellArray;


    if strcmp(TreeSelection,'GetInputParameter')

        if~isa(maObj,'ModelAdvisor.Check')
            DAStudio.error('ModelAdvisor:engine:UnknownWorkFlow')
        end

        node=createJSONForCheck(maObj,'MACE');
        jsonString=node.InputParameters;

    elseif strcmp(TreeSelection,'EDITTIME')
        if isa(maObj,'ModelAdvisor.Check')
            taskNode=modeladvisorprivate('modeladvisorutil2','createTANFromCheck',checkCellArray,am.slCustomizationDataStructure.CheckIDMap(maObj.ID),[maObj.ID,'_']);
            taskNode.MACIndex=am.slCustomizationDataStructure.CheckIDMap(maObj.ID);
        else
            taskNode=maObj;
        end
        ConfigUIRoot=ModelAdvisor.Group('_SYSTEM');
        ConfigUIRoot.DisplayName=DAStudio.message('Simulink:tools:MACETitle');
        ConfigUIRoot.ChildrenObj{end+1}=taskNode;
        ConfigUIRoot.Children{end+1}=maObj.ID;
        nodes=emitJSONForTree(ConfigUIRoot,checkCellArray);
        nodes(1).parent=NaN;
        jsondata.Tree=nodes;
        jsonString=jsonencode(jsondata,'PrettyPrint',true);
        jsonStruct=[];
        return

    elseif strcmp(TreeSelection,'MACE')

        if isa(maObj,'ModelAdvisor.Check')

            nodes=createJSONForCheck(maObj,TreeSelection);

        elseif isa(maObj,'ModelAdvisor.ConfigUI')

            nodes=createJSONStruct(maObj,checkCellArray);

        elseif isa(maObj,'Simulink.ModelAdvisor')

            ConfigUIRoot=maObj.ConfigUIRoot;
            nodes=emitJSONForTree(ConfigUIRoot,checkCellArray);
            nodes(1).parent=NaN;

        elseif isempty(maObj)

            ConfigUIRoot=ModelAdvisor.Group('_SYSTEM');
            ConfigUIRoot.DisplayName=DAStudio.message('Simulink:tools:MACETitle');

            maceNode=emitJSONForTree(ConfigUIRoot,checkCellArray);
            maceNode(1).parent=NaN;

            jsongStringForRootLevelFolders=cell(1,numel(am.slCustomizationDataStructure.topLevelWorkFlows));
            RootLevelNodes=cell(1,numel(am.slCustomizationDataStructure.topLevelWorkFlows));

            for i=1:numel(am.slCustomizationDataStructure.topLevelWorkFlows)
                ConfigUIRoot.ChildrenObj{end+1}=am.slCustomizationDataStructure.TaskAdvisorCellArray{am.slCustomizationDataStructure.topLevelWorkFlows{i}};
                ConfigUIRoot.Children{end+1}=ConfigUIRoot.ChildrenObj{end}.ID;
                RootLevelNodes{i}=emitJSONForTree(ConfigUIRoot.ChildrenObj{end},checkCellArray);
                jsongStringForRootLevelFolders{i}=jsonencode(RootLevelNodes{i});
                RootLevelNodes{i}(1).parent=maceNode.id;
            end

            nodes=[maceNode,RootLevelNodes{:}];

        else
            DAStudio.error('ModelAdvisor:engine:UnknownWorkFlow');
        end

        jsonString=jsonencode(nodes);

    else
        DAStudio.error('ModelAdvisor:engine:UnknownWorkFlow');
    end
end

function nodeStruct=createJSONForCheck(checkObj,TreeSelection)

    nodeStruct.id=checkObj.ID;
    nodeStruct.label=checkObj.Title;
    nodeStruct.enable=checkObj.Enable;
    nodeStruct.description=checkObj.Description;
    nodeStruct.check=checkObj.Selected;
    nodeStruct.iscompile=~strcmp(checkObj.CallbackContext,'None');

    if isempty(checkObj.InputParametersLayoutGrid)
        nodeStruct.InputParametersLayoutGrid_row=0;
        nodeStruct.InputParametersLayoutGrid_col=0;
    else
        nodeStruct.InputParametersLayoutGrid_row=checkObj.InputParametersLayoutGrid(1);
        nodeStruct.InputParametersLayoutGrid_col=checkObj.InputParametersLayoutGrid(2);
    end

    if~strcmp(TreeSelection,'MACE')
        if size(checkObj.Action,2)>0
            nodeStruct.action=struct('Name',checkObj.Action.Name,...
            'Description',checkObj.Action.Description,...
            'Enable',checkObj.Action.enable);
        else
            nodeStruct.action=struct('Name','NA',...
            'Description','NA',...
            'Enable','NA');
        end
    end

    nodeStruct.InputParameters=createInputParameters(checkObj);
    nodeStruct.helpPath='';
    nodeStruct.oldid='';
    nodeStruct.oldparent='';
end

function InputParameters=createInputParameters(checkObj)

    if isempty(checkObj.InputParameters)
        InputParameters=[];
        return
    end

    InputParameters=struct('name','',...
    'index',0,...
    'type','',...
    'visible','',...
    'entries','',...
    'value','',...
    'rowspan1','',...
    'rowspan2','',...
    'colspan1','',...
    'colspan2','',...
    'isenable',true);

    for i=1:length(checkObj.InputParameters)
        inpElement.name=checkObj.InputParameters{i}.Name;
        inpElement.index=i;
        inpElement.isenable=checkObj.InputParameters{i}.Enable;
        inpElement.type=checkObj.InputParameters{i}.Type;
        inpElement.visible=checkObj.InputParameters{i}.Visible;

        if~isempty(checkObj.InputParameters{i}.RowSpan)
            inpElement.rowspan1=checkObj.InputParameters{i}.RowSpan(1);
            inpElement.rowspan2=checkObj.InputParameters{i}.RowSpan(2);
        else
            inpElement.rowspan1=i;
            inpElement.rowspan2=i;
        end

        if~isempty(checkObj.InputParameters{i}.ColSpan)
            inpElement.colspan1=checkObj.InputParameters{i}.ColSpan(1);
            inpElement.colspan2=checkObj.InputParameters{i}.ColSpan(2);
        else
            inpElement.colspan1=1;
            inpElement.colspan2=1;
        end

        switch checkObj.InputParameters{i}.Type
        case 'BlockType'
            ValueElement=[];
            for j=1:length(checkObj.InputParameters{i}.Value)
                if isempty(checkObj.InputParameters{i}.Value{j})
                    continue;
                end
                ValueElement(j).name=checkObj.InputParameters{i}.Value{j,1};
                ValueElement(j).masktype=checkObj.InputParameters{i}.Value{j,2};
            end
            inpElement.entries=checkObj.InputParameters{i}.Entries;
            inpElement.value=ValueElement;
        case 'BlockTypeWithParameter'
            ValueElement=[];
            for j=1:length(checkObj.InputParameters{i}.Value)
                if isempty(checkObj.InputParameters{i}.Value{j})
                    continue;
                end
                ValueElement(j).name=checkObj.InputParameters{i}.Value{j,1};
                ValueElement(j).masktype=checkObj.InputParameters{i}.Value{j,2};
                ValueElement(j).blocktypeparameters=checkObj.InputParameters{i}.Value{j,3};
            end
            inpElement.entries=checkObj.InputParameters{i}.Entries;
            inpElement.value=ValueElement;
        case 'PushButton'
            inpElement.entries=[];
            inpElement.value=checkObj.InputParameters{i}.value;
        otherwise
            inpElement.entries=checkObj.InputParameters{i}.Entries;
            inpElement.value=checkObj.InputParameters{i}.value;
        end
        InputParameters(i)=inpElement;
    end
end

function nodeStruct=createJSONStruct(node,checkCellArray)

    nodeStruct.id=node.ID;%#ok<*AGROW>
    nodeStruct.label=node.DisplayName;
    nodeStruct.enable=node.Enable;
    nodeStruct.CSHParameters=node.CSHParameters;
    nodeStruct.helpPath='';
    nodeStruct.oldid='';
    nodeStruct.oldparent='';
    nodeStruct.InputParametersCallback=false;

    if isa(node,'ModelAdvisor.Task')||isempty(node.InputParametersLayoutGrid)
        nodeStruct.InputParametersLayoutGrid_row=0;
        nodeStruct.InputParametersLayoutGrid_col=0;
    else
        nodeStruct.InputParametersLayoutGrid_row=node.InputParametersLayoutGrid(1);
        nodeStruct.InputParametersLayoutGrid_col=node.InputParametersLayoutGrid(2);
    end

    nodeStruct.description=node.Description;
    nodeStruct.InputParameters=[];
    nodeStruct.originalnodeid=node.ID;
    nodeStruct.Severity='';
    nodeStruct.EdittimeClassname='';
    nodeStruct.ConstraintXML='';

    if isa(node,'ModelAdvisor.Task')
        if~isempty(node.InputParameters)
            nodeStruct.InputParameters=createInputParameters(node);
        else
            nodeStruct.InputParameters=createInputParameters(checkCellArray{node.MACIndex});
        end
        if(node.MACIndex>0)
            if~isempty(checkCellArray{node.MACIndex}.InputParametersCallback)
                nodeStruct.InputParametersCallback=true;
            end
        end
        nodeStruct.Severity=node.Severity;

        if ischar(checkCellArray{node.MACIndex}.CallbackHandle)
            nodeStruct.EdittimeClassname=checkCellArray{node.MACIndex}.CallbackHandle;
        end
    elseif isa(node,'ModelAdvisor.ConfigUI')
        nodeStruct.InputParameters=createInputParameters(node);
        if(node.MACIndex>0)
            if~isempty(checkCellArray{node.MACIndex}.InputParametersCallback)
                nodeStruct.InputParametersCallback=true;
            end
        end

        if slfeature('MACEConfigurationValidation')
            nodeStruct.MACIndex=node.MACIndex;
        end
    end

    nodeStruct.check=node.Selected;
    nodeStruct.iscompile=false;
    nodeStruct.isedittime=false;
    nodeStruct.isblockconstraint=false;


    if isa(node,'ModelAdvisor.Group')
        nodeStruct.checkid=NaN;
        nodeStruct.searchdata=[nodeStruct.label,' ',nodeStruct.description];
        nodeStruct.iconUri=node.getDisplayIcon;
    else

        if isempty(node.MAC)
            nodeStruct.checkid=NaN;
            nodeStruct.iconUri=node.getDisplayIcon;
            if slfeature('MACEConfigurationValidation')
                nodeStruct.MACIndex=node.MACIndex;
            end
        else
            nodeStruct.checkid=node.MAC;
            if node.MACIndex>0
                checkObj=checkCellArray{node.MACIndex};
                nodeStruct.iscompile=~strcmp(checkObj.CallbackContext,'None');
                if strcmp(checkObj.CallbackContext,'None')
                    nodeStruct.iconUri='toolbox/simulink/simulink/modeladvisor/private/no_compile_16.png';
                elseif strcmp(checkObj.CallbackContext,'PostCompile')
                    nodeStruct.iconUri='toolbox/simulink/simulink/modeladvisor/private/compile_16.png';
                else
                    nodeStruct.iconUri='toolbox/simulink/simulink/modeladvisor/private/larger_compile_16.png';
                end
            else
                nodeStruct.iconUri=node.getDisplayIcon;
            end
        end

        nodeStruct.searchdata=[nodeStruct.label,' ',nodeStruct.checkid,' ',nodeStruct.description];

        if node.MACIndex>0&&checkCellArray{node.MACIndex}.SupportsEditTime

            nodeStruct.searchdata=[nodeStruct.searchdata,' ','@edit_time_supported_check'];
            nodeStruct.isedittime=true;
        end
        if node.MACIndex>0&&checkCellArray{node.MACIndex}.getIsBlockConstraintCheck
            nodeStruct.isblockconstraint=true;
            if~isempty(nodeStruct.InputParameters)&&strcmp(nodeStruct.InputParameters.name,'Data File')
                if exist(nodeStruct.InputParameters.value,"file")
                    nodeStruct.ConstraintXML=fileread(nodeStruct.InputParameters.value);
                end
            else
                nodeStruct.ConstraintXML=checkCellArray{node.MACIndex}.getConstraintString();
            end
        end
    end

    if~isa(node,'ModelAdvisor.ConfigUI')
        if(node.state==ModelAdvisor.CheckStatus.Warning)
            nodeStruct.runStatus='Warning';
        elseif(node.state==ModelAdvisor.CheckStatus.NotRun)
            nodeStruct.runStatus='notRun';
        elseif(node.state==ModelAdvisor.CheckStatus.Failed)
            nodeStruct.runStatus='Fail';
        elseif(node.state==ModelAdvisor.CheckStatus.Passed)
            nodeStruct.runStatus='Pass';
        else
            nodeStruct.runStatus=node.state;
        end
    end

    if isempty(deblank(nodeStruct.iconUri))
        nodeStruct.iconUri=NaN;
    else
        nodeStruct.iconUri=['/',nodeStruct.iconUri];
    end
    nodeStruct.parent=node.ParentObj;
    if isempty(nodeStruct.parent)
        nodeStruct.parent=NaN;
    else
        nodeStruct.parent=nodeStruct.parent.ID;
    end
end

function node=emitJSONForTree(maTree,checkCellArray)
    if isempty(maTree)
        node=[];
        return
    end
    node=createJSONStruct(maTree,checkCellArray);
    if isa(maTree,'ModelAdvisor.Group')||isa(maTree,'ModelAdvisor.ConfigUI')
        for i=1:numel(maTree.ChildrenObj)
            needResetParentObj=false;
            if isempty(maTree.ChildrenObj{i}.ParentObj)
                needResetParentObj=true;
                maTree.ChildrenObj{i}.ParentObj=maTree;
            end
            node=[node,emitJSONForTree(maTree.ChildrenObj{i},checkCellArray)];


            if needResetParentObj
                maTree.ChildrenObj{i}.ParentObj=[];
            end
        end
    end
end

