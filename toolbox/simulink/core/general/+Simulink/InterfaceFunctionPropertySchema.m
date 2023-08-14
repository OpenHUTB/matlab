classdef InterfaceFunctionPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:EntryPointFunctions');
        end
    end

    methods
        function this=InterfaceFunctionPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={'Simulink:studio:DataViewPerspective_CodeGen'...
            };
            if slfeature('MapPartitionsToMultiCore')>0
                props{end+1}='Simulink:studio:DataViewPerspective_Deployment';
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Source',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,perspective)
            needsRefresh=false;
            if strcmp(perspective,DAStudio.message('Simulink:studio:DataViewPerspective_CodeGen'))
                needsRefresh=true;
            end
        end
        function isVisible=isTabVisible(obj,bd)%#ok<INUSL>
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(bd.Handle);
            if strcmp(mappingType,'AutosarTargetCPP')
                isVisible=true;
            elseif(strcmp(mappingType,'AutosarTarget')&&~isempty(modelMapping)&&~modelMapping.IsSubComponent)...
                ||strcmp(mappingType,'CoderDictionary')...
                ||(strcmp(mappingType,'CppModelMapping')&&...
                modelMapping.DeploymentType=="Unset"||...
                modelMapping.DeploymentType=="Component"||...
                modelMapping.DeploymentType=="Subcomponent")
                isVisible=true;
            else
                isVisible=false;
            end
        end

        function toolTip=propertyTooltip(~,prop)
            if strcmp(prop,DAStudio.message('coderdictionary:mapping:RunnableSwAddrMethodColumnName'))
                toolTip=DAStudio.message('coderdictionary:mapping:SwAddrMethodForRunnableTooltip');
            elseif strcmp(prop,DAStudio.message('coderdictionary:mapping:InternalDataSwAddrMethodColumnName'))
                toolTip=DAStudio.message('coderdictionary:mapping:SwAddrMethodForInternalDataTooltip');
            elseif strcmp(prop,'Simulink:studio:DataViewPerspective_CodeGen')
                toolTip=DAStudio.message('Simulink:studio:DataViewPerspective_CodeGen');
            else
                toolTip=prop;
            end
        end

        function out=needsRefresh(~,eventData)
            if(contains(eventData.EventName,'EPFMappingEntity'))
                out=true;
            else
                out=false;
            end
        end

        function handleHelp(obj,~)
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                model=bdroot(obj.Source.getForwardedObject.Handle);
            end
            [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if any(strcmp(mappingType,{'AutosarTarget','AutosarTargetCPP'}))
                helpview(fullfile(docroot,'autosar','helptargets.map'),'autosar_code_mappings');
            elseif strcmp(mappingType,'CoderDictionary')
                helpview(fullfile(docroot,'ecoder','helptargets.map'),'code_mappings');
            elseif strcmp(mappingType,'CppModelMapping')
                helpview(fullfile(docroot,'ecoder','helptargets.map'),'cpp_code_mappings_function');
            end
        end

    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,~)
            props={'Source'};
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={};
                [modelMapping,mappingType]=obj.getCurrentMapping();
                if strcmp(mappingType,'AutosarTarget')
                    props{end+1}='Runnable';
                    if~isa(obj.Source,'DataView')

                        props{end+1}=DAStudio.message('coderdictionary:mapping:RunnableSwAddrMethodColumnName');
                        props{end+1}=DAStudio.message('coderdictionary:mapping:InternalDataSwAddrMethodColumnName');
                    end
                elseif strcmp(mappingType,'AutosarTargetCPP')
                    mc=metaclass(Simulink.AutosarTarget.PortMethod);
                    for ii=1:numel(mc.PropertyList)
                        prop=mc.PropertyList(ii);
                        if strcmp(prop.GetAccess,'public')&&~prop.Hidden
                            props{end+1}=prop.Name;%#ok<AGROW>
                        end
                    end


                    props=setdiff(props,'Timeout','stable');
                    if slfeature('AUTOSARMethodsFireAndForgetMapping')
                        props{end+1}='FireAndForget';
                    end
                elseif strcmp(mappingType,'CoderDictionary')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:FunctionClassColumnName');
                    props{end+1}=DAStudio.message('coderdictionary:mapping:FunctionNameColumnName');
                    props{end+1}=DAStudio.message('coderdictionary:mapping:FunctionPreviewColumnName');
                    if~isa(obj.Source,'DataView')

                        if~modelMapping.isFunctionPlatform
                            props{end+1}=...
                            DAStudio.message('coderdictionary:mapping:MemorySectionColumnName');
                            if slfeature('InternalDataMemorySectionInCMapping')>0
                                props{end+1}=...
                                DAStudio.message('coderdictionary:mapping:InternalDataMemorySectionColumnName');
                            end
                        end
                        if(slfeature('TimingServicesInCodeGen')&&...
                            modelMapping.isFunctionPlatform)&&...
                            isequal(modelMapping.DeploymentType,'Component')
                            props{end+1}=DAStudio.message('coderdictionary:mapping:TimerServiceColumnName');
                        end
                    end
                elseif strcmp(mappingType,'CppModelMapping')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:CppMethodNameColumnName');
                    props{end+1}=DAStudio.message('coderdictionary:mapping:CppMethodPreviewColumnName');
                end
                if isa(obj.Source,'DataView')&&...
                    (strcmp(mappingType,'CoderDictionary')||strcmp(mappingType,'AutosarTarget'))

                    props{end+1}=obj.mappingInspectorColumnName;
                end
            case 'Simulink:studio:DataViewPerspective_Deployment'
                props={};
                if~isa(obj.Source,'DataView')

                    model=bdroot(obj.Source.getForwardedObject.Handle);
                    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                    if strcmp(mappingType,'CoderDictionary')
                        if slfeature('MapPartitionsToMultiCore')>0
                            props{end+1}=DAStudio.message('coderdictionary:mapping:ExecutionCoreColumnName');
                        end
                    end
                end
            otherwise
                props={};
            end
        end
    end

    methods(Access=private)
        function[modelMapping,mappingType]=getCurrentMapping(obj)
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                model=bdroot(obj.Source.getForwardedObject.Handle);
            end
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
        end
    end

end


