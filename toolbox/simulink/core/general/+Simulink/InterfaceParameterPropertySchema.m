classdef InterfaceParameterPropertySchema<Simulink.InterfaceDataPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewParameters');
        end
    end

    methods
        function this=InterfaceParameterPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,viewType)
            props={'Simulink:studio:DataViewPerspective_Design'};
            bHideCode=isequal(slfeature('ShowCodePropertiesInMDE'),0);

            if(~bHideCode)
                props{end+1}='Simulink:studio:DataViewPerspective_CodeGen';
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Source',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=false;
        end

        function props=getPerInstanceProperties(obj,perspective)
            props={};
            if slfeature('ModelOwnedDataIM')<1
                return;
            end
            if isequal(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                if isa(obj.Source,'DataView')
                    return;
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                if((~strcmp(obj.Source.getDisplayClass,'Simulink.Parameter')&&...
                    ~strcmp(obj.Source.getDisplayClass,'Simulink.LookupTable')&&...
                    ~strcmp(obj.Source.getDisplayClass,'Simulink.Breakpoint'))||...
                    ~isValidProperty(obj.Source,'StorageClass'))
                    return;
                end
                [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                if~isempty(modelMapping)&&strcmp(mappingType,'CoderDictionary')
                    paramName=obj.Source.getPropValue('Name');
                    mappedParam=modelMapping.ModelScopedParameters.findobj('Parameter',paramName);
                    if~isempty(mappedParam)&&~isempty(mappedParam.MappedTo)
                        props=mappedParam.MappedTo.getCSCAttributeNames(model)';
                    end
                end
            end
        end

        function isVisible=isTabVisible(~,~)
            isVisible=true;
        end

        function handleHelp(~,~)
            helpview(fullfile(docroot,'simulink','helptargets.map'),'simulink_model_data');
        end
        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            if(slfeature('HierarchicalViewInMDE')>0)
                isHierarchical=true;
            else
                isHierarchical=false;
            end
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,~)
            if(slfeature('BlockParameterConfiguration')==2)
                props={'Source',...
                'Name',...
                'Definition',...
                };
            elseif(slfeature('BlockParameterConfiguration')>=3)
                props={'Source',...
                };
            else
                props={'Source',...
                'Name',...
                };
            end
        end

        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_Design'
                if(slfeature('BlockParameterConfiguration')<=1)
                    props={'Value',...
                    'Data Type',...
                    'Min',...
                    'Max',...
                    'Dimensions',...
                    'Unit',...
                    'Argument',...
                    };
                elseif(slfeature('BlockParameterConfiguration')>=2)
                    props={'Value',...
                    'ValueSource',...
                    'Data Type',...
                    'Min',...
                    'Max',...
                    'Dimensions',...
                    'Unit',...
                    'Argument',...
                    'ArgumentName',...
                    };
                end

            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={'Argument',...
                'Storage Class',...
                'Header File',...
                'Definition File',...
                'Get Function',...
                'Set Function',...
                'Struct Name',...
                };

                if(slfeature('ModelOwnedDataIM')>0)
                    if isa(obj.Source,'DataView')
                        return;
                    else
                        model=bdroot(obj.Source.getForwardedObject.Handle);
                    end
                    [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                    if~isempty(modelMapping)
                        paramName=obj.Source.getPropValue('Name');
                        mappedParam=modelMapping.ModelScopedParameters.findobj('Parameter',paramName);
                        if~isempty(mappedParam)&&strcmp(mappingType,'CoderDictionary')
                            props={'Argument',...
                            DAStudio.message('coderdictionary:mapping:StorageClassColumnName')};
                        end
                    end
                end

            otherwise
                props={};
            end
        end

        function hiddenProps=getHiddenProps(obj,perspective,props)
            hiddenProps={};
            if isequal(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                if(slfeature('ModelOwnedDataIM')>0)
                    if isa(obj.Source,'DataView')
                        return;
                    else
                        model=bdroot(obj.Source.getForwardedObject.Handle);
                    end
                    [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                    if~isempty(modelMapping)
                        paramName=obj.Source.getPropValue('Name');
                        mappedParam=modelMapping.ModelScopedParameters.findobj('Parameter',paramName);
                        if~isempty(mappedParam)
                            return;
                        end
                    end
                end
            end
            hiddenProps=getHiddenProps@Simulink.InterfaceDataPropertySchema(obj,perspective,props);
        end

    end

end


