classdef InterfaceSignalPropertySchema<Simulink.InterfaceDataPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewSignals');
        end
    end

    methods
        function this=InterfaceSignalPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={};
            if(slfeature('ShowSignalDesignPropsOnMDE')>0)
                props{end+1}='Simulink:studio:DataViewPerspective_Design';
            end
            props{end+1}='Simulink:studio:DataViewPerspective_Logging';
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
            defaultSort={'Source',true};
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

        function props=getCommonProperties(obj,~,includeHidden)
            props={'Source',...
            'Name',...
            };
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_Design'

                props={};
                props=[props,...
                'Data Type',...
                'Min',...
                'Max',...
                'Dimensions',...
                'Complexity',...
                'Sample Time',...
                'Unit',...
                ];
                props=obj.addResolveProperty(props);
            case 'Simulink:studio:DataViewPerspective_CodeGen'

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
...
                'Get Function',...
                'Set Function',...
                'Struct Name',...
                ];
            case 'Simulink:studio:DataViewPerspective_Logging'
                if slfeature('ShowSDITolerancesOnMDE')
                    props={'Test Point',...
                    'Log Data',...
                    'Absolute Tolerance',...
                    'Relative Tolerance',...
                    };
                else
                    props={'Test Point',...
                    'Log Data',...
                    };
                end

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


