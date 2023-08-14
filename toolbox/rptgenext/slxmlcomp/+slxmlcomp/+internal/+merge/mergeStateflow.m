function[modifiedObjects,message]=mergeStateflow(type,mergeActionData)






















    message='';
    action=char(mergeActionData.getActionName());
    try
        switch action
        case 'Delete'
            modifiedObjects=i_DeleteObject(mergeActionData);
        case 'Insert'
            [modifiedObjects,message]=i_InsertObject(mergeActionData);
        case 'Parameter'
            modifiedObjects=i_MergeParameter(mergeActionData);
        otherwise
            error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomerge'));
        end
    catch ME
        ME.getReport();
        rethrow(ME);
    end
end







function modifiedObjects=i_DeleteObject(mergeActionData)


    dstNode=mergeActionData.getToNode();
    dstPath=char(dstNode.getNodePath());



    sfprivate('traceabilityManager','unHighlightObject',dstPath);

    object=i_GetStateflowObject(dstNode);
    if(isempty(object))
        modifiedObjects=[];
        return;
    end


    specialHandlingForData=false;
    switch(char(dstNode.getTagName()))
    case 'range'
        object.Props.Range.Minimum='';
        object.Props.Range.Maximum='';
        specialHandlingForData=true;
    case 'array'
        object.Props.Array.Size='';
        object.Props.Array.FirstIndex='';
        object.Props.Array.IsDynamic=0;
        specialHandlingForData=true;
    case 'fixpt'
        object.Props.Type.Fixpt.ScalingMode='None';
        object.Props.Type.Fixpt.Bias='';
        object.Props.Type.Fixpt.Slope='';
        object.Props.Type.Fixpt.FractionLength='';
        specialHandlingForData=true;
    end
    if(specialHandlingForData)
        modifiedObjects=[];
        return;
    end



    transitionMap=i_GetAffectedTransitions(object,mergeActionData.getAffectedNodes());
    debugDisplay('deleting',object);
    if(isAContainer(object)&&object.isSubChart)



        srcTrans=sf('get',object.Id,'.srcTransitions');
        outgoingSuperTrans=sf('find',srcTrans,'.type','SUB','.src.intersection.space','SUB_SPACE');
        for i=1:length(outgoingSuperTrans)
            transHandle=idToHandle(sfroot,outgoingSuperTrans(i));
            debugDisplay('deleting',transHandle);
            delete_safely(transHandle);
        end
    end
    parent=object.up;
    delete_safely(object);



    i_UpdateTransitions(parent,transitionMap,mergeActionData);

    modifiedObjects=transitionMap.values;
end

function delete_safely(object)
    parent=object.up;
    if(isAContainer(parent))
        groupStatus=parent.IsGrouped;
        parent.IsGrouped=0;
        if isAContainer(object)
            object.IsGrouped=1;
        end
        object.delete;
        parent.IsGrouped=groupStatus;
    else
        if isAContainer(object)
            object.IsGrouped=1;
        end
        object.delete;
    end
end


function[modifiedObjects,message]=i_InsertObject(mergeActionData)


    modifiedObjects=java.util.ArrayList;


    srcNode=mergeActionData.getFromNode();
    [srcObj,srcObjId]=i_GetStateflowObject(srcNode);
    dstNode=mergeActionData.getToNode();
    dstObj=i_GetStateflowObject(dstNode);



    result=i_HandleActiveStateOutput(srcNode,srcObj,dstObj);
    if(result)
        newNode=srcNode.copy();
        message='';
        newParent=[];
        modifiedObjects.add(newNode);
        modifiedObjects.add(newParent);
        return;
    end
    if(isempty(srcObj)||isempty(dstObj))

        newNode=srcNode.copy();
        message='';
        newParent=[];
        modifiedObjects.add(newNode);
        modifiedObjects.add(newParent);
        return;
    end

    isASuperTransition=~isempty(sf('find',srcObjId,'transition.type','SUPER'));
    isASubTransition=~isempty(sf('find',srcObjId,'transition.type','SUB'));
    if(isASubTransition)
        newNode=srcNode.copy();
        message='';
        newParent=[];
        modifiedObjects.add(newNode);
        modifiedObjects.add(newParent);
        return;
    end
    specialHandlingForData=false;
    switch(char(srcNode.getTagName()))
    case 'range'
        dstObj.Props.Range.Minimum=srcObj.Props.Range.Minimum;
        dstObj.Props.Range.Maximum=srcObj.Props.Range.Maximum;
        specialHandlingForData=true;
    case 'array'
        dstObj.Props.Array.Size=srcObj.Props.Array.Size;
        dstObj.Props.Array.FirstIndex=srcObj.Props.Array.FirstIndex;
        dstObj.Props.Array.IsDynamic=srcObj.Props.Array.IsDynamic;
        specialHandlingForData=true;
    case 'fixpt'

        specialHandlingForData=true;
    end
    if(specialHandlingForData)
        newNode=srcNode.copy();
        message='';
        newParent=[];
        modifiedObjects.add(newNode);
        modifiedObjects.add(newParent);
        return;
    end
    if isa(srcObj,'Stateflow.Transition')
        targetSource=mergeActionData.getToSource();
        differences=mergeActionData.getDiffSet();
        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
        import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.type.transition.TransitionUtils;


        ssIdMappingInfo=access_ssid_mapping('get',dstObj.Machine.id);

        unconnectedSource=sf('get',srcObjId,'.src.id')==0;
        if(unconnectedSource)
            srcID='';
        else
            if(~isempty(ssIdMappingInfo)&&isKey(ssIdMappingInfo,srcObj.Source.ssIdNumber))
                srcToConnectToSSID=ssIdMappingInfo(srcObj.Source.ssIdNumber);
                srcID=int2str(srcToConnectToSSID);
            else
                srcID=char(TransitionUtils.getMatchedStateSSID(srcNode,'src',differences,targetSource));
                if isempty(srcID)
                    error(...
                    slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomergetransition.source',...
                    LightweightNodeUtils.getParameterValue(srcNode,'srcName'),...
                    LightweightNodeUtils.getParameterValue(srcNode,'dstName')));
                end
            end
        end
        unconnectedDest=sf('get',srcObjId,'.dst.id')==0;
        if(unconnectedDest)
            dstID='';
        else
            if(~isempty(ssIdMappingInfo)&&isKey(ssIdMappingInfo,srcObj.Destination.ssIdNumber))
                dstToConnectToSSID=ssIdMappingInfo(srcObj.Destination.ssIdNumber);
                dstID=int2str(dstToConnectToSSID);
            else
                dstID=char(TransitionUtils.getMatchedStateSSID(srcNode,'dst',differences,targetSource));
                if isempty(dstID)
                    error(...
                    slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomergetransition.destination',...
                    LightweightNodeUtils.getParameterValue(srcNode,'srcName'),...
                    LightweightNodeUtils.getParameterValue(srcNode,'dstName')));
                end
            end
        end
    end


    if srcObj.isValidProperty('Position')
        position=get(srcObj,'Position');
    else
        position=[];
    end


    if isAContainer(srcObj)
        group=1;
        grouped=srcObj.IsGrouped;
        srcObj.IsGrouped=1;
    else
        group=0;
    end


    cb=sfclipboard;
    cb.copy(srcObj);

    if(isAContainer(dstObj))
        if~dstObj.IsSubchart
            dstObj=dstObj.Subviewer;
        end
    end


    currentObjs=dstObj.find('-depth',1);
    cb.pasteTo(dstObj);
    newObjs=dstObj.find('-depth',1);
    newObj=setdiff(newObjs,currentObjs);
    debugDisplay('inserted',newObj);


    if numel(newObj)>1
        error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomerge'));
    end

    if(isAContainer(newObj))
        compute_ssid_mapping_for_copied_objects(newObj.Machine,srcObj,newObj);
        if(newObj.isSubchart)



            srcSubLinks=sf('find',sf('get',newObj.id,'state.srcTransitions'),'.type','SUB');
            dstSubLinks=sf('find',sf('get',newObj.id,'state.dstTransitions'),'.type','SUB');
            allSubLinks=[srcSubLinks,dstSubLinks];
            for i=1:length(allSubLinks)
                subLinkTrans=idToHandle(sfroot,allSubLinks(i));
                delete_safely(subLinkTrans);
            end
        end
    end


    if isa(srcObj,'Stateflow.Transition')

        if(~isempty(srcID))
            srcToConnectTo=dstObj.find('SSID',str2double(srcID));
            if~isValidTransitionEndPoint(srcToConnectTo)
                error(...
                slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomergetransition.source',...
                LightweightNodeUtils.getParameterValue(srcNode,'srcName'),...
                LightweightNodeUtils.getParameterValue(srcNode,'dstName')));
            end
        else

            srcToConnectTo=[];
        end

        if(~isempty(dstID))
            dstToConnectTo=dstObj.find('SSID',str2double(dstID));
            if~isValidTransitionEndPoint(dstToConnectTo)
                error(...
                slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomergetransition.destination',...
                LightweightNodeUtils.getParameterValue(srcNode,'srcName'),...
                LightweightNodeUtils.getParameterValue(srcNode,'dstName')));
            end
        else

            dstToConnectTo=[];
        end

        connect_transition(isASuperTransition,newObj,srcObj,dstObj,srcToConnectTo,dstToConnectTo);

    end

    function isValid=isValidTransitionEndPoint(item)
        isValid=~isempty(item)...
        &&(isa(item,'Stateflow.Junction')...
        ||isa(item,'Stateflow.State'))...
        ||isa(item,'Stateflow.SimulinkBasedState')...
        ||isa(item,'Stateflow.Subchart')...
        ||isa(item,'Stateflow.AtomicSubchart');
    end


    if~isempty(position)
        if isa(srcObj,'Stateflow.Junction')
            newObj.Position.Radius=position.Radius;
            newObj.Position.Center=position.Center;
        elseif~srcObj.isReadonlyProperty('Position')
            set(newObj,'Position',position);
        end
    end

    [newNode,message,newParent]=i_CreateNode(srcNode,newObj,dstNode);


    paramDifferences={};

    if newObj.isValidProperty('SSIdNumber')||isa(newObj,'Stateflow.Event')
        paramDifferences={'ID',slxmlcomp.internal.convertToString(get(newObj,'SSIdNumber')),''};
        paramDifferences=[paramDifferences;{'SSID',slxmlcomp.internal.convertToString(get(newObj,'SSIdNumber')),''}];
    end

    if isa(newObj,'Stateflow.Transition')
        paramDifferences=[paramDifferences;{'srcName',i_getSFObjString(get(newObj,'Source')),''}];
        paramDifferences=[paramDifferences;{'dstName',i_getSFObjString(get(newObj,'Destination')),''}];
    end

    parameterUpdater=mergeActionData.getParameterUpdater();
    targetChoice=mergeActionData.getFromSide();
    parameterNameToDiffMap=mergeActionData.getParameterNameToDifferenceMap();
    slxmlcomp.internal.merge.updateNodeParameters(parameterUpdater,newNode,paramDifferences,true,false,srcNode,targetChoice,parameterNameToDiffMap);
    modifiedObjects.add(newNode);
    if~isempty(newParent)
        modifiedObjects.add(newParent);
    end

    if~isa(newObj,'Stateflow.Transition')
        transitions=com.mathworks.toolbox.rptgenslxmlcomp.comparison.merge.SimulinkMergeAction.getAffectedNodes(srcNode.getParent());
        transitionMap=i_GetAffectedTransitions(srcObj,transitions);
        i_UpdateTransitionSSIDs(transitionMap,srcNode,newNode,mergeActionData);
    end


    if group
        srcObj.IsGrouped=grouped;
        newObj.IsGrouped=grouped;
    end

    function name=i_getSFObjString(obj)
        name='';
        if~isempty(obj)
            if isa(obj,'Stateflow.Junction')
                name='junction';
            elseif isa(obj,'Stateflow.SimulinkBasedState')
                name=get(obj,'Name');
            else
                name=get(obj,'labelString');
            end
        end
    end

end

function compute_ssid_mapping_for_copied_objects(targetMachine,srcObj,dstObj)
    srcStates=sf('AllSubstatesIn',srcObj.Id,true);
    srcJunctions=sf('JunctionsIn',srcObj.Id,true);

    dstStates=sf('AllSubstatesIn',dstObj.Id,true);
    dstJunctions=sf('JunctionsIn',dstObj.Id,true);

    if(length(srcStates)==length(dstStates)&&...
        length(srcJunctions)==length(dstJunctions))
        allSources=[srcObj.Id,srcStates,srcJunctions];
        allDsts=[dstObj.Id,dstStates,dstJunctions];
        allSourceSSIDs=sf('get',allSources,'.ssIdNumber');
        allDstSSIDs=sf('get',allDsts,'.ssIdNumber');
        access_ssid_mapping('set',targetMachine.Id,allSourceSSIDs,allDstSSIDs);
    else
        disp('something went wrong in paste container');
    end
end

function result=access_ssid_mapping(method,machineId,varargin)
    persistent ssIdMappingInfo;
    modelH=sf('get',machineId,'.simulinkModel');
    switch(method)
    case 'get'
        if(~isempty(ssIdMappingInfo)&&isKey(ssIdMappingInfo,modelH))
            machineMappingInfo=ssIdMappingInfo(modelH);
        else
            machineMappingInfo=[];
        end
    case 'set'
        if(~isempty(ssIdMappingInfo)&&isKey(ssIdMappingInfo,modelH))
            machineMappingInfo=ssIdMappingInfo(modelH);
        else
            machineMappingInfo=[];
        end
        allSourceSSIDs=varargin{1};
        allDstSSIDs=varargin{2};
        if(isempty(machineMappingInfo))
            machineMappingInfo=containers.Map(allSourceSSIDs,allDstSSIDs);
            if(isempty(ssIdMappingInfo))
                ssIdMappingInfo=containers.Map(modelH,machineMappingInfo);
            else

                garbage_collect_ssid_mapping(ssIdMappingInfo);
                ssIdMappingInfo(modelH)=machineMappingInfo;
            end
        else
            for i=1:length(allSourceSSIDs)
                machineMappingInfo(allSourceSSIDs(i))=allDstSSIDs(i);
            end
        end
    end
    result=machineMappingInfo;
end

function garbage_collect_ssid_mapping(mappingInfo)
    modelHandles=keys(mappingInfo);
    for i=1:length(modelHandles)
        if(~ishandle(modelHandles{i}))
            remove(mappingInfo,modelHandles{i});
        end
    end
end


function connect_transition(isASuperTransition,newObj,srcObj,dstObj,srcToConnectTo,dstToConnectTo)
    if(isASuperTransition)
        chartId=newObj.Chart.id;
        chartVisibility=sf('get',chartId,'.visible');
        showEditTimeIssues=get_param(0,'ShowEditTimeIssues');
        set_param(0,'ShowEditTimeIssues','off');
    end

    if(~isempty(srcToConnectTo))
        srcSubchartInfo=unsubchart_upto_path_parent(srcToConnectTo,dstObj);
        newObj.Source=srcToConnectTo;
        newObj.SourceOClock=srcObj.SourceOClock;
    else
        newObj.SourceEndpoint=srcObj.SourceEndpoint;
    end


    if(~isempty(dstToConnectTo))
        dstSubchartInfo=unsubchart_upto_path_parent(dstToConnectTo,dstObj);
        newObj.Destination=dstToConnectTo;
        newObj.DestinationOClock=srcObj.DestinationOClock;
    else
        newObj.MidPoint=srcObj.MidPoint;
        newObj.DestinationEndpoint=srcObj.DestinationEndpoint;
    end

    if(isASuperTransition)
        if(~isempty(srcToConnectTo))
            resubchart(srcSubchartInfo);
        end
        if(~isempty(dstToConnectTo))
            resubchart(dstSubchartInfo);
        end
        update_sublink_slit_position(newObj);
        set_param(0,'ShowEditTimeIssues',showEditTimeIssues);
        sf('set',chartId,'.visible',chartVisibility);
    end
end

function update_sublink_slit_position(newObj)


    if(isa(newObj.up,'Stateflow.Chart'))
        return;
    end
    subViewerId=newObj.up.Id;
    nextSubLink=sf('get',newObj.id,'.subLink.next');
    if(nextSubLink)
        [side,ratio]=sf('get',nextSubLink,'.src.intersection.side','.src.intersection.ratio');
        pos=sf('get',subViewerId,'.subviewS.pos');
        slitPosition=compute_slit_position(side,ratio,pos);

        endPoint=slitPosition;
        sourcePoint=sf('get',newObj.id,'.src.intersection.point');
        midPoint=sourcePoint+(endPoint-sourcePoint)/2;
        labelPosition=sf('get',newObj.id,'.labelPosition');
        labelPosition(1:2)=midPoint;
        sf('set',newObj.id,'.labelPosition',labelPosition,...
        '.midPoint',midPoint,...
        '.dst.intersection.point',endPoint,...
        '.dst.intersection.side',side,...
        '.dst.intersection.ratio',ratio);
    end
end

function slitPosition=compute_slit_position(side,ratio,pos)

    x=pos(1);
    y=pos(2);
    w=pos(3);
    h=pos(4);
    offset=10;
    switch(side)
    case 1
        xPos=x+ratio*w;
        yPos=y-offset;

    case 2
        xPos=x+w+offset;
        yPos=y+ratio*h;

    case 3
        xPos=x+ratio*w;
        yPos=y+h+offset;

    case 4
        xPos=x-offset;
        yPos=y+ratio*h;
    end
    slitPosition=[xPos,yPos];
end

function subchartInfo=unsubchart_upto_path_parent(leafObject,pathParent)
    subchartInfo.subchartList={};
    subchartInfo.subviewerProps={};
    parent=leafObject.up;
    while(parent~=pathParent)
        if(parent.IsSubchart)
            subchartInfo.subchartList{end+1}=parent;
            subchartInfo.subviewerProps{end+1}=capture_subviewer_object_properties(parent);
        end
        parent=getParent(parent);
    end
    for i=1:length(subchartInfo.subchartList)
        subchart=subchartInfo.subchartList{i};
        preSubchartPosition=subchart.position;
        subchart.IsSubchart=0;
        subchart.position=preSubchartPosition;
        subchart.IsGrouped=0;
    end
end

function resubchart(subchartInfo)
    for i=1:length(subchartInfo.subchartList)
        subchartInfo.subchartList{i}.IsSubchart=1;
    end
    for i=1:length(subchartInfo.subchartList)
        restore_subviewer_object_properties(subchartInfo.subviewerProps{i});
    end
end

function subviewerObjectProperties=capture_subviewer_object_properties(s)

    states=sf('get',s.id,'.localStates');
    transitions=sf('get',s.id,'.localTransitions');
    junctions=sf('get',s.id,'.localJunctions');

    stateProperties=cell(length(states),1);
    for i=1:length(states)
        state=idToHandle(sfroot,states(i));
        stateProperties{i}=capture_state_properties(state);
    end
    transProperties=cell(length(transitions),1);
    for i=1:length(transitions)
        trans=idToHandle(sfroot,transitions(i));
        transProperties{i}=capture_trans_properties(trans);
    end

    junctionProperties=cell(length(junctions),1);
    for i=1:length(junctions)
        junction=idToHandle(sfroot,junctions(i));
        junctionProperties{i}=capture_junction_properties(junction);
    end

    subviewerObjectProperties.states=states;
    subviewerObjectProperties.transitions=transitions;
    subviewerObjectProperties.junctions=junctions;
    subviewerObjectProperties.stateProperties=stateProperties;
    subviewerObjectProperties.transProperties=transProperties;
    subviewerObjectProperties.junctionProperties=junctionProperties;

    subviewS.panLimits=sf('get',s.id,'.subviewS.panLimits');
    subviewS.objectLimits=sf('get',s.id,'.subviewS.objectLimits');
    subviewS.x1=sf('get',s.id,'.subviewS.x1');
    subviewS.y1=sf('get',s.id,'.subviewS.y1');
    subviewS.zoomFactor=sf('get',s.id,'.subviewS.zoomFactor');
    subviewS.pos=sf('get',s.id,'.subviewS.pos');
    subviewS.fontSize=sf('get',s.id,'.subviewS.fontSize');
    subviewerObjectProperties.subviewS=subviewS;
    subviewerObjectProperties.Id=s.Id;

end


function restore_subviewer_object_properties(subviewerObjectProperties)

    subviewS=subviewerObjectProperties.subviewS;

    sf('flag','state.subviewS.panLimits:all','save3/show/write');
    sf('set',subviewerObjectProperties.Id,'.subviewS.panLimits',subviewS.panLimits);
    sf('flag','state.subviewS.panLimits:all','save3/show');

    sf('flag','state.subviewS.objectLimits:all','save3/show/write');
    sf('set',subviewerObjectProperties.Id,'.subviewS.objectLimits',subviewS.objectLimits);
    sf('flag','state.subviewS.objectLimits:all','save3/show');

    sf('flag','state.subviewS.x1','save3/show/write');
    sf('set',subviewerObjectProperties.Id,'.subviewS.x1',subviewS.x1);
    sf('flag','state.subviewS.x1','save3/show');

    sf('flag','state.subviewS.y1','save3/show/write');
    sf('set',subviewerObjectProperties.Id,'.subviewS.y1',subviewS.y1);
    sf('flag','state.subviewS.y1','save3/show');


    sf('flag','state.subviewS.pos:all','save3/show/write');
    sf('set',subviewerObjectProperties.Id,'.subviewS.pos',subviewS.pos);
    sf('flag','state.subviewS.pos:all','save3/show');

    sf('flag','state.subviewS.zoomFactor','save3/show/write');
    sf('set',subviewerObjectProperties.Id,'.subviewS.zoomFactor',subviewS.zoomFactor);
    sf('flag','state.subviewS.zoomFactor','save3/show');



    for i=1:length(subviewerObjectProperties.states)
        state=idToHandle(sfroot,subviewerObjectProperties.states(i));
        restore_state_properties(state,subviewerObjectProperties.stateProperties{i});
    end
    for i=1:length(subviewerObjectProperties.junctions)
        junction=idToHandle(sfroot,subviewerObjectProperties.junctions(i));
        restore_junction_properties(junction,subviewerObjectProperties.junctionProperties{i});
    end
    for i=1:length(subviewerObjectProperties.transitions)
        trans=idToHandle(sfroot,subviewerObjectProperties.transitions(i));
        restore_trans_properties(trans,subviewerObjectProperties.transProperties{i});
    end
end

function stateProperties=capture_state_properties(state)
    stateProperties.position=state.position;
    stateProperties.fontSize=state.fontSize;
    stateProperties.arrowSize=state.arrowSize;
end
function stateProperties=restore_state_properties(state,stateProperties)
    state.position=stateProperties.position;
    state.fontSize=stateProperties.fontSize;
    state.arrowSize=stateProperties.arrowSize;
end

function transProperties=capture_trans_properties(trans)
    transProperties.labelPosition=trans.labelPosition;
    transProperties.fontSize=trans.fontSize;
    transProperties.arrowSize=trans.arrowSize;
    transProperties.Midpoint=trans.Midpoint;
    transProperties.SourceEndpoint=trans.SourceEndpoint;
    transProperties.DestinationEndpoint=trans.DestinationEndpoint;
end

function restore_trans_properties(trans,transProperties)
    trans.labelPosition=transProperties.labelPosition;
    trans.fontSize=transProperties.fontSize;
    trans.arrowSize=transProperties.arrowSize;
    if(isempty(trans.Source))

        trans.Midpoint=transProperties.Midpoint;
        trans.SourceEndpoint=transProperties.SourceEndpoint;
    end
end

function junctionProperties=capture_junction_properties(junction)
    junctionProperties.center=junction.position.center;
    junctionProperties.radius=junction.position.radius;
    junctionProperties.arrowSize=junction.arrowSize;
end

function restore_junction_properties(junction,junctionProperties)
    junction.position.center=junctionProperties.center;
    junction.position.radius=junctionProperties.radius;
    junction.arrowSize=junctionProperties.arrowSize;
end


function modifiedObjects=i_MergeParameter(mergeActionData)


    modifiedObjects=java.util.ArrayList;


    srcNode=mergeActionData.getFromNode();
    [srcObj,srcObjectId]=i_GetStateflowObject(srcNode);
    dstNode=mergeActionData.getToNode();
    [dstObj,dstObjectId]=i_GetStateflowObject(dstNode);

    result=i_HandleActiveStateOutput(srcNode,srcObj,dstObj);
    if(result)
        return;
    end
    if(isempty(dstObj))

        return;
    end


    dstParent=dstObj.getParent();

    if isAContainer(dstParent)
        grouped=dstParent.IsGrouped;
        dstParent.IsGrouped=false;
        group=true;
    else
        group=false;
    end


    paramName=char(mergeActionData.getParameterName());
    debugDisplay('setting',dstObj,paramName);
    try

        specialHandling=false;

        if(isa(dstObj,'Stateflow.Data'))
            specialHandling=true;
            switch(paramName)
            case{'size','firstIndex','isDynamic'}
                dstObj.props.array.(paramName)=srcObj.props.array.(paramName);
            case{'resolveToSignalObject','initialValue','complexity','frame'}
                dstObj.props.(paramName)=srcObj.props.(paramName);
            case{'minimum','maximum'}
                dstObj.props.range.(paramName)=srcObj.props.range.(paramName);
            case{'method','primitive','expression','busObject','enumType'}
                dstObj.props.type.(paramName)=srcObj.props.type.(paramName);
            case{'scalingMode','fractionLength','slope','bias'}
                dstObj.props.type.fixpt.(paramName)=srcObj.props.type.fixpt.(paramName);
            case 'name'
                if strcmp(srcNode.getName().char,'unit')
                    dstObj.props.unit.name=srcObj.props.unit.name;

                else
                    specialHandling=false;
                end
            otherwise
                specialHandling=false;
            end
        end
        switch(paramName)
        case 'midPoint'


            if(~isempty(sf('find',srcObjectId,'.type','SUB')))



                srcMidPoint=sf('get',srcObjectId,'.midPoint');
                sf('set',dstObjectId,'.midPoint',srcMidPoint);
            end
            specialHandling=true;
        case 'labelPosition'
            if(~isempty(sf('find',srcObjectId,'.type','SUB')))


                srcLabelPosition=sf('get',srcObjectId,'.labelPosition');
                sf('set',dstObjectId,'.labelPosition',srcLabelPosition);
                specialHandling=true;
            end
        case 'position'
            if(isa(dstObj,'Stateflow.Junction'))
                srcParamValue=get(srcObj,paramName);
                dstObj.Position.Radius=srcParamValue.Radius;
                dstObj.Position.Center=srcParamValue.Center;
                specialHandling=true;
            end

        case{'allowGlobalAccessToExportedFunctions','exportChartFunctions','actionLanguage','saturateOnIntegerOverflow'}
            if(isa(dstObj,'Stateflow.AtomicSubchart'))
                dstObj.Chart.(paramName)=srcObj.Chart.(paramName);
                specialHandling=true;
            end
        otherwise
        end

        if(~specialHandling)
            srcParamValue=get(srcObj,paramName);
            set(dstObj,paramName,srcParamValue);
        end
    catch E %#ok<NASGU>

        if group
            dstParent.IsGrouped=grouped;
        end
        return
    end


    if group
        dstParent.IsGrouped=grouped;
    end


    newDstParams=get(dstObj);


    filters={};

    oldDstParams=get(dstObj);
    differences=i_GetParameterDifferences(newDstParams,oldDstParams,filters);
    differences=i_ParameterSpecialCase(dstObj,differences);
    if~specialHandling&&(isempty(differences)||~ismember(paramName,differences(:,1)))

        differences=[differences;{paramName,...
        slxmlcomp.internal.convertToString(get(srcObj,paramName)),...
        slxmlcomp.internal.convertToString(get(dstObj,paramName))}];
    end


    parameterUpdater=mergeActionData.getParameterUpdater();
    slxmlcomp.internal.merge.updateNodeParameters(parameterUpdater,srcNode,differences,true,true,dstNode);
    targetChoice=mergeActionData.getFromSide();
    parameterNameToDiffMap=mergeActionData.getParameterNameToDifferenceMap();
    slxmlcomp.internal.merge.updateNodeParameters(parameterUpdater,dstNode,differences,true,true,srcNode,targetChoice,parameterNameToDiffMap);
end






function[node,message,newParent]=i_CreateNode(srcNode,newObj,dstNode)
    node=srcNode.copy();
    message='';
    newParent=[];

    dstObj=i_GetStateflowObject(dstNode);
    objParent=newObj.up;
    if objParent~=dstObj
        newParent=getParentByLookingHigherInHierarchy(objParent,dstNode);
        if isempty(newParent)
            newParent=getParentByLookingLowerInHierarchy(objParent,dstNode);
            if isempty(newParent)
                newParent=dstNode;
            end
        end
        message=slxmlcomp.internal.getMessage('slxmlcomp.merge.wrongstateflowhierarchy');
    end
end

function newParent=getParentByLookingHigherInHierarchy(objParent,dstNode)
    newParent=[];
    parent=dstNode.getParent();
    while isempty(parent.getParent())
        parent=parent.getParent();
        if objParent==i_GetStateflowObject(parent)
            newParent=parent;
            return
        end
    end
end

function newParent=getParentByLookingLowerInHierarchy(objParent,dstNode)
    import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.LightweightNodeUtils;
    newParent=[];
    descendantStack=java.util.Stack;
    descendantStack.addAll(LightweightNodeUtils.getPathAwareChildren(dstNode));
    while~descendantStack.isEmpty()
        parent=descendantStack.pop();
        if objParent==i_GetStateflowObject(parent)
            newParent=parent.getOuterDecorator();
            return
        end
        descendantStack.addAll(LightweightNodeUtils.getPathAwareChildren(parent));
    end
end


function transitionMap=i_GetAffectedTransitions(object,reportTransitions)



    transitionMap=java.util.HashMap;

    parent=object.up;
    if isempty(parent)
        return;
    end
    iterator=reportTransitions.iterator;
    while iterator.hasNext()
        repTransition=iterator.next;

        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
        transitionID=str2double(LightweightNodeUtils.getParameterValue(repTransition,'ID'));
        if isnan(transitionID)
            continue
        end

        sfTransition=parent.find('-isa','Stateflow.Transition','SSIdNumber',transitionID);
        if isempty(sfTransition)||numel(sfTransition)>1
            continue
        end


        if~isempty(sfTransition.Destination)&&sfTransition.Destination==object||...
            ~isempty(sfTransition.Source)&&sfTransition.Source==object
            transitionMap.put(transitionID,repTransition);
        end
    end
end


function[vals,names]=i_GetFilteredValues(values,filters)

    names=fieldnames(values);
    vals=struct2cell(values);

    idx=[];


    if nargin==2
        for i=1:numel(filters)
            idx=[idx;find(strcmp(names,filters(i)))];%#ok<AGROW>
        end
    end

    vals(idx)=[];
    names(idx)=[];
end


function differences=i_GetParameterDifferences(newValues,oldValues,filters)

    [newValues,names1]=i_GetFilteredValues(newValues,filters);
    [oldValues,names2]=i_GetFilteredValues(oldValues,filters);

    differences=slxmlcomp.internal.merge.getDifferences(names1,newValues,names2,oldValues);
end


function[object,objectId]=i_GetStateflowObject(node)

    node=i_GetObjectNodeFromSubStructure(node);
    path=char(node.getNodePath());
    [object,objectId]=slxmlcomp.internal.stateflow.getObject(path);
end

function node=i_GetObjectNodeFromSubStructure(node)
    switch(char(node.getTagName()))
    case 'props'
        node=node.getParent();
    case{'range','array','type','unit'}
        node=node.getParent().getParent();
    case 'fixpt'
        node=node.getParent().getParent().getParent();
    end
end



function name=i_GetTransitionConnectionName(transition,srcOrDst)
    name='';
    obj=transition.(srcOrDst);
    if~isempty(obj)
        if isa(obj,'Stateflow.Junction')
            name='junction';
        else
            name=obj.Name;
        end
    end
end


function name=i_GetTransitionDestinationName(transition)
    name=i_GetTransitionConnectionName(transition,'Destination');
end


function name=i_GetTransitionSourceName(transition)
    name=i_GetTransitionConnectionName(transition,'Source');
end


function parameters=i_ParameterSpecialCase(~,parameters)





    params={'LabelString','Script','Document','Description'};
    for i=1:numel(params)
        name=params{i};
        index=find(ismember(parameters,name));
        if~isempty(index)
            parameters{index}=[lower(name(1)),name(2:end)];
        end
    end

end


function i_UpdateTransitions(parent,transitionMap,mergeActionData)

    entrySet=transitionMap.entrySet();
    iterator=entrySet.iterator();
    while iterator.hasNext()
        entry=iterator.next();
        transitionID=entry.getKey();
        reportTransition=entry.getValue();

        transition=parent.find('-isa','Stateflow.Transition','SSIdNumber',transitionID);

        srcName=i_GetTransitionSourceName(transition);
        dstName=i_GetTransitionDestinationName(transition);

        differences=mergeActionData.getDiffSet();
        sourceSource=mergeActionData.getFromSource();
        parameterUpdater=mergeActionData.getParameterUpdater();
        difference=differences.getDifferenceForSnippet(reportTransition);
        partner=difference.getSnippet(sourceSource);
        targetChoice=mergeActionData.getFromSide();
        parameterNameToDiffMap=mergeActionData.getParameterNameToDifferenceMap();
        slxmlcomp.internal.merge.updateNodeParameter(parameterUpdater,reportTransition,'srcName',srcName,false,false,partner,targetChoice,parameterNameToDiffMap);
        slxmlcomp.internal.merge.updateNodeParameter(parameterUpdater,reportTransition,'dstName',dstName,false,false,partner,targetChoice,parameterNameToDiffMap);
    end
end


function i_UpdateTransitionSSIDs(transitionMap,srcNode,newNode,mergeActionData)

    entrySet=transitionMap.entrySet();
    iterator=entrySet.iterator();
    while iterator.hasNext()
        entry=iterator.next();
        reportTransition=entry.getValue();
        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
        transitionID=char(LightweightNodeUtils.getParameterValue(srcNode,'ID'));
        newNodeID=char(LightweightNodeUtils.getParameterValue(newNode,'ID'));

        differences=mergeActionData.getDiffSet();
        sourceSource=mergeActionData.getFromSource();
        parameterUpdater=mergeActionData.getParameterUpdater();
        difference=differences.getDifferenceForSnippet(reportTransition);
        partner=difference.getSnippet(sourceSource);
        targetChoice=mergeActionData.getFromSide();
        parameterNameToDiffMap=mergeActionData.getParameterNameToDifferenceMap();
        if strcmp(char(LightweightNodeUtils.getParameterValue(reportTransition,'srcID')),transitionID)
            slxmlcomp.internal.merge.updateNodeParameter(parameterUpdater,reportTransition,'srcMatchID',newNodeID,false,false,partner,targetChoice,parameterNameToDiffMap);
        elseif strcmp(char(LightweightNodeUtils.getParameterValue(reportTransition,'dstID')),transitionID)
            slxmlcomp.internal.merge.updateNodeParameter(parameterUpdater,reportTransition,'dstMatchID',newNodeID,false,false,partner,targetChoice,parameterNameToDiffMap);
        end
    end
end

function result=i_HandleActiveStateOutput(srcNode,srcObj,dstObj)

    if(isa(srcObj,'Stateflow.Data')&&~isempty(srcObj.OutputState))
        result=true;
        return;
    end
    if(~strcmp(char(srcNode.getTagName),'activeStateOutput'))
        result=false;
        return;
    end
    result=true;
    if(~isa(srcObj,'Stateflow.State'))

        return;
    end
    dstObj.hasOutputData=1;
    for i=1:srcNode.getParameters.size
        param=srcNode.getParameters.get(i-1);
        paramName=char(param.getName);
        paramValueString=char(param.getValue);
        switch(paramName)
        case{'activityMode','enumValueSortingMode','customName','enumTypeName','enumStorageType'}
            sf('set',dstObj.Id,['.activeStateOutput.',paramName],paramValueString);
        case{'useCustomName','useStringType','useCustomEnumTypeName','customEnumDefn'}
            sf('set',dstObj.Id,['.activeStateOutput.',paramName],str2double(paramValueString));
        otherwise
        end
    end
end

function result=isAContainer(object)
    result=isa(object,'Stateflow.State')||...
    isa(object,'Stateflow.Box')||...
    isa(object,'Stateflow.Function');
end

function debugDisplay(action,object,paramName)

    if(false)
        if(~isempty(object))
            objectClass=class(object);
            switch(objectClass)
            case{'Stateflow.State','Stateflow.Box','Stateflow.Function','Stateflow.Data'}
                objectName=object.Name;
            case{'Stateflow.Junction','Stateflow.Transition'}
                objectName=num2str(object.id);
            otherwise
                objectName='';
            end
            if(nargin<3)
                fprintf('%s %s %s\n',action,objectClass,objectName);
            else
                fprintf('%s %s:%s %s\n',action,objectClass,paramName,objectName);
            end
        else
            fprintf('%s empty\n',action);
        end
    end
end
