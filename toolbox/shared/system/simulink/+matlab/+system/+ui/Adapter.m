classdef Adapter<handle




    properties(Access=protected)
DialogParameterProperties
PropertyNameToParameterName
    end

    methods
        function obj=Adapter(systemName)

            paramMap=struct();
            nameMap=struct();

            groups=matlab.system.display.internal.Memoizer.getBlockPropertyGroups(systemName,...
            'DefaultIfError',true);
            dialogProps=matlab.system.ui.getPropertyList(systemName,groups);
            for propInd=1:numel(dialogProps)
                property=dialogProps(propInd);
                paramMap.(property.BlockParameterName)=property;
                nameMap.(property.Name)=property.BlockParameterName;
            end
            obj.DialogParameterProperties=paramMap;
            obj.PropertyNameToParameterName=nameMap;
        end

        function sysObj=set(obj,sysObj,paramName,v)

            sysObj=obj.DialogParameterProperties.(paramName).setValue(sysObj,v);
        end

        function v=get(obj,sysObj,paramName)


            v=obj.DialogParameterProperties.(paramName).getValue(sysObj);
        end

        function v=isVisible(obj,sysObj,paramName)


            v=obj.DialogParameterProperties.(paramName).isVisible(sysObj);
        end

        function v=isActive(obj,sysObj,paramName)


            v=obj.DialogParameterProperties.(paramName).isActive(sysObj);
        end

        function vis=updateVisibilityForDataTypesTablePanel(obj,maskObj,controls)
            vis='off';
            for i=1:length(controls)
                if isa(controls(i),'Simulink.dialog.parameter.Control')
                    param=maskObj.getParameter(controls(i).Name);
                    if strcmp(param.Visible,'on')
                        vis='on';
                        break;
                    end
                end
            end
        end

        function updateVisibilityOfDataTypeControl(obj,hBlock,maskObject,controlName,visibility)
            dlgControl=maskObject.getDialogControl(controlName);
            if~isempty(dlgControl)
                preserve_dirty=Simulink.PreserveDirtyFlag(bdroot(hBlock),'blockDiagram');%#ok<NASGU>
                dlgControl.Visible=visibility;
            end
        end


        function updateAttributes(obj,hBlock,sysObj,paramNames)










            matlab.system.ui.ImplementSystemObjectUsingMask.registerBlock(hBlock);


            maskObject=matlab.system.ui.SimulinkDescriptor.getBlockMaskObject(hBlock);
            for pInd=1:numel(paramNames)
                paramName=paramNames{pInd};

                maskParam=maskObject.getParameter(paramName);


                if strcmpi(maskParam.Hidden,'off')
                    if obj.isVisible(sysObj,paramName)
                        vis='on';
                    else
                        vis='off';
                    end


                    if strcmp(paramName,"LockScale")&&~matlab.system.ui.hasOwnAutoscaler(hBlock)
                        vis='off';
                    end
                    maskParam.Visible=vis;
                    if contains(paramName,"DataTypeStr")
                        updateVisibilityOfDataTypeControl(obj,hBlock,maskObject,[paramName,'Label'],vis);
                        updateVisibilityOfDataTypeControl(obj,hBlock,maskObject,[paramName,'MinLabel'],vis);
                        updateVisibilityOfDataTypeControl(obj,hBlock,maskObject,[paramName,'MaxLabel'],vis);
                    end
                end

                updateDependentPopups(obj,hBlock,sysObj,paramName);
            end

            systemName=get_param(hBlock,'System');
            filepath=which(systemName);
            xmlFilePath=[filepath(1:end-2),'_mask','.xml'];
            if~isfile(xmlFilePath)
                dialogControls=maskObject.getDialogControls;
                for i=1:numel(dialogControls)
                    vis=updateContainerVisibility(obj,hBlock,dialogControls(i));
                    if isprop(dialogControls(i),'Visible')
                        if~strcmp(dialogControls(i).Visible,vis)
                            preserve_dirty=Simulink.PreserveDirtyFlag(bdroot(hBlock),'blockDiagram');%#ok<NASGU>
                            dialogControls(i).Visible=vis;
                        end
                    else
                        param=maskObject.getParameter(dialogControls(i).Name);
                        param.Visible=vis;
                    end
                end
            end


            if sysObj.showFiSettings(class(sysObj))
                inputFimathParam=maskObject.getParameter('InputFimath');


                if strcmp(get_param(hBlock,'BlockDefaultFimath'),'Specify Other')
                    inputFimathParam.Enabled='on';
                else
                    inputFimathParam.Enabled='off';
                end
            end


            matlab.system.ui.ImplementSystemObjectUsingMask.updateActionsEnabled(hBlock);
        end

        function vis=updateContainerVisibility(obj,hBlock,dialogControl)
            maskObj=matlab.system.ui.SimulinkDescriptor.getBlockMaskObject(hBlock);
            if~isprop(dialogControl,'DialogControls')
                if isprop(dialogControl,'Visible')
                    vis=dialogControl.Visible;
                else
                    param=maskObj.getParameter(dialogControl.Name);
                    vis=param.Visible;
                end
            else
                Controls=dialogControl.DialogControls;
                vis=dialogControl.Visible;
                if~isempty(Controls)
                    if strcmp(dialogControl.Name,'TypesTablePanel')
                        vis=updateVisibilityForDataTypesTablePanel(obj,maskObj,Controls);
                    else
                        visible={};
                        for j=1:numel(Controls)
                            visible{end+1}=updateContainerVisibility(obj,hBlock,Controls(j));
                        end
                        vis='off';
                        for k=1:length(visible)
                            if strcmp(visible(k),'on')
                                vis='on';
                                break;
                            end
                        end
                    end
                    if~strcmp(dialogControl.Visible,vis)
                        preserve_dirty=Simulink.PreserveDirtyFlag(bdroot(hBlock),'blockDiagram');%#ok<NASGU>
                        dialogControl.Visible=vis;
                    end
                end
            end
        end

        function failed=initializeDynamicMaskParameters(obj,sysObj,maskObject,paramNames,paramValues)


            parametersToSet=dynamicPopupParameterSearch(obj,paramNames);
            failed={};
            for n=1:numel(parametersToSet)
                paramName=parametersToSet{n};

                property=obj.DialogParameterProperties.(paramName);

                idx=strcmp(paramNames,paramName);
                parameterValue=paramValues{idx};

                try







                    maskParam=maskObject.getParameter(paramName);

                    if~property.IsEnumerationDynamic

                        if property.IsLogical
                            propertyValue=parameterValue=="on";
                        else

                            propertyValue=parameterValue;
                        end
                        set(obj,sysObj,paramName,propertyValue);
                        maskParam.Value=parameterValue;
                    else

                        set(obj,sysObj,paramName,parameterValue);

                        allMembers=property.StringSetValues;
                        activeMembers=allMembers(getActiveEnumerationMemberIndices(sysObj,paramName));
                        assert(any(strcmp(activeMembers,parameterValue)));

                        maskParam.TypeOptions=activeMembers;
                        maskParam.Value=parameterValue;
                    end
                catch
                    failed=unique([failed,paramName]);
                end
            end
        end

        function v=getCodegenScriptType(obj,sysObj,paramName)


            v=obj.DialogParameterProperties.(paramName).getCodegenScriptType(sysObj);
        end

        function v=getConstructorString(obj,sysObj,paramNames)

            systemName=class(sysObj);

            builder=matlab.system.ui.ConstructorBuilder(systemName);


            builder.addLiteralParameterValue('isInMATLABSystemBlock','true');




            numIn=getNumInputs(sysObj);
            numOut=getNumOutputs(sysObj);
            if(numIn>0)||(numOut>0)
                sts=sysObj.getSampleTime();
                builder.addLiteralParameterValue('sampleTimeType',...
                ['''',sts.Type,'''']);

                stIsSingle=strcmp(class(sts.SampleTime),'single');
                if(stIsSingle)
                    builder.addLiteralParameterValue('sampleTime',...
                    ['single(',num2str(sts.SampleTime,'%22.18g\n'),')']);
                    builder.addLiteralParameterValue('offsetTime',...
                    ['single(',num2str(sts.OffsetTime,'%22.18g\n'),')']);
                    builder.addLiteralParameterValue('sampleTimeClassIsSingle','true');
                else
                    builder.addLiteralParameterValue('sampleTime',...
                    num2str(sts.SampleTime,'%22.18g\n'));
                    builder.addLiteralParameterValue('offsetTime',...
                    num2str(sts.OffsetTime,'%22.18g\n'));
                    builder.addLiteralParameterValue('sampleTimeClassIsSingle','false');
                end

                if strcmp(sts.Type,'Controllable')


                    builder.addLiteralParameterValue('sampleTime',...
                    num2str(sts.TickTime,'%22.18g\n'));
                    builder.addLiteralParameterValue('offsetTime',...
                    num2str(-20,'%22.18g\n'));
                elseif strcmp(sts.Type,'Fixed In Minor Step')
                    builder.addLiteralParameterValue('sampleTime','0');
                    builder.addLiteralParameterValue('offsetTime','1');
                end
            end

            builder.addLiteralParameterValue('fxpDataTypeOverride',...
            num2str(sysObj.getFixptDataTypeOverride()));
            builder.addLiteralParameterValue('fxpDataTypeOverrideAppliesTo',...
            num2str(sysObj.getFixptDataTypeOverrideAppliesTo()));



            numIn=getNumInputs(sysObj);
            if numIn>0
                szStr='{';
                for idx=1:numIn
                    szStr=[szStr,mat2str(sysObj.getPropagatedInputSize(idx))];%#ok<AGROW>
                    if idx<numIn
                        szStr=[szStr,','];%#ok<AGROW>
                    end
                end
                szStr=[szStr,'}'];
                builder.addLiteralParameterValue('propInputSize',szStr);
            end


            paramNames=addDynamicPopupDependents(obj,paramNames);
            for pInd=1:numel(paramNames)
                paramName=paramNames{pInd};
                obj.DialogParameterProperties.(paramName).addParameterValue(sysObj,builder);
            end
            v=builder.build();
        end
    end

    methods(Access=private)
        function updateDependentPopups(obj,hBlock,sysObj,paramName)


            property=obj.DialogParameterProperties.(paramName);
            if property.IsControllingAnEnumeration
                maskObject=matlab.system.ui.SimulinkDescriptor.getBlockMaskObject(hBlock);
                maskParam=maskObject.getParameter(paramName);





                if property.IsLogical
                    if get(obj,sysObj,paramName)
                        maskParam.Value='on';
                    else
                        maskParam.Value='off';
                    end
                elseif property.IsEnumeration
                    maskParam.Value=get(obj,sysObj,paramName);
                end

                parametersToUpdate=property.ControlledPropertyList;

                for n=1:numel(parametersToUpdate)
                    updatePropertyName=parametersToUpdate{n};


                    updateParameterName=obj.PropertyNameToParameterName.(updatePropertyName);

                    updateProperty=obj.DialogParameterProperties.(updateParameterName);
                    updateParam=maskObject.getParameter(updateParameterName);
                    allMembers=updateProperty.StringSetValues;
                    activeMembers=allMembers(getActiveEnumerationMemberIndices(sysObj,updatePropertyName));











                    if~isequal(updateParam.TypeOptions,activeMembers)

                        updateParam.TypeOptions=activeMembers;


                        dialog=getDialogHandle(maskObject);
                        if~isempty(dialog)
                            updateParam.Value=activeMembers{1};


                            set(obj,sysObj,updateParameterName,activeMembers{1});

                            block=get_param(hBlock,'Object');
                            dialogSource=getDialogSource(block);
                            slSetEnumMaskDialogValue(dialogSource,...
                            block,...
                            0,...
                            find(updateParam==maskObject.Parameters)-1);
                        end
                    end
                end
            end
        end

        function paramNames=addDynamicPopupDependents(obj,paramNames)









            extraParams=dynamicPopupParameterSearch(obj,paramNames);


            paramNames=unique([paramNames,extraParams],'stable');
        end

        function paramNames=dynamicPopupParameterSearch(obj,startNames)





            paramNames={};



            paramsToSearch=string(startNames(:));
            searchIndex=1;



            doSort=false;

            while numel(paramsToSearch)>=searchIndex
                paramName=paramsToSearch{searchIndex};
                searchIndex=searchIndex+1;

                prop=obj.DialogParameterProperties.(paramName);

                if prop.IsControllingAnEnumeration
                    if~doSort
                        propGraph=digraph;
                        doSort=true;
                    end


                    controlledParameterList=prop.ControlledPropertyList;
                    for n=1:numel(controlledParameterList)
                        controlledParameterList{n}=obj.PropertyNameToParameterName.(controlledParameterList{n});
                    end


                    paramsToSearch=unique([paramsToSearch;controlledParameterList],'stable');


                    for n=1:numel(controlledParameterList)
                        propGraph=addedge(propGraph,prop.BlockParameterName,controlledParameterList{n});
                    end
                end
            end

            if doSort
                sortIdx=toposort(propGraph);

                paramNames=propGraph.Nodes(sortIdx,1).Name';
            end
        end
    end
end
