classdef EditorModelListener<handle




    properties(Hidden)
        Model;
    end

    properties(Access='private')
        ModelListener;
        EditorMFModel;
        SystemComposerModel;
        EditorModelData;
        isParameterFcn=@(w)(isequal(w.widgetMetaData.isParameter,true)&&isequal(w.widgetMetaData.isPromotedParameter,false));
        isPromotedParameterFcn=@(w)isequal(w.widgetMetaData.isPromotedParameter,true);
    end

    methods
        function this=EditorModelListener(modelName,editorMFModel)

            if any(ismember(find_system('type','block_diagram'),modelName))
                this.SystemComposerModel=get_param(modelName,'SystemComposerModel');
                this.EditorMFModel=editorMFModel;
                for topElem=this.EditorMFModel.topLevelElements
                    if isa(topElem,'simulink.maskeditor.MaskEditorModel')
                        this.EditorModelData=topElem;
                        break;
                    end
                end
                this.EditorMFModel.addObservingListener(@this.transactionCommitted);
            end
        end
    end

    methods(Access='private')
        function transactionCommitted(this,changeReport)
            currentBlockPath=this.EditorModelData.context.blockFullPath;
            currentElement=this.SystemComposerModel.lookup('Path',currentBlockPath);
            if isa(currentElement,'systemcomposer.arch.BaseComponent')&&~currentElement.isReference
                currentElement=currentElement.Architecture;
            end
            for m=1:numel(changeReport.Created)
                if isa(changeReport.Created(m),'simulink.maskeditor.Widget')
                    widget=changeReport.Created(m);

                    if(widget.widgetMetaData.isParameter&&~widget.widgetMetaData.isPromotedParameter)
                        paramName=findobj(widget.properties,'id','Name').value;
                        dataType=findobj(widget.properties,'id','DataType').value;
                        value=findobj(widget.properties,'id','Value').value;
                        unit=findobj(widget.properties,'id','Unit').value;
                        dimensions=findobj(widget.properties,'id','Dimensions').value;
                        min=findobj(widget.properties,'id','Min').value;
                        max=findobj(widget.properties,'id','Max').value;
                        currentElement.addParameter(paramName,'Type',dataType,'Value',value,...
                        'Unit',unit,'Dimensions',dimensions,'Min',min,'Max',max);
                        prompt=findobj(widget.properties,'id','Prompt');
                        prompt.value=jsonencode(struct('textId',paramName,'text',paramName));
                    elseif(widget.widgetMetaData.isPromotedParameter)


                        paramName=findobj(widget.properties,'id','Name').value;
                        promotedParamName=findobj(widget.properties,'id','PromotedParametersList').value;
                        promotedParamName=eval(promotedParamName);
                        sourceComponentPath=regexprep(promotedParamName,[append("/",paramName),'$'],'','once');
                        srcCompFullPath=[currentElement.getQualifiedName,'/',char(sourceComponentPath)];
                        isModelRef=strcmpi(get_param(srcCompFullPath,'BlockType'),'ModelReference');
                        if contains(paramName,'.')&&~isModelRef
                            paramData=strsplit(promotedParamName,'.');
                            sourceComponentPath=paramData{1};
                            paramName=paramData{2};
                        end
                        try
                            currentElement.exposeParameter("Path",sourceComponentPath,"Parameter",paramName);
                        catch e
                            btStruct=warning('QUERY','backtrace');
                            warning('off','backtrace');
                            warning(e.message);
                            warning(btStruct);
                        end
                    end
                end

            end
            for n=1:numel(changeReport.Modified)
                propertyChanged=changeReport.Modified(n).Element;
                if isa(propertyChanged,'simulink.maskeditor.Property')
                    widgetChanged=findobj(this.EditorModelData.widgets.toArray,'id',propertyChanged.widgetId);
                    if widgetChanged.widgetMetaData.isPromotedParameter
                        paramName=findobj(widgetChanged.properties,'id','Name').value;
                        propName=propertyChanged.id;

                        relParameterPath=findobj(widgetChanged.properties,'id','PromotedParametersList').value;
                        promotedParamName=strrep(eval(relParameterPath),'//','/');


                        if~promotedParamName.contains('.')
                            idx=strfind(promotedParamName,'/');
                            promotedParamName=promotedParamName.replaceBetween(idx(end),idx(end),'.');
                        end
                        if strcmpi(propName,'Value')
                            currentElement.setParameterValue(promotedParamName,propertyChanged.value);
                        end
                    else
                        paramName=findobj(widgetChanged.properties,'id','Name').value;
                        propName=propertyChanged.id;
                        if strcmpi(propName,'Name')
                            currParamName=changeReport.getOldValue(propertyChanged,changeReport.Modified(n).ModifiedProperties);
                        end
                        newVal=propertyChanged.value;
                        if isa(currentElement,'systemcomposer.arch.Architecture')
                            try
                                paramDef=currentElement.getParameterDefinition(paramName);
                                if strcmp(propName,'Type')
                                    paramDef.DataType=newVal;
                                elseif strcmp(propName,'Name')
                                    paramDef=currentElement.getParameterDefinition(currParamName);
                                    paramDef.setName(paramName)
                                elseif strcmp(propName,'Value')
                                    if~isempty(newVal)&&isempty(eval(newVal))
                                        newVal='';
                                    end
                                    systemcomposer.internal.parameters.arch.sync.updateSimulinkParameter(currentElement.SimulinkHandle,paramName,propName,newVal);
                                else
                                    paramDef.set(propName,newVal);
                                end
                                prompt=findobj(widgetChanged.properties,'id','Prompt');
                                prompt.value=jsonencode(struct('textId',paramName,'text',paramName));
                            catch exp


                                currVal=changeReport.getOldValue(propertyChanged,changeReport.Modified(n).ModifiedProperties);
                                prop=findobj(widgetChanged.properties,'id',propertyChanged.id);
                                prop.value=currVal;
                            end
                        end
                    end
                end
            end

            if~isempty(changeReport.Destroyed)
                allParamsOnElem=currentElement.getParameterNames;
                allWidgetParams=this.getAllParameterNames;
                nonExistingParams=setdiff(allParamsOnElem,allWidgetParams);
                for i=1:numel(nonExistingParams)
                    paramName=nonExistingParams(i);
                    if~paramName.contains(".")
                        currentElement.removeParameter(paramName);
                    else


                        srcComp=currentElement.getImpl.getComponentPromotedFrom(paramName);
                        relBlockPath=strrep(srcComp.getQualifiedName,[currentElement.getImpl.getQualifiedName,'/'],'');
                        paramName=strrep(paramName,[relBlockPath,'.'],'');
                        currentElement.unexposeParameter('Path',relBlockPath,'Parameters',paramName)
                    end
                end
            end

        end

        function[paramWidgets,promotedParamWidgets]=getAllParameterWidgets(this)
            allWidgets=this.EditorModelData.widgets.toArray;
            paramIdx=arrayfun(@(w)this.isParameterFcn(w),allWidgets);
            promoteParamIdx=arrayfun(@(w)this.isPromotedParameterFcn(w),allWidgets);
            paramWidgets=allWidgets(paramIdx);
            promotedParamWidgets=allWidgets(promoteParamIdx);
        end

        function paramNames=getAllParameterNames(this)
            paramNames=string.empty;
            [paramWidgets,promotedParamWidgets]=this.getAllParameterWidgets;
            if isempty(paramWidgets)&&isempty(promotedParamWidgets)
                return;
            end
            for widget=paramWidgets
                nameProp=findobj(widget.properties,'id','Name');
                paramNames=[paramNames,string(nameProp.value)];%#ok<AGROW> 
            end

            for widget=promotedParamWidgets
                promotedProp=findobj(widget.properties,'id','PromotedParametersList');
                paramName=char(eval(promotedProp.value));
                idx=strfind(paramName,'/');
                paramName=strrep(paramName,paramName(idx(end)),'.');
                paramNames=[paramNames,paramName];%#ok<AGROW>
            end

        end
    end
end
