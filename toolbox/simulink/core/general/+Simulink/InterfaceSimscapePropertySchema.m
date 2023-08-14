classdef InterfaceSimscapePropertySchema<Simulink.InterfaceDataPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewSimscape');
        end
    end

    methods
        function this=InterfaceSimscapePropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={'Simulink:studio:DataViewPerspective_Design'};
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Block',true};
        end
        function isVisible=isTabVisible(~,currentSystem)
            isVisible=false;
            if slfeature('SimscapeDataEditor')>0
                mdl=currentSystem;
                while~isa(mdl,'Simulink.BlockDiagram')
                    mdl=mdl.getParent;
                end

                cs=getActiveConfigSet(mdl);
                if~isempty(cs)
                    isVisible=~isempty(cs.getComponent('Simscape'));
                end
            end
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,~)
            props={'Block',...
            'Parameter',...
            };
        end
        function props=getPerspectiveProperties(~,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_Design'
                props={'Value',...
                'Unit',...
                };
            otherwise
                props={};
            end
        end
    end

end

