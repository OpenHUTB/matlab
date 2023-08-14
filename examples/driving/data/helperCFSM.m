classdef helperCFSM<matlab.System...
    &matlabshared.tracking.internal.SimulinkBusUtilities





    properties(Nontunable,Access=public)

        ScenarioName='scenario';
    end

    properties(Constant,Access=protected)

        pBusPrefix={'BusActors'};
    end
    properties(Access=private,Hidden=true)

        Vehicles;

        RNStruct;

        ActorCount=0;
    end
    methods

        function obj=helperCFSM(varargin)

            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
        function RNStruct=fetchData(obj)

            coder.extrinsic('gcbh');
            coder.extrinsic('getDynRoadnetwork');
            hSafeReachGoal=coder.const(gcbh);
            RNStruct=coder.const(getDynRoadnetwork(...
            obj.ScenarioName,hSafeReachGoal));
        end
        function set.ScenarioName(obj,varName)

            coder.extrinsic('isvarname');
            if~isvarname(varName)
                coder.internal.error('InvalidScenarioVariableName');
            end
            obj.ScenarioName=char(varName);
        end
    end
    methods(Access=protected)
        function sz1=getOutputSizeImpl(obj)


            sz1=[1,1];
        end
        function dt1=getOutputDataTypeImpl(obj)

            dt1=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
        end
        function out=isOutputFixedSizeImpl(obj)

            out=true;
        end
        function out=isOutputComplexImpl(obj)

            out=false;
        end
        function sts=getSampleTimeImpl(obj)
            sts=createSampleTime(obj,'Type','Discrete',...
            'SampleTime',0.025,'OffsetTime',0.0);
        end
        function icon=getIconImpl(~)

            icon="Collision Free Speed Manipulator";
        end





        function[out,argsToBus]=defaultOutput(obj,varargin)



            if(obj.ActorCount==0)
                obj.RNStruct=obj.fetchData();
                obj.ActorCount=numel(obj.RNStruct.Actors);
            end
            numPts=obj.ActorCount;
            out=struct("ID",NaN(numPts,1),...
            "Position",NaN(numPts,3),...
            "Speed",NaN(numPts,1));
            argsToBus={numPts};
        end
        function out=sendToBus(obj,inStruct,varargin)











            out=struct("ID",inStruct.ID,...
            "Position",inStruct.Position,...
            "Speed",inStruct.Speed);
        end




        function setupImpl(obj)

        end
        function Actors=stepImpl(obj)


            currentTime=obj.getCurrentTime();
            obj.RNStruct=obj.RNStruct.update(currentTime);
            actorDetails=obj.RNStruct.getActorDetails();
            Actors=sendToBus(obj,actorDetails);
        end

        function resetImpl(obj)

        end

    end
    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl

            simMode="Interpreted execution";
        end
        function groups=getPropertyGroupsImpl

            scenarioPropList{1}=matlab.system.display.internal.Property(...
            'ScenarioName','Description','ScenarioName');
            groupScenario=matlab.system.display.Section(...
            'Title','Scenario','PropertyList',scenarioPropList);
            portUtil=getPropertyGroupsImpl@matlabshared.tracking.internal.SimulinkBusUtilities;
            portPropList=portUtil.PropertyList;
            portPropList{1}.Description=getString(message('driving:scenarioReader:BusActorSource'));
            groups=[groupScenario,portUtil];
        end
    end
end
