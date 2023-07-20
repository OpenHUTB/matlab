classdef InterfaceStatePropertySchema<Simulink.InterfaceDataPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewStates');
        end
    end

    methods
        function this=InterfaceStatePropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,viewType)
            props={'Simulink:studio:DataViewPerspective_Design'};
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
            props={'Source'};
            props{end+1}='Name';
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_Design'
                props={'Initial Value'};
                props=obj.addResolveProperty(props);
                if slfeature('StateRWForModelBlocks')>0&&slfeature('StateRWForMaskedSubsystem')<2
                    props{end+1}='Public';
                    props{end+1}='Public Name';
                end
                if slfeature('StateRWForMaskedSubsystem')==1
                    props{end+1}='Promote To Parent Subsystem';
                elseif slfeature('StateRWForMaskedSubsystem')==2
                    props{end+1}='Promoted To';
                end
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={};
                props=obj.addResolveProperty(props);
                props=[props,...
                'Storage Class',...
                'Header File',...
'Definition File'
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
            otherwise
                props={};
            end
        end
    end
end



