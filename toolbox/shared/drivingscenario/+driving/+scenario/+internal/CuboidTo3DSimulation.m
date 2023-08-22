classdef CuboidTo3DSimulation<matlab.System

%#codegen

    properties(Nontunable)
        SpecifyActorID(1,1)logical=false

        ActorIDToConvert(1,1){mustBePositive,mustBeInteger}=1
    end


    properties(Access=private)
pActorProfiles
    end


    methods

        function obj=CuboidTo3DSimulation(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Automated_Driving_Toolbox'))
                    error(message('driving:block:NoLicenseAvailable','CuboidTo3DSimulation'));
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


        function resetImpl(obj)
            updateActorProfiles(obj);
        end


        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if strcmp(prop,'ActorIDToConvert')
                flag=~obj.SpecifyActorID;
            end
        end

        function[x,y,yaw]=stepImpl(obj,actorPose)
            if isfield(actorPose,'Actors')
                actors=actorPose.Actors;
                if obj.SpecifyActorID
                    numActors=numel(actors);
                    actorIDs=ones(numActors,1);
                    for kndx=1:numActors
                        actorIDs(kndx)=actors(kndx).ActorID;
                    end
                    selActors=actors(actorIDs==obj.ActorIDToConvert);
                    if~isempty(selActors)
                        actor=selActors(1);
                    else
                        coder.internal.error('driving:block:UnknownActorID',obj.ActorIDToConvert);
                    end
                else
                    actor=actors(1);
                end

            else
                actor=actorPose;
            end
            if isempty(actor)
               actor=driving.scenario.internal.defaultActorPose;
            end
            if~isempty(obj.pActorProfiles)
                numActorsInProfile=numel(obj.pActorProfiles);
                apIDs=ones(numActorsInProfile,1);
                for pndx=1:numActorsInProfile
                    apIDs(pndx)=obj.pActorProfiles(pndx).ActorID;
                end
                ap=obj.pActorProfiles(apIDs==actor(1).ActorID);
                if~isempty(ap)
                    ro=ap(1).Length/2+ap(1).OriginOffset(1);
                    actor(1).Position=driving.scenario.internal.translateVehiclePosition(actor(1).Position,...
                    ro,ap(1).Length,actor(1).Roll,actor(1).Pitch,actor(1).Yaw);
                end
            end
            x=actor(1).Position(1);
            y=actor(1).Position(2);
            yaw=actor(1).Yaw;
        end


        function validateInputsImpl(~,varargin)

            if isfield(varargin{1},'Actors')
                actors=varargin{1}.Actors;
            else
                actors=varargin{1};
            end
            driving.scenario.internal.validateInput('ActorPosesBus',actors,'CuboidTo3DSimulation');
        end


        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end


        function num=getNumInputsImpl(~)
            num=1;
        end


        function num=getNumOutputsImpl(~)
            num=3;
        end


        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.pActorProfiles=s.pActorProfiles;
            end
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);

            if isLocked(obj)
                s.pActorProfiles=obj.pActorProfiles;
            end
        end

        function[outx,outy,outyaw]=getOutputSizeImpl(~)
            outx=[1,1];
            outy=[1,1];
            outyaw=[1,1];
        end

        function[out,out2,out3]=getOutputDataTypeImpl(obj)
            out="double";
            out2="double";
            out3="double";
            updateActorProfiles(obj);
        end


        function updateActorProfiles(obj)
            coder.extrinsic('gcbh');
            if isSourceBlock(obj)
                blkHandle=coder.const(gcbh);
                obj.pActorProfiles=coder.const(driving.scenario.internal.ScenarioReader.getCompiledActorProfiles(blkHandle));
            end
        end

        function[out,out2,out3]=isOutputComplexImpl(~)
            out=false;
            out2=false;
            out3=false;
        end

        function[out,out2,out3]=isOutputFixedSizeImpl(~)
            out=true;
            out2=true;
            out3=true;
        end


        function flag=supportsMultipleInstanceImpl(~)
            flag=true;
        end


        function icon=getIconImpl(obj)
            icon="CuboidTo3DSimulation";
            if obj.SpecifyActorID
                icon=icon+newline+"ActorID: "+obj.ActorIDToConvert;
            end
        end


        function names=getInputNamesImpl(~)
            names="Actor";
        end


        function names=getOutputNamesImpl(~)
            names=["X","Y","Yaw"];
        end


        function flag=isSourceBlock(obj)
            flag=obj.getExecPlatformIndex();
        end
    end


    methods(Static,Access=protected)

        function header=getHeaderImpl
            header=matlab.system.display.Header(...
            'Title','driving:block:CuboidTo3DSimulationTitle',...
            'Text','driving:block:CuboidTo3DSimulationDialogText',...
            'ShowSourceLink',false);
        end


        function groups=getPropertyGroupsImpl

            mainPropList{1}=matlab.system.display.internal.Property(...
            'SpecifyActorID','Description',getString(message('driving:block:SpecifyActorID')));
            mainPropList{2}=matlab.system.display.internal.Property(...
            'ActorIDToConvert','Description',getString(message('driving:block:ActorIDToConvert')));
            groupParams=matlab.system.display.Section(...
            'Title',getString(message('driving:block:MainParameters')),...
            'PropertyList',mainPropList);
            groups=groupParams;
        end

    end
end
