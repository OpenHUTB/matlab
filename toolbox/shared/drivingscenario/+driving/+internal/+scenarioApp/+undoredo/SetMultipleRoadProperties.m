classdef SetMultipleRoadProperties<driving.internal.scenarioApp.undoredo.SetRoadProperty

    methods
        function this=SetMultipleRoadProperties(hApp,spec,propNames,newValues,oldValues)




            if nargin<5
                oldValues=cell(1,numel(propNames));
                for indx=1:numel(propNames)
                    oldValues{indx}=spec.(propNames{indx});
                end
            end
            this@driving.internal.scenarioApp.undoredo.SetRoadProperty(...
            hApp,spec,propNames,newValues,oldValues);
        end

        function execute(this)
            propNames=this.Property;
            newValues=this.NewValue;
            roadSpec=this.Object;


            for indx=1:numel(propNames)
                roadSpec.(propNames{indx})=newValues{indx};
            end
            this.Application.Sim3dScene='';
            try
                updateScenario(this);
            catch ME



                oldValues=this.OldValue;
                for indx=1:numel(propNames)
                    roadSpec.(propNames{indx})=oldValues{indx};
                end
                rethrow(ME);
            end
        end

        function undo(this)
            propNames=this.Property;
            oldValues=this.OldValue;
            roadSpec=this.Object;


            for indx=1:numel(propNames)
                roadSpec.(propNames{indx})=oldValues{indx};
            end
            this.Application.Sim3dScene=this.OldSim3dScene;
            updateScenario(this);
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:SetMultiplePropertiesText'));
        end
    end
end


