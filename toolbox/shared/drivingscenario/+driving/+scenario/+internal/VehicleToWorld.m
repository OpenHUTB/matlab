classdef VehicleToWorld<matlabshared.tracking.internal.SimulinkBusUtilities







%#codegen

    properties(Constant,Access=protected)

        pBusPrefix={'BusVehicleToWorldActors'}
    end

    methods

        function obj=VehicleToWorld(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Automated_Driving_Toolbox'))
                    error(message('driving:block:NoLicenseAvailable','VehicleToWorld'));
                end
            else
                coder.license('checkout','Automated_Driving_Toolbox');
            end

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)

        function setupImpl(~)

        end

        function actorPoses=stepImpl(~,actorPoses,egoActor)


            tp=driving.scenario.targetsToScenario(actorPoses.Actors,egoActor);
            actorPoses.Actors=tp;
        end

        function flag=isInactivePropertyImpl(obj,prop)


            flag=isInactivePropertyImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj,prop);
        end


        function s=saveObjectImpl(obj)


            s=saveObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
        end

        function loadObjectImpl(obj,s,wasLocked)


            loadObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj,s,wasLocked);
        end

        function validateInputsImpl(~,varargin)


            actors=varargin{1};
            driving.scenario.internal.validateInput('Actors',actors,'VehicleToWorld');
            driving.scenario.internal.validateInput('ActorPosesBus',actors.Actors,'VehicleToWorld');

            driving.scenario.internal.validateInput('Ego',varargin{2},'VehicleToWorld');
        end

        function flag=isInputSizeMutableImpl(~,~)


            flag=false;
        end

        function num=getNumInputsImpl(~)

            num=2;
        end

        function num=getNumOutputsImpl(~)


            num=1;
        end

        function[out]=getOutputSizeImpl(~)

            out=[1,1];
        end

        function out=getOutputDataTypeImpl(obj)

            out=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
        end

        function out=isOutputComplexImpl(~)

            out=false;
        end

        function out=isOutputFixedSizeImpl(~)

            out=true;
        end




        function[out,argsToBus]=defaultOutput(obj)


            out=struct.empty();
            argsToBus={};



            busIn=propagatedInputBus(obj,1);
            if isempty(busIn)
                return
            end
            st=matlabshared.tracking.internal.SimulinkBusUtilities.bus2struct(busIn);
            dp=driving.scenario.internal.defaultActorPose;
            out=repmat(dp,size(st.Actors));
            argsToBus={1};
        end

        function outStruct=sendToBus(~,inStruct,busIndx,varargin)











            switch busIndx
            case 1
                outStruct=struct('NumActors',1,...
                'Time',0,...
                'Actors',inStruct);
            case 2
                outStruct=inStruct;
            end
        end

        function icon=getIconImpl(~)

            icon="VehicleToWorld";
        end

        function names=getInputNamesImpl(~)

            names=["Actors","Ego Vehicle"];
        end

        function name=getOutputNamesImpl(~)

            name="Actors";
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header(...
            'Title','driving:block:VehicleToWorldTitle',...
            'Text','driving:block:VehicleToWorldDialogText',...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl

            portUtil=getPropertyGroupsImpl@matlabshared.tracking.internal.SimulinkBusUtilities;
            portPropList=portUtil.PropertyList;
            portPropList{1}.Description=getString(message('driving:scenarioReader:BusActorSource'));
            portPropList{2}.Description=getString(message('driving:scenarioReader:BusActorName'));
            groups=portUtil;
        end

    end
end
