classdef SetMultipleActorProperties<driving.internal.scenarioApp.undoredo.SetActorProperty

    methods
        function this=SetMultipleActorProperties(varargin)
            hApp=varargin{1};
            spec=varargin{2};
            propNames=varargin{3};
            newValues=varargin{4};



            if(nargin<5)
                oldValues=cell(numel(spec),numel(propNames));
                for indx=1:numel(propNames)
                    for iSpec=1:numel(spec)
                        oldValues{iSpec,indx}=spec(iSpec).(propNames{indx});
                    end
                end
            else
                oldValues=varargin{5};
            end
            this@driving.internal.scenarioApp.undoredo.SetActorProperty(...
            hApp,spec,propNames,newValues,oldValues);
        end

        function execute(this)
            propNames=this.Property;
            newValues=this.NewValue;
            actorSpec=this.Object;


            for indx=1:numel(propNames)
                for iSpec=1:numel(actorSpec)
                    actorSpec(iSpec).(propNames{indx})=newValues{iSpec,indx};
                end
            end
            try
                updateScenario(this);
            catch ME



                oldValues=this.OldValue;
                for indx=1:numel(propNames)
                    for iSpec=1:numel(actorSpec)
                        actorSpec(iSpec).(propNames{indx})=oldValues{iSpec,indx};
                    end
                end
                rethrow(ME);
            end
        end

        function undo(this)
            propNames=this.Property;
            oldValues=this.OldValue;
            actorSpec=this.Object;


            for indx=1:numel(propNames)
                for iSpec=1:numel(actorSpec)
                    actorSpec(iSpec).(propNames{indx})=oldValues{iSpec,indx};
                end
            end
            updateScenario(this);
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:SetMultiplePropertiesText'));
        end
    end
end


