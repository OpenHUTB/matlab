classdef InterfaceDataStorePropertySchema<Simulink.InterfaceDataPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewDataStores');
        end
    end

    methods
        function this=InterfaceDataStorePropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,viewType)
            props={'Simulink:studio:DataViewPerspective_Design',...
            'Simulink:studio:DataViewPerspective_Logging',...
            };
            bHideCode=isequal(slfeature('ShowCodePropertiesInMDE'),0);
            if~bHideCode
                props{end+1}='Simulink:studio:DataViewPerspective_CodeGen';
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Name',true};
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

                props{end+1}='Shared';
                props=[props,...
                'Initial Value',...
                'Data Type',...
                'Min',...
                'Max',...
                'Dimensions',...
                'Complexity',...
'Sample Time'
                ];
                props=obj.addResolveProperty(props);
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={};

                props{end+1}='Shared';

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
                props={'Log Data',...
                };
            otherwise
                props={};
            end
        end
    end

end


