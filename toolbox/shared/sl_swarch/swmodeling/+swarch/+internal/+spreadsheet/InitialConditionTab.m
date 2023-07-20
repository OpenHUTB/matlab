classdef InitialConditionTab<swarch.internal.spreadsheet.AbstractSoftwareModelingTab




    methods
        function this=InitialConditionTab(spreadSheetObj)
            this=this@swarch.internal.spreadsheet.AbstractSoftwareModelingTab(spreadSheetObj);
        end

        function columns=getColumnNames(~)
            columns={...
            getString(message('SoftwareArchitecture:ArchEditor:SoftwareComponentColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:PortColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:InitialConditionColumn'))};
        end

        function tabName=getTabName(~)
            tabName=getString(message('SoftwareArchitecture:ArchEditor:InitialConditionTabName'));
        end

        function refreshChildren(this)
            swComponents=swarch.utils.getAllSoftwareComponents(this.getRootArchitecture());
            children=[];


            for swComp=swComponents
                children=[children,this.getInitialConditionsOfComponent(swComp)];%#ok<AGROW>
            end
            this.pChildren=children;
        end
    end

    methods(Access=private)
        function ics=getInitialConditionsOfComponent(this,currSwComponent)
            ics=[];
            if currSwComponent.isImplComponent()
                for port=currSwComponent.getPorts()
                    ics=[ics...
                    ,swarch.internal.spreadsheet.InitialConditionDataSource(this,port)];%#ok<AGROW>
                end
            end
        end
    end
end


