classdef InterfaceIOPropertySchema<Simulink.InterfaceDataPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewInportOutport');
        end
    end

    methods
        function this=InterfaceIOPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,viewType)
            props={'Simulink:studio:DataViewPerspective_Design',...
            'Simulink:studio:DataViewPerspective_Logging',...
            };
            if(slfeature('ShowComputedModelData')==3)
                props{end+1}='Simulink:studio:DataViewPerspective_Computed';
            end
            bHideCode=isequal(slfeature('ShowCodePropertiesInMDE'),0);
            if~bHideCode
                props{end+1}='Simulink:studio:DataViewPerspective_CodeGen';
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={' ',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=false;
        end
        function props=getPerInstanceProperties(~,~)
            props={};
        end
        function isVisible=isTabVisible(~,~)
            isVisible=true;
        end
        function handleHelp(~,~)
            helpview(fullfile(docroot,'simulink','helptargets.map'),'simulink_model_data');
        end

        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            if(slfeature('SLMDECompositePorts')==3)
                isHierarchical=true;
            else
                isHierarchical=false;
            end
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(obj,~,includeHidden)
            props={'Source'...
            ,'#',...
            'Signal Name',...
            };
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_Design'
                props={
                'Data Type',...
                'Min',...
                'Max',...
                'Dimensions',...
                'Complexity',...
                'Sample Time',...
                'Unit',...
                };
                props=obj.addResolveProperty(props);
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                props={};


                props=obj.addResolveProperty(props);

                props{end+1}='Storage Class';

                if slfeature('AllowSignalGrouping')>0&&...
                    slfeature('BlockParameterConfiguration')>0
                    props{end+1}='Group';
                end

                props=[props,...
                'Header File',...
                'Definition File',...
                ];

                if(slfeature('LatchingViaCSCs')>0)
                    props=[props,...
                    'Latching',...
                    ];
                end

                props=[props,...
                'Get Function',...
                'Set Function',...
                'Struct Name',...
                ];

            case 'Simulink:studio:DataViewPerspective_Logging'
                props={
                'Test Point',...
                'Log Data',...
                };
            case 'Simulink:studio:DataViewPerspective_Computed'
                props={...
                'Data Type  ',...
                'Min  ',...
                'Max  ',...
                'Dimensions  ',...
                'Complexity  ',...
                'Sample Time  ',...
                'Unit  ',...
                };
            otherwise
                props={};
            end
        end
    end

end


