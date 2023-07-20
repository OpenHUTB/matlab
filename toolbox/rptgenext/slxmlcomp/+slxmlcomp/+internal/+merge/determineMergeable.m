function determineMergeable(node,modelFile,logger,parameterList)






















    prevState=warning('off');
    warnCleanup=onCleanup(@()warning(prevState));

    import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.LightweightNodeUtils;
    nodeTypeNode=LightweightNodeUtils.getNodeTypeNode(node);
    type=char(nodeTypeNode.getNodeType());


    nodeTypes={'Comment','DefaultType','data'};
    if find(ismember(nodeTypes,type)==1)
        return
    end


    import slxmlcomp.internal.highlight.window.BDInfo
    bdInfo=BDInfo.fromDetermineMergeableNode(node,modelFile);
    bdInfo.ensureLoaded();


    checkType=i_GetType(type);

    nodePath=char(node.getNodePath());

    try
        [~,name]=fileparts(modelFile);
        switch checkType
        case 'Stateflow'
            i_DetermineStateflowParameters(nodePath,parameterList);
        case 'Simulink'
            i_DetermineSimulinkParameters(type,name,node,nodePath,parameterList);
        otherwise
            i_DetermineStateflowParameters(nodePath,parameterList);
            i_DetermineSimulinkParameters(type,name,node,nodePath,parameterList,true);
        end
    catch E
        logger.log(java.util.logging.Level.FINE,E.getReport());
    end


    slxmlcomp.internal.merge.ParameterMergeOverride.doParameterOverride(parameterList);
end







function i_DetermineSimulinkParameters(type,modelName,node,nodePath,parameterList,ignoreError)
    if nargin<6
        ignoreError=false;
    end

    switch type
    case{'Line','Branch'}
        handle=slxmlcomp.internal.line.getLineUnique(...
        slxmlcomp.internal.line.linePathToStruct(nodePath)...
        );
    case{'Annotation'}
        handle=slxmlcomp.internal.annotation.find(...
        slxmlcomp.internal.annotation.highlightPathToStruct(nodePath)...
        );
    otherwise
        handle=nodePath;
    end
    try
        objectParameters=get_param(handle,'ObjectParameters');
    catch E %#ok<NASGU>
        return
    end
    iterator=parameterList.iterator();
    while iterator.hasNext()
        paramObj=iterator.next();
        result=0;
        try
            name=getParamName(paramObj);

            if i_IsSpecialSimulinkCase(type,modelName,nodePath,name)
                paramObj.setMergeable(result);
                continue
            end

            if strcmp(type,'Mask')
                name=['Mask',name];%#ok<AGROW>
            end

            if isfield(objectParameters,name)
                param=objectParameters.(name);
                result=isempty(find(ismember(param.Attributes,{'read-only'})==1,1));
                paramObj.setMergeable(result);
            elseif "UserParameters"==string(node.getTagName())
                paramObj.setMergeable(true);
            else
                if~ignoreError
                    paramObj.setMergeable(0);
                end
            end
        catch E %#ok<NASGU>
            if~ignoreError
                paramObj.setMergeable(0);
            end
        end

    end
end


function result=i_IsSpecialSimulinkCase(type,modelName,path,paramName)



    if "CustomSymbolStrFcn"==paramName||"LastModifiedBy"==paramName
        result=true;
        return
    end



    if strcmp('Annotation',type)&&strcmp('Interpreter',paramName)
        result=true;
        return;
    end


    modelParams={'Name'};
    if strcmp(modelName,path)&&~isempty(find(ismember(modelParams,paramName)==1,1))
        result=true;
        return
    end

    result=false;
end







function i_DetermineStateflowParameters(nodePath,parameterList)


    sfObject=slxmlcomp.internal.stateflow.getObject(nodePath);

    if isempty(sfObject)
        return
    end


    iterator=parameterList.iterator();
    while iterator.hasNext()
        paramObj=iterator.next();
        propertyName=getParamName(paramObj);

        result=~sfObject.isReadonlyProperty(propertyName);



        switch(propertyName)
        case 'executionOrder'
            if(isa(sfObject,'Stateflow.Transition')||isa(sfObject,'Stateflow.State'))
                result=sfObject.chart.UserSpecifiedStateTransitionExecutionOrder;
            end
        case 'position'
            if(isa(sfObject,'Stateflow.Junction'))
                result=true;
            end
        case{'minimum','maximum','range','resolveToSignalObject','updateMethod','initialValue',...
            'complexity','size','firstIndex','isDynamic','method',...
            'primitive','expression','busObject','enumType',...
            'scalingMode','fractionLength','slope','bias','unit'}
            if(isa(sfObject,'Stateflow.Data'))
                result=true;
            end
        case{'allowGlobalAccessToExportedFunctions','exportChartFunctions','actionLanguage','saturateOnIntegerOverflow'}
            result=true;
        end
        paramObj.setMergeable(result);
    end
end

function name=getParamName(paramObj)
    name=paramObj.getName();
    if~ischar(name)


        name=char(name);
    end
end







function result=i_GetType(type)

    switch type
    case{'Transition','Junction','MatlabFunction',...
        'predicateArray','actionArray','Data','Event','Message','props'}
        result='Stateflow';
    case{'Chart','State'}
        result='Both';
    otherwise
        result='Simulink';
    end
end
