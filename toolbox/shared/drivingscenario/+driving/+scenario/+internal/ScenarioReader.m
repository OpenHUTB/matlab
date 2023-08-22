classdef(StrictDefaults)ScenarioReader<...
    matlabshared.tracking.internal.SimulinkBusUtilities

%#codegen

    properties(Nontunable)
        OrientVehiclesOnRoad(1,1)logical=false
        OutputEgoVehiclePose(1,1)logical=false;
        OutputEgoVehicleState(1,1)logical=false;
        ShowCoordinateLabels(1,1)logical=true;
        ScenarioFileName='EgoVehicleGoesStraight.mat'

        ScenarioVariableName='scenario'

        ScenarioSource='From file'

        EgoVehicleActorID=1

        OutputCoordinateSystem='Vehicle coordinates'

        EgoVehicleSource='Scenario'

        SampleTime=0.1

        LaneBoundaryOutput='None'
        LaneBoundaryDistance=linspace(-150,150,101)

        LaneBoundaryLocation='Center of lane markings'
    end


    properties(Constant,Hidden)
        OutputCoordinateSystemSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:VehicleCoordinates','driving:scenarioReader:WorldCoordinates'});
        LaneBoundaryOutputSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:None',...
        'driving:scenarioReader:EgoLane','driving:scenarioReader:AllLanes'});

        LaneBoundaryLocationSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:CenterLaneMarkings','driving:scenarioReader:InnerLaneMarkings'});

        EgoVehicleSourceSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:InputPort','driving:scenarioReader:Scenario'});

        BusName2SourceSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:Auto','driving:scenarioReader:Property'})

        BusName3SourceSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:Auto','driving:scenarioReader:Property'})

        BusName4SourceSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:Auto','driving:scenarioReader:Property'})

        ScenarioSourceSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:FromFile','driving:scenarioReader:FromWorkspace'})

        BusNumActorsSourceSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:Scenario','driving:scenarioReader:Property'})

        BusNumLaneBoundariesSourceSet=matlab.system.internal.MessageCatalogSet({'driving:scenarioReader:Scenario','driving:scenarioReader:Property'})
    end

    properties(Nontunable)

        BusName2Source='Auto'

        BusName2=char.empty(1,0)

        BusName3Source='Auto'

        BusName4Source='Auto'

        BusName3=char.empty(1,0)

        BusName4=char.empty(1,0)

        BusNumActorsSource='Scenario'

        BusNumActors=100

        BusNumLaneBoundariesSource='Scenario'

        BusNumLaneBoundaries=10
    end

    properties(Constant,Access=protected)

        pBusPrefix={'BusActors','BusLaneBoundaries','BusEgoActor','BusEgoState'}
    end


    properties(Access=private)


pActors


        pCurrentTime=0


pCurrentIndex


pMaxIndex


pRoadNetwork


        pSampleTimeCached=0.1


pActorOrientCache


pCanOrientActor


pActorStates
    end
    properties(Access=private,Nontunable)

        pLaneBoundariesSize=[2,1]


        pEgoVehicleActorID(1,1){mustBePositive,mustBeInteger}=1


        pHasEgoVehicle(1,1)logical

        pIsOutputVehicleCoordinate(1,1)logical

        pIsInnerLaneBoundary(1,1)logical

        pLaneBoundaries(1,1)logical

        pAllBoundaries(1,1)logical

        pIsScenarioSourceWorkspace(1,1)logical
    end

    methods

        function obj=ScenarioReader(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Automated_Driving_Toolbox'))
                    error(message('driving:block:NoLicenseAvailable','Scenario Reader'));
                end
            else
                coder.license('checkout','Automated_Driving_Toolbox');
            end

            setProperties(obj,nargin,varargin{:})
        end

        function set.ScenarioVariableName(obj,varName)

            coder.extrinsic('isvarname');
            if~isvarname(varName)
                coder.internal.error('driving:scenarioReader:InvalidScenarioVariableName');
            end
            obj.ScenarioVariableName=char(varName);
        end
        function set.ScenarioFileName(obj,rawName)

            coder.extrinsic('message');
            coder.extrinsic('getString');
            validateattributes(rawName,{'char','string'},{'nonempty'},'',getString(message('driving:scenarioReader:ScenarioFileName')));
            obj.ScenarioFileName=char(rawName);
        end
        function set.LaneBoundaryDistance(obj,lbDistance)

            validateattributes(lbDistance,{'numeric'},...
            {'real','finite','vector','increasing','>=',-500,'<=',500},'ScenarioReader','LaneBoundaryDistance');
            obj.LaneBoundaryDistance=lbDistance;
        end
        function set.EgoVehicleActorID(obj,vehID)

            validateattributes(vehID,{'numeric'},...
            {'real','finite','scalar','positive','integer'},'ScenarioReader','EgoVehicleActorID');
            obj.EgoVehicleActorID=vehID;
        end

        function generateScenarioDataForSimulink(obj)
            coder.extrinsic('driving.scenario.internal.Utilities.generateCompiledScenarioData');
            coder.extrinsic('gcbh');
            blkHandle=coder.const(gcbh);
            if obj.isScenarioSourceFile
                fullName=driving.scenario.internal.ScenarioReader.getFullScenarioFileName(obj.ScenarioFileName);
                if~isempty(fullName)

                    driving.scenario.internal.Utilities.generateCompiledScenarioData(fullName,blkHandle,obj.pSampleTimeCached);
                end
            else

                driving.scenario.internal.Utilities.generateCompiledScenarioData(obj.ScenarioVariableName,blkHandle,obj.pSampleTimeCached);
            end
        end

        function set.SampleTime(obj,sampleTime)
            coder.extrinsic('message');
            coder.extrinsic('getString');
            validateattributes(sampleTime,{'numeric'},...
            {'scalar','nonnan','finite','positive'},...
            '',getString(message('driving:scenarioReader:SampleTime')));
            obj.SampleTime=sampleTime;




            obj.pSampleTimeCached=sampleTime;%#ok<MCSUP>
        end



        function val=get.BusName2(obj)
            val=obj.BusName2;
            val=getBusName(obj,val,2);
        end
        function set.BusName2(obj,val)
            validateBusName(obj,val,'BusName2')
            obj.BusName2=val;
        end
        function val=get.BusName3(obj)
            val=obj.BusName3;
            val=getBusName(obj,val,3);
        end
        function set.BusName3(obj,val)
            validateBusName(obj,val,'BusName3')
            obj.BusName3=val;
        end
        function val=get.BusName4(obj)
            val=obj.BusName4;
            val=getBusName(obj,val,4);
        end
        function set.BusName4(obj,val)
            validateBusName(obj,val,'BusName4')
            obj.BusName4=val;
        end
        function set.BusNumActors(obj,val)
            coder.extrinsic('message');
            coder.extrinsic('getString');
            validateattributes(val,{'numeric'},...
            {'scalar','nonnan','finite','positive','integer'},...
            '',getString(message('driving:scenarioReader:BusNumActors')));
            obj.BusNumActors=val;
        end
        function set.BusNumLaneBoundaries(obj,val)
            coder.extrinsic('message');
            coder.extrinsic('getString');
            validateattributes(val,{'numeric'},...
            {'scalar','nonnan','finite','positive','integer','>=',2},...
            '',getString(message('driving:scenarioReader:BusNumLaneBoundaries')));
            obj.BusNumLaneBoundaries=val;
        end
    end

    methods(Access=protected)

        function setupImpl(obj)

            obj.pHasEgoVehicle=obj.isEgoVehicleFromScenario;
            obj.pIsOutputVehicleCoordinate=obj.isOutputVehicleCoordinate;
            obj.pIsInnerLaneBoundary=strcmpi(obj.LaneBoundaryLocation,'Inner edge of lane markings');
            if obj.isScenarioSourceFile
                obj.pEgoVehicleActorID=coder.const(driving.scenario.internal.ScenarioReader.readEgoVehicleActorID(obj.ScenarioFileName));
                obj.pIsScenarioSourceWorkspace=false;
            else
                obj.pEgoVehicleActorID=obj.EgoVehicleActorID;
                obj.pIsScenarioSourceWorkspace=true;
            end
            obj.pLaneBoundaries=isLanesOutput(obj);
            obj.pAllBoundaries=strcmpi(obj.LaneBoundaryOutput,'All lane boundaries');



            if(obj.pLaneBoundaries||obj.OrientVehiclesOnRoad)&&obj.pIsOutputVehicleCoordinate
                readRoadNetwork(obj);
            end
            obj.pCanOrientActor=obj.OrientVehiclesOnRoad&&~isempty(obj.pRoadNetwork)&&obj.pRoadNetwork.RoadHasElevation;
        end

        function[posesOnBus,varargout]=stepImpl(obj,varargin)






            obj.pCurrentTime=obj.pCurrentTime+obj.pSampleTimeCached;
            if~isempty(obj.pActors)
                if~obj.isEndOfData()
                    obj.pCurrentIndex=obj.pCurrentIndex+1;
                end

                if obj.pIsOutputVehicleCoordinate
                    if obj.pHasEgoVehicle
                        egoVehicle=obj.pActors(obj.pCurrentIndex).ActorPoses(obj.pEgoVehicleActorID);
                        otherActorIndices=(obj.pEgoVehicleActorID~=1:numel(obj.pActors(obj.pCurrentIndex).ActorPoses));
                        actors=obj.pActors(obj.pCurrentIndex).ActorPoses(otherActorIndices);
                    else
                        egoVehicle=varargin{1};
                        if obj.pIsScenarioSourceWorkspace&&(egoVehicle.ActorID~=obj.pEgoVehicleActorID)

                            coder.internal.error('driving:scenarioReader:EgoVehicleActorIDMismatch');
                        end


                        if obj.pCanOrientActor
                            [egoVehicle,obj.pActorOrientCache]=driving.scenario.internal.orientVehicleOnRoad(egoVehicle,obj.pRoadNetwork,obj.pActorOrientCache);
                        end
                        actors=obj.pActors(obj.pCurrentIndex).ActorPoses;
                    end
                    actorPoses=driving.scenario.targetsToEgo(actors,egoVehicle);
                else

                    actorPoses=obj.pActors(obj.pCurrentIndex).ActorPoses;
                end
            else
                actorPoses=[];
                if obj.pHasEgoVehicle||~obj.pIsOutputVehicleCoordinate
                    egoVehicle=driving.scenario.internal.defaultActorPose;
                else
                    egoVehicle=varargin{1};


                    if obj.pCanOrientActor
                        [egoVehicle,obj.pActorOrientCache]=driving.scenario.internal.orientVehicleOnRoad(egoVehicle,obj.pRoadNetwork,obj.pActorOrientCache);
                    end
                end
            end
            if isempty(actorPoses)
                posesOnBus=sendToBus(obj,actorPoses,1);
            else

                isValid=true(length(actorPoses),1);
                for indx=1:length(actorPoses)
                    isValid(indx)=~isequaln(actorPoses(indx,1).Position(1:end),[NaN,NaN,NaN]);
                end



                val=actorPoses(isValid);
                inVal=actorPoses(~isValid);
                actorPoses(1:length(val))=val;
                if(~isempty(inVal))&&(~isempty(val))
                    actorPoses(1:end)=[val;inVal];
                end
                posesOnBus=sendToBus(obj,actorPoses,1);
                posesOnBus(1).NumActors=sum(isValid);
                if posesOnBus(1).NumActors==0
                    posesOnBus(1).Actors(1,1)=struct('ActorID',...
                    actorPoses(1,1).ActorID,'Position',[0,0,0],...
                    'Velocity',[0,0,0],'Roll',0,'Pitch',0,'Yaw',0,...
                    'AngularVelocity',[0,0,0]);
                end
            end

            oIndx=0;

            if obj.pLaneBoundaries&&obj.pIsOutputVehicleCoordinate
                lbStruct=driving.scenario.internal.laneBoundaries(obj.pRoadNetwork,...
                egoVehicle,obj.LaneBoundaryDistance,obj.pIsInnerLaneBoundary,...
                obj.pAllBoundaries,obj.pLaneBoundariesSize);
                oIndx=oIndx+1;
                varargout{oIndx}=sendToBus(obj,lbStruct,2);
            end

            if obj.OutputEgoVehiclePose&&obj.pHasEgoVehicle&&obj.pIsOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=egoVehicle;
            end
            if obj.OutputEgoVehicleState&&obj.pHasEgoVehicle&&obj.pIsOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=obj.pActorStates(obj.pCurrentIndex).ActorStates(obj.pEgoVehicleActorID);
            end
        end

        function resetImpl(obj)



            updateActorsData(obj);


            if coder.target('MATLAB')
                currentTime=str2double(get_param(bdroot,'StartTime'));
            else
                currentTime=getCurrentTime(obj);
            end


            coder.internal.errorIf(currentTime<0,'driving:scenarioReader:NegativeStartTime');
            obj.pCurrentTime=currentTime;


            obj.pCurrentTime=obj.pCurrentTime-obj.pSampleTimeCached;
            obj.pCurrentIndex=0;
            obj.pActorOrientCache=getDefaultOrientStruct(obj);
        end

        function flag=isInactivePropertyImpl(obj,prop)



            flag=isInactivePropertyImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj,prop);

            isVehicle=obj.isOutputVehicleCoordinate;
            isFile=obj.isScenarioSourceFile;

            if strcmp(prop,'ScenarioFileName')
                flag=~isFile;
            end

            if strcmp(prop,'ScenarioVariableName')
                flag=isFile;
            end

            if strcmp(prop,'EgoVehicleActorID')
                flag=~(~isFile&&isVehicle);
            end

            if strcmp(prop,'OrientVehiclesOnRoad')
                flag=obj.isEgoVehicleFromScenario||~isVehicle;
            end

            if strcmp(prop,'OutputEgoVehiclePose')
                flag=~obj.isEgoVehicleFromScenario||~isVehicle;
            end

            if strcmp(prop,'OutputEgoVehicleState')
                flag=~obj.isEgoVehicleFromScenario||~isVehicle;
            end

            if strcmp(prop,'EgoVehicleSource')
                flag=~isVehicle;
            end

            if strcmp(prop,'LaneBoundaryOutput')
                flag=~isVehicle;
            end

            outputLaneBoundaries=isLanesOutput(obj);

            if strcmp(prop,'LaneBoundaryDistance')
                flag=~(outputLaneBoundaries&&isVehicle);
            end

            if strcmp(prop,'LaneBoundaryLocation')
                flag=~(outputLaneBoundaries&&isVehicle);
            end

            if~isSourceBlock(obj)&&...
                (strcmp(prop,'BusName2Source')||strcmp(prop,'BusName2')||...
                strcmp(prop,'BusName3Source')||strcmp(prop,'BusName3')||...
                strcmp(prop,'BusName4Source')||strcmp(prop,'BusName4')||...
                strcmp(prop,'BusNumActorsSource')||strcmp(prop,'BusNumActors')||...
                strcmp(prop,'BusNumLaneBoundariesSource')||strcmp(prop,'BusLaneBoundariesActors'))
                flag=true;
            else
                if strcmp(prop,'BusName2')
                    flag=~(~strcmp(obj.BusName2Source,'Auto')&&outputLaneBoundaries&&isVehicle);
                end
                if strcmp(prop,'BusName2Source')
                    flag=~(outputLaneBoundaries&&isVehicle);
                end
                if strcmp(prop,'BusName3')
                    flag=~(~strcmp(obj.BusName3Source,'Auto')&&obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&isVehicle);
                end
                if strcmp(prop,'BusName3Source')
                    flag=~(obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&isVehicle);
                end

                if strcmp(prop,'BusName4')
                    flag=~(~strcmp(obj.BusName4Source,'Auto')&&obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&isVehicle);
                end
                if strcmp(prop,'BusName4Source')
                    flag=~(obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&isVehicle);
                end

                if strcmp(prop,'BusNumActors')
                    flag=strcmp(obj.BusNumActorsSource,'Scenario');
                end
                outputAllBoundaries=strcmpi(obj.LaneBoundaryOutput,'All lane boundaries');
                if strcmp(prop,'BusNumLaneBoundariesSource')
                    flag=~(outputAllBoundaries&&isVehicle);
                end
                if strcmp(prop,'BusNumLaneBoundaries')
                    flag=~(strcmp(obj.BusNumLaneBoundariesSource,'Property')&&outputAllBoundaries&&isVehicle);
                end
            end
        end


        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);


            s.pActors=obj.pActors;
            s.pCurrentTime=obj.pCurrentTime;
            s.pCurrentIndex=obj.pCurrentIndex;
            s.pMaxIndex=obj.pMaxIndex;
            s.pRoadNetwork=obj.pRoadNetwork;
            s.pSampleTimeCached=obj.pSampleTimeCached;
            s.pLaneBoundariesSize=obj.pLaneBoundariesSize;
            s.pEgoVehicleActorID=obj.pEgoVehicleActorID;
            s.pHasEgoVehicle=obj.pHasEgoVehicle;
            s.pIsOutputVehicleCoordinate=obj.pIsOutputVehicleCoordinate;
            s.pIsInnerLaneBoundary=obj.pIsInnerLaneBoundary;
            s.pLaneBoundaries=obj.pLaneBoundaries;
            s.pAllBoundaries=obj.pAllBoundaries;
            s.pIsScenarioSourceWorkspace=obj.pIsScenarioSourceWorkspace;
            s.pActorStates=obj.pActorStates;
        end

        function status=isEndOfData(obj)

            status=(obj.pCurrentIndex==obj.pMaxIndex);
        end

        function loadObjectImpl(obj,s,wasLocked)



            obj.pActors=s.pActors;
            obj.pCurrentTime=s.pCurrentTime;
            obj.pCurrentIndex=s.pCurrentIndex;
            obj.pMaxIndex=s.pMaxIndex;
            obj.pRoadNetwork=s.pRoadNetwork;
            obj.pLaneBoundariesSize=s.pLaneBoundariesSize;
            obj.pEgoVehicleActorID=s.pEgoVehicleActorID;
            obj.pHasEgoVehicle=s.pHasEgoVehicle;
            obj.pIsOutputVehicleCoordinate=s.pIsOutputVehicleCoordinate;
            obj.pIsInnerLaneBoundary=s.pIsInnerLaneBoundary;
            obj.pLaneBoundaries=s.pLaneBoundaries;
            obj.pAllBoundaries=s.pAllBoundaries;
            obj.pIsScenarioSourceWorkspace=s.pIsScenarioSourceWorkspace;
            obj.pActorStates=s.pActorStates;

            loadObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj,s,wasLocked);
        end


        function ds=getDiscreteStateImpl(~)

            ds=struct([]);
        end

        function validateInputsImpl(obj,varargin)

            if~obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                driving.scenario.internal.validateInput('Ego',varargin{1},'ScenarioReader');
            end
        end


        function num=getNumInputsImpl(obj)

            num=0;
            if~obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                num=1;
            end
        end

        function num=getNumOutputsImpl(obj)


            num=1;
            outputLaneBoundaries=isLanesOutput(obj);
            if outputLaneBoundaries&&obj.isOutputVehicleCoordinate
                num=num+1;
            end
            if obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                num=num+1;
            end
            if obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                num=num+1;
            end
        end

        function[out,varargout]=getOutputSizeImpl(obj)

            out=[1,1];
            outputLaneBoundaries=isLanesOutput(obj)&&...
            obj.isOutputVehicleCoordinate;
            varargout=cell(1,0);
            oIndx=0;
            if outputLaneBoundaries
                oIndx=oIndx+1;
                varargout{oIndx}=[1,1];
            end
            if obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=[1,1];
            end
            if obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=[1,1];
            end
        end

        function[out,varargout]=getOutputDataTypeImpl(obj)




            generateScenarioDataForSimulink(obj);


            if obj.isOutputVehicleCoordinate&&obj.isEgoVehicleFromScenario
                if obj.isScenarioSourceFile
                    egoIDScenario=coder.const(driving.scenario.internal.ScenarioReader.readEgoVehicleActorID(obj.ScenarioFileName));
                    if(egoIDScenario==-1)

                        msg=message('driving:scenarioReader:UndefinedEgoVehicle');
                        throwAsCaller(MException(msg));
                    end
                    isSmoothTrajectory=coder.const(driving.scenario.internal.Utilities.getIsSmoothTrajectory(...
                    obj.ScenarioFileName,egoIDScenario));
                else

                    sActors=coder.const(driving.scenario.internal.Utilities.getCompiledActors(...
                    obj.ScenarioVariableName,obj.EgoVehicleSource,obj.EgoVehicleActorID,true,-1));
                    coder.internal.errorIf(isempty(sActors),...
                    'driving:scenarioReader:InvalidEgoVehicleActorID',obj.EgoVehicleActorID);
                    actorIDs=ones(length(sActors(1).ActorPoses),1);
                    for kndx=1:length(actorIDs)
                        actorIDs(kndx)=sActors(1).ActorPoses(kndx).ActorID;
                    end
                    coder.internal.errorIf(~any(actorIDs==obj.EgoVehicleActorID),...
                    'driving:scenarioReader:InvalidEgoVehicleActorID',obj.EgoVehicleActorID);
                    isSmoothTrajectory=coder.const(driving.scenario.internal.Utilities.getIsSmoothTrajectory(...
                    obj.ScenarioVariableName,obj.EgoVehicleActorID));
                end



                if obj.OutputEgoVehicleState
                    coder.internal.errorIf(~isSmoothTrajectory,...
                    'driving:scenarioReader:StateRequiresSmoothTrajectory');
                end
            end

            outputLaneBoundaries=isLanesOutput(obj)&&...
            obj.isOutputVehicleCoordinate;
            outputEgoVehicle=obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate;
            outputEgoVehicleState=obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate;
            if outputLaneBoundaries&&outputEgoVehicle&&outputEgoVehicleState
                [out,busTypeLaneBoundaries,busTypeEgoVehicle,busTypeEgoVehicleState]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={busTypeLaneBoundaries,busTypeEgoVehicle,busTypeEgoVehicleState};
            elseif outputLaneBoundaries&&outputEgoVehicle
                [out,busTypeLaneBoundaries,busTypeEgoVehicle]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={busTypeLaneBoundaries,busTypeEgoVehicle};
            elseif outputLaneBoundaries&&outputEgoVehicleState
                [out,busTypeLaneBoundaries,busTypeEgoVehicleState]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={busTypeLaneBoundaries,busTypeEgoVehicleState};
            elseif outputEgoVehicle&&outputEgoVehicleState
                [out,busTypeEgoVehicle,busTypeEgoVehicleState]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={busTypeEgoVehicle,busTypeEgoVehicleState};
            elseif outputLaneBoundaries
                [out,busTypeLaneBoundaries]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={busTypeLaneBoundaries};
            elseif outputEgoVehicle
                [out,busTypeEgoVehicle]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={busTypeEgoVehicle};
            elseif outputEgoVehicleState
                [out,busTypeEgoVehicleState]=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={busTypeEgoVehicleState};
            else
                out=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
                varargout={};
            end
        end

        function[out,varargout]=isOutputComplexImpl(obj)

            out=false;
            outputLaneBoundaries=isLanesOutput(obj)&&...
            obj.isOutputVehicleCoordinate;
            varargout=cell(1,0);
            oIndx=0;
            if outputLaneBoundaries
                oIndx=oIndx+1;
                varargout{oIndx}=false;
            end
            if obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=false;
            end
            if obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=false;
            end
        end

        function[out,varargout]=isOutputFixedSizeImpl(obj)

            out=true;
            outputLaneBoundaries=isLanesOutput(obj)&&...
            obj.isOutputVehicleCoordinate;
            varargout=cell(1,0);
            oIndx=0;
            if outputLaneBoundaries
                oIndx=oIndx+1;
                varargout{oIndx}=true;
            end
            if obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=true;
            end
            if obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                varargout{oIndx}=true;
            end
        end

        function sts=getSampleTimeImpl(obj)


            sts=obj.createSampleTime("Type","Discrete",...
            "SampleTime",obj.SampleTime);
        end

        function updateActorsData(obj)
            isVehicle=coder.const(obj.isOutputVehicleCoordinate);
            coder.extrinsic('driving.scenario.internal.Utilities.getCompiledActors');
            coder.extrinsic('driving.scenario.internal.Utilities.getCompiledActorStates');
            if obj.isBusNumActorsSourceProperty
                numActors=obj.BusNumActors;
            else
                numActors=-1;
            end
            if obj.isScenarioSourceFile
                egoIDScenario=coder.const(driving.scenario.internal.ScenarioReader.readEgoVehicleActorID(obj.ScenarioFileName));
                obj.pActors=coder.const(driving.scenario.internal.Utilities.getCompiledActors(...
                obj.ScenarioFileName,obj.EgoVehicleSource,egoIDScenario,isVehicle,numActors));
                if obj.OutputEgoVehicleState
                    obj.pActorStates=coder.const(driving.scenario.internal.Utilities.getCompiledActorStates(...
                    obj.ScenarioFileName,isVehicle,numActors));
                end
            else
                obj.pActors=coder.const(driving.scenario.internal.Utilities.getCompiledActors(...
                obj.ScenarioVariableName,obj.EgoVehicleSource,obj.EgoVehicleActorID,isVehicle,numActors));
                if obj.OutputEgoVehicleState
                    obj.pActorStates=coder.const(driving.scenario.internal.Utilities.getCompiledActorStates(...
                    obj.ScenarioVariableName,isVehicle,numActors));
                end
            end
            obj.pMaxIndex=numel(obj.pActors);
        end

        function readRoadNetwork(obj)

            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            if obj.isScenarioSourceFile
                fullName=coder.const(driving.scenario.internal.ScenarioReader.getFullScenarioFileName(obj.ScenarioFileName));
                s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            else
                s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(obj.ScenarioVariableName));
            end


            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            expFields={'RoadNetwork'};
            flag=driving.scenario.internal.ScenarioReader.checkStructForFields(s,expFields);
            if flag
                obj.pRoadNetwork=s.RoadNetwork;
                if isempty(obj.pRoadNetwork)||~strcmpi(obj.LaneBoundaryOutput,'All lane boundaries')
                    obj.pLaneBoundariesSize=[2,1];
                else


                    if strcmpi(obj.BusNumLaneBoundariesSource,'Property')
                        obj.pLaneBoundariesSize=[obj.BusNumLaneBoundaries,1];
                    else
                        if strcmpi(obj.LaneBoundaryLocation,'Center of lane markings')
                            mbLength=size(obj.pRoadNetwork.MaxLaneBoundaryCenter,2);
                        else
                            mbLength=size(obj.pRoadNetwork.MaxLaneBoundaryInner,2);
                        end
                        obj.pLaneBoundariesSize=[mbLength,1];
                    end
                end
            end
        end




        function[out,argsToBus]=defaultOutput(obj,busIndx)


            switch busIndx
            case 1
                updateActorsData(obj);
                if isempty(obj.pActors)
                    actorPoses=driving.scenario.internal.defaultActorPose;
                else
                    if obj.isOutputVehicleCoordinate
                        numActors=numel(obj.pActors(1).ActorPoses)-obj.isEgoVehicleFromScenario;
                    else
                        numActors=numel(obj.pActors(1).ActorPoses);
                    end
                    numActors=max(numActors,1);
                    actorStruct=obj.pActors(1).ActorPoses(1);
                    actorPoses=repmat(actorStruct,[numActors,1]);
                end
                out=actorPoses;
                argsToBus={1};
            case 2
                if(isLanesOutput(obj)||obj.OrientVehiclesOnRoad)&&obj.isOutputVehicleCoordinate
                    readRoadNetwork(obj);
                    out=driving.scenario.internal.defaultLaneBoundaries(obj.LaneBoundaryDistance,obj.pLaneBoundariesSize);
                else
                    numPts=numel(obj.LaneBoundaryDistance);
                    out=struct('Coordinates',NaN(numPts,3),...
                    'Curvature',NaN(numPts,1),...
                    'CurvatureDerivative',NaN(numPts,1),...
                    'HeadingAngle',NaN,...
                    'LateralOffset',NaN,...
                    'BoundaryType',uint8(0),...
                    'Strength',NaN,...
                    'Width',NaN,...
                    'Length',NaN,...
                    'Space',NaN);
                end
                argsToBus={};
            case 3
                out=driving.scenario.internal.defaultActorPose;
                argsToBus={};
            case 4
                out=driving.scenario.internal.defaultActorState;
                argsToBus={};
            end
        end

        function outStruct=sendToBus(obj,inStruct,busIndx,varargin)











            switch busIndx
            case 1
                if isempty(inStruct)
                    outActorPoses=driving.scenario.internal.defaultActorPose;
                    numActors=0;
                else
                    outActorPoses=inStruct;
                    numActors=numel(inStruct);
                end
                outStruct=struct('NumActors',numActors,...
                'Time',obj.pCurrentTime,...
                'Actors',outActorPoses);
            case 2
                outStruct=struct('NumLaneBoundaries',numel(inStruct),...
                'Time',obj.pCurrentTime,...
                'LaneBoundaries',inStruct);
            case 3
                outStruct=inStruct;
            case 4
                outStruct=inStruct;
            end
        end

        function icon=getIconImpl(obj)

            if obj.isScenarioSourceFile
                [~,fileName,~]=fileparts(obj.ScenarioFileName);
                icon={fileName};
            else
                icon={obj.ScenarioVariableName};
            end
            if getNumInputs(obj)==1||getNumOutputs(obj)==1
                icon=[icon,{'',''}];
            end
        end

        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,nargout);
            if~obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                if obj.ShowCoordinateLabels
                    varargout{1}=sprintf('Ego Vehicle Pose\n(World Coord.)');
                else
                    varargout{1}=sprintf('Ego Vehicle Pose');
                end
            end
        end

        function[name,varargout]=getOutputNamesImpl(obj)

            name='Actors';
            if obj.ShowCoordinateLabels
                if obj.isOutputVehicleCoordinate
                    name=sprintf('Actors\n(Vehicle Coord.)');
                else
                    name=sprintf('Actors\n(World Coord.)');
                end
            end
            varargout=cell(1,0);
            oIndx=0;
            if isLanesOutput(obj)&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                if obj.ShowCoordinateLabels
                    varargout{oIndx}=sprintf('Lane\nBoundaries\n(Vehicle Coord.)');
                else
                    varargout{oIndx}=sprintf('Lane\nBoundaries');
                end
            end
            if obj.OutputEgoVehiclePose&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                if obj.ShowCoordinateLabels
                    varargout{oIndx}=sprintf('Ego Vehicle Pose\n(World Coord.)');
                else
                    varargout{oIndx}=sprintf('Ego Vehicle Pose');
                end
            end
            if obj.OutputEgoVehicleState&&obj.isEgoVehicleFromScenario&&obj.isOutputVehicleCoordinate
                oIndx=oIndx+1;
                if obj.ShowCoordinateLabels
                    varargout{oIndx}=sprintf('Ego Vehicle State\n(World Coord.)');
                else
                    varargout{oIndx}=sprintf('Ego Vehicle State');
                end
            end
        end

        function isVehicle=isOutputVehicleCoordinate(obj)

            isVehicle=strcmpi(obj.OutputCoordinateSystem,'Vehicle coordinates');
        end

        function ol=isLanesOutput(obj)

            ol=~strcmpi(obj.LaneBoundaryOutput,'None');
        end

        function isFile=isScenarioSourceFile(obj)

            isFile=strcmpi(obj.ScenarioSource,'From file');
        end

        function isFromScenario=isEgoVehicleFromScenario(obj)

            isFromScenario=strcmpi(obj.EgoVehicleSource,'Scenario');
        end

        function def=getDefaultOrientStruct(~)

            def=struct('Elevation',NaN,...
            'Roll',NaN,...
            'Pitch',NaN,...
            'Yaw',NaN);
        end

        function isProperty=isBusNumActorsSourceProperty(obj)
            isProperty=strcmpi(obj.BusNumActorsSource,'Property');
        end
    end

    methods(Hidden)
        function browseButtonCallback(obj,h)
            title=getString(message('driving:scenarioApp:OpenDialogTitleScenario'));
            spec={'*.mat',getString(message('driving:scenarioApp:FileTypeDescription'))};

            [file,path]=uigetfile(spec,title,obj.ScenarioFileName);

            if file


                file=fullfile(path,file);

                blk=h.SystemHandle;
                set_param(blk,'ScenarioFileName',file);
                obj.ScenarioFileName=char(file);
            end
        end
    end

    methods(Static)
        function fullName=getFullScenarioFileName(rawName)
            coder.extrinsic('which');
            coder.extrinsic('exist');
            if isempty(rawName)
                fullName=rawName;
            else



                fullNameTest=coder.const(which(rawName));
                if isempty(fullNameTest)



                    fullName=rawName;
                else
                    fullName=fullNameTest;
                end


                isFileFound=coder.const(exist(fullName,'file'));
                coder.internal.errorIf(~isFileFound,...
                'driving:scenarioReader:UnableToLoadFile',fullName);
            end

        end

        function egoVehicleID=readEgoVehicleActorID(scenarioFileName)


            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getFullScenarioFileName(scenarioFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            egoVehicleID=-1;
            if isempty(s)
                return;
            end

            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            expFields={'EgoCarId'};
            found=driving.scenario.internal.ScenarioReader.checkStructForFields(s,expFields);
            if found&&~isempty(s.EgoCarId)
                egoVehicleID=s.EgoCarId;
            end
        end

        function splitRoadBoundaries=splitRoadBoundariesAtNans(roadBoundariesWithNans,nanLocations)
            numNans=length(nanLocations);
            splitRoadBoundaries=cell(1,numNans);
            cellIdx=1;rbStartIdx=1;
            for nanIdx=nanLocations

                assert(~isequal(rbStartIdx,nanIdx));
                splitRoadBoundaries{cellIdx}=roadBoundariesWithNans(rbStartIdx:nanIdx-1,:);
                rbStartIdx=nanIdx+1;cellIdx=cellIdx+1;
            end
            splitRoadBoundaries{cellIdx}=roadBoundariesWithNans(rbStartIdx:end,:);
        end

        function key=getScenarioKey(scenarioSource)


            if isvarname(scenarioSource)
                key=scenarioSource;
            else
                key=driving.scenario.internal.ScenarioReader.getFullScenarioFileName(scenarioSource);
            end
        end

        function[roadBoundaries,roadDims]=readRoadBoundaries(scenarioFileName,varargin)

            if isequal(nargin,2)
                splitRoadsRequired=varargin{1};
            else
                splitRoadsRequired=false;
            end


            fullName=coder.const(driving.scenario.internal.ScenarioReader.getScenarioKey(scenarioFileName));


            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));


            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            expFields={'RoadBoundaries'};
            flag=driving.scenario.internal.ScenarioReader.checkStructForFields(s,expFields);
            foundRoads=false;
            if flag
                foundRoads=true;
                roads=s.RoadBoundaries;
            else
                fields=fieldnames(s);
                for i=1:numel(fields)
                    flag=driving.scenario.internal.ScenarioReader.checkStructForFields(s.(fields{i}),expFields);
                    if flag
                        foundRoads=true;
                        roads=s.(fields{i});
                        break
                    end
                end
            end
            if foundRoads
                if isstruct(roads)
                    r=struct2cell(roads);
                    numRoads=numel(r);
                    roadBoundaries=reshape(r,1,numRoads);
                elseif~iscell(roads)
                    roadBoundaries={roads};
                else
                    roadBoundaries=roads;
                end
            else
                roadBoundaries=[];
            end
            if isempty(roadBoundaries)||isempty(roadBoundaries{1})

                roadBoundaries=[];
                roadDims=[];
                return;
            end
            egoVehicle=driving.scenario.internal.defaultActorPose;
            roads=driving.scenario.roadBoundariesToEgo(roadBoundaries,egoVehicle);
            roadDims=size(roads);



            if(splitRoadsRequired)
                splitRoadBoundaries={};
                for rbIdx=1:length(roadBoundaries)
                    roadBoundariesArray=roadBoundaries{rbIdx};
                    rbRows=1:size(roadBoundariesArray,1);
                    nanLocations=rbRows(isnan(roadBoundariesArray(:,1)));
                    if~isempty(nanLocations)
                        splitRoadBoundaries=[splitRoadBoundaries,driving.scenario.internal.ScenarioReader.splitRoadBoundariesAtNans(roadBoundariesArray,nanLocations)];%#ok
                    else
                        splitRoadBoundaries=[splitRoadBoundaries,roadBoundariesArray];%#ok
                    end
                end
                roadBoundaries=splitRoadBoundaries;
            end
        end

        function[laneMarkingVertices,laneMarkingFaces,foundMarkings,varargout]=readLaneMarkings(scenarioFileName)

            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getScenarioKey(scenarioFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            if isequal(nargout,4)
                varargout{1}=s;
            end

            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            expFields={'LaneMarkingVertices','LaneMarkingFaces'};
            flag=driving.scenario.internal.ScenarioReader.checkStructForFields(s,expFields);
            foundMarkings=false;
            if flag
                foundMarkings=true;
                laneMarkingVertices=s.LaneMarkingVertices;
                laneMarkingFaces=s.LaneMarkingFaces;
            else
                laneMarkingVertices=[];
                laneMarkingFaces=[];
            end
        end

        function actors=readActorsData(scenarioFileName)

            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getScenarioKey(scenarioFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            if isempty(s)
                actors=[];
                return;
            end

            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            expFields={'SimulationTime','ActorPoses'};
            flag=driving.scenario.internal.ScenarioReader.checkStructForFields(s,expFields);
            foundActors=false;
            if flag
                foundActors=true;
                actors=s;
            else
                fields=fieldnames(s);
                for i=1:numel(fields)
                    flag=driving.scenario.internal.ScenarioReader.checkStructForFields(s.(fields{i}),expFields);
                    if flag
                        foundActors=true;
                        actors=s.(fields{i});
                        break
                    end
                end
            end
            if~foundActors
                actors=[];
            end
        end

        function actorStates=readActorsStateData(scenarioFileName)

            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getScenarioKey(scenarioFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            if isempty(s)
                actorStates=[];
                return;
            end

            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            actorStates=s.vehicleStates;
        end

        function isSmoothTrajectory=readActorsIsSmoothTrajectory(scenarioFileName)

            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getScenarioKey(scenarioFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            if isempty(s)
                isSmoothTrajectory=[];
                return;
            end

            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            isSmoothTrajectory=s.isSmoothTrajectory;
        end

        function[egoActor,simTimes]=getEgoActorAndSimTimes(scenarioFileName,varargin)
            if nargin<2
                egoIndex=driving.scenario.internal.ScenarioReader.readEgoVehicleActorID(scenarioFileName);
            else
                egoIndex=varargin{1};
            end
            actors=driving.scenario.internal.ScenarioReader.readActorsData(scenarioFileName);
            if isempty(actors)||(egoIndex==-1)
                simTimes=0;
                egoActorStructArray=driving.scenario.internal.defaultActorPose;
            else
                simTimes=[actors.SimulationTime];
                actorPoses=[actors.ActorPoses];
                egoActorStructArray=actorPoses(egoIndex,:);
            end
            egoActor=struct('ActorID',egoActorStructArray(1).ActorID,...
            'Position',[egoActorStructArray.Position],...
            'Velocity',[egoActorStructArray.Velocity],...
            'Roll',[egoActorStructArray.Roll],...
            'Pitch',[egoActorStructArray.Pitch],...
            'Yaw',[egoActorStructArray.Yaw],...
            'AngularVelocity',[egoActorStructArray.AngularVelocity]);
        end

        function actor_profiles=readActorProfiles(scenarioFileName,includeColor)


            coder.extrinsic('driving.scenario.internal.setGetCompiledScenarioData');
            if nargin<2


                includeColor=false;
            end
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getScenarioKey(scenarioFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            actor_profiles=[];
            if isempty(s)
                return;
            end

            validateattributes(s,{'struct'},{'nonempty'},'ScenarioReader');
            expFields={'ActorProfiles'};
            found=driving.scenario.internal.ScenarioReader.checkStructForFields(s,expFields);
            if found&&~isempty(s.ActorProfiles)
                actor_profiles=s.ActorProfiles;
                if~includeColor
                    actor_profiles=rmfield(actor_profiles,'Color');
                end
            end
        end

        function[actorID,actorLength,actorWidth,actorRearOverhang,color]=getActorProfiles(scenarioFileName)

            profiles=driving.scenario.internal.ScenarioReader.readActorProfiles(scenarioFileName,true);
            actorID=[];
            actorLength=4.7;
            actorWidth=1.8;
            actorRearOverhang=1;
            color=round(lines(1)*255);
            if~isempty(profiles)
                actorID=[profiles.ActorID];
                actorLength=[profiles.Length];
                actorWidth=[profiles.Width];
                numActors=length(actorLength);
                actorRearOverhang=ones(1,numActors);
                for kndx=1:numActors
                    actorRearOverhang(kndx)=actorLength(kndx)/2+profiles(kndx).OriginOffset(1);
                end
                color=[profiles.Color];
            end
        end

        function egoPoses=readEgoVehiclePoses(scenarioSource,varargin)

            if nargin>1


                egoIndex=varargin{1};
            else
                egoIndex=driving.scenario.internal.ScenarioReader.readEgoVehicleActorID(scenarioSource);
            end
            actors=driving.scenario.internal.ScenarioReader.readActorsData(scenarioSource);
            if isempty(actors)||(egoIndex==-1)
                egoPoses=[];
            else
                actorPoses=[actors.ActorPoses];
                egoPoses=actorPoses(egoIndex,:);
            end
        end

        function verticalAxis=getVerticalAxis(scenarioFileName)
            fullName=coder.const(driving.scenario.internal.ScenarioReader.getScenarioKey(scenarioFileName));
            s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(fullName));
            verticalAxis=s.VerticalAxis;
        end

        function isEnabled=isBrowseEnabled(hblk)

            if isnumeric(hblk)
                isFile=strcmpi(get_param(hblk,'ScenarioSource'),'From file');
            else
                isFile=false;
            end
            isEnabled=true;
            if~isFile
                isEnabled=false;
            end
            isEnabled=isEnabled&&~matlab.system.display.Action.isSystemLocked(hblk);
        end

        function outData=blockTransformationFcn(inData)



            InstanceData=inData.InstanceData;
            outData.NewInstanceData=InstanceData;
            paramNames={outData.NewInstanceData.Name};
            egoVehSourceParamIndx=strcmpi('EgoVehicleSource',paramNames);


            if strcmpi(outData.NewInstanceData(egoVehSourceParamIndx).Value,'Scenario file')
                outData.NewInstanceData(egoVehSourceParamIndx).Value='Scenario';
            end
            outData.NewBlockPath=inData.ForwardingTableEntry.('__slOldName__');
        end

        function rn=getCompiledRoadNetwork(sensorBlockHandle)
            coder.extrinsic('driving.scenario.internal.ScenarioReader.findScenarioReaderBlock');
            hScenarioReaderBlock=coder.const(driving.scenario.internal.ScenarioReader.findScenarioReaderBlock(sensorBlockHandle));
            if~isempty(hScenarioReaderBlock)


                scenarioFullName=driving.scenario.internal.ScenarioReader.getScenarioFullNameFromBlock(hScenarioReaderBlock);
                s=coder.const(driving.scenario.internal.setGetCompiledScenarioData(scenarioFullName));
                if~isempty(s)
                    rn=s.RoadNetwork;
                else
                    rn=[];
                end
            else
                rn=[];
            end
        end

        function ap=getCompiledActorProfiles(sensorBlockHandle)

            coder.extrinsic('driving.scenario.internal.ScenarioReader.findScenarioReaderBlock');
            coder.extrinsic('driving.scenario.internal.ScenarioReader.readActorProfiles');
            hScenarioReaderBlock=coder.const(driving.scenario.internal.ScenarioReader.findScenarioReaderBlock(sensorBlockHandle));
            if~isempty(hScenarioReaderBlock)
                scenarioFullName=driving.scenario.internal.ScenarioReader.getScenarioFullNameFromBlock(hScenarioReaderBlock);
                ap=coder.const(driving.scenario.internal.ScenarioReader.readActorProfiles(scenarioFullName));
            else
                ap=[];
            end
        end

        function scenarioFullName=getScenarioFullNameFromBlock(hScenarioReaderBlock)


            coder.extrinsic('get_param');
            scenarioSource=coder.const(get_param(hScenarioReaderBlock,'ScenarioSource'));
            if strcmpi(scenarioSource,'From file')
                scenarioName=coder.const(get_param(hScenarioReaderBlock,'ScenarioFileName'));
                scenarioFullName=coder.const(driving.scenario.internal.ScenarioReader.getFullScenarioFileName(scenarioName));
            else
                scenarioFullName=coder.const(get_param(hScenarioReaderBlock,'ScenarioVariableName'));
            end
        end

        function hScenarioReaderBlock=findScenarioReaderBlock(sensorBlockHandle)
            coder.extrinsic('find_system');


            hScenarioReaderBlock=coder.const(find_system(bdroot(sensorBlockHandle),'FirstResultOnly','on','System','driving.scenario.internal.ScenarioReader'));
            if isempty(hScenarioReaderBlock)

                topMdlName=get_param(bdroot(sensorBlockHandle),'Name');


                allMdls=find_mdlrefs(bdroot(sensorBlockHandle),'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                for i=1:numel(allMdls)
                    refMdlName=allMdls{i};
                    if isequal(refMdlName,topMdlName)
                        continue;
                    end
                    isNotLoaded=~bdIsLoaded(refMdlName);
                    if isNotLoaded
                        load_system(refMdlName);
                        clnUp=onCleanup(@()close_system(refMdlName,0));
                    end
                    foundBlkPath=coder.const(find_system(refMdlName,'FirstResultOnly','on','System','driving.scenario.internal.ScenarioReader'));
                    if~isempty(foundBlkPath)
                        hScenarioReaderBlock=get_param(foundBlkPath{1},'Handle');
                        break;
                    end
                end
            end
        end

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header(...
            'Title','driving:scenarioReader:DialogTitle',...
            'Text','driving:scenarioReader:DialogText',...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl

            portUtil=getPropertyGroupsImpl@matlabshared.tracking.internal.SimulinkBusUtilities;
            groups=[getScenarioGroup(),getLanesGroup(),getPortsGroup(portUtil)];
        end


        function flag=checkStructForFields(s,expFields)


            flag=true;
            for i=1:numel(expFields)
                if~isfield(s,expFields{i})
                    flag=false;
                    return
                end
            end
        end

    end
end

function groupScenario=getScenarioGroup()


    scenarioPropList{1}=matlab.system.display.internal.Property(...
    'ScenarioSource','Description',getString(message('driving:scenarioReader:ScenarioSource')));
    scenarioPropList{2}=matlab.system.display.internal.Property(...
    'ScenarioFileName','Description',getString(message('driving:scenarioReader:ScenarioFileName')));
    scenarioPropList{3}=matlab.system.display.internal.Property(...
    'ScenarioVariableName','Description',getString(message('driving:scenarioReader:ScenarioVariableName')));
    scenarioPropList{4}=matlab.system.display.internal.Property(...
    'OutputCoordinateSystem','Description',getString(message('driving:scenarioReader:OutputCoordinateSystem')));
    scenarioPropList{5}=matlab.system.display.internal.Property(...
    'EgoVehicleSource','Description',getString(message('driving:scenarioReader:EgoVehicleSource')));
    scenarioPropList{6}=matlab.system.display.internal.Property(...
    'EgoVehicleActorID','Description',getString(message('driving:scenarioReader:EgoVehicleActorID')));
    scenarioPropList{7}=matlab.system.display.internal.Property(...
    'OrientVehiclesOnRoad','Description',getString(message('driving:scenarioReader:OrientVehiclesOnRoad')));
    scenarioPropList{8}=matlab.system.display.internal.Property(...
    'OutputEgoVehiclePose','Description',getString(message('driving:scenarioReader:OutputEgoVehiclePose')));
    scenarioPropList{9}=matlab.system.display.internal.Property(...
    'OutputEgoVehicleState','Description',getString(message('driving:scenarioReader:OutputEgoVehicleState')));
    scenarioPropList{10}=matlab.system.display.internal.Property(...
    'SampleTime','Description',getString(message('driving:scenarioReader:SampleTime')));
    groupScenario=matlab.system.display.Section(...
    'Title',getString(message('driving:scenarioReader:ScenarioSectionTitle')),...
    'PropertyList',scenarioPropList);
    groupScenario.Actions=matlab.system.display.Action(@(h,obj)browseButtonCallback(obj,h),...
    'Label',getString(message('driving:scenarioReader:Browse')),...
    'Placement','OutputCoordinateSystem','Alignment','right');
    matlab.system.display.internal.setCallbacks(groupScenario.Actions,...
    'IsEnabledFcn',@driving.scenario.internal.ScenarioReader.isBrowseEnabled);
end

function groupLanes=getLanesGroup()


    lanesPropList{1}=matlab.system.display.internal.Property(...
    'LaneBoundaryOutput','Description',getString(message('driving:scenarioReader:LaneBoundaryOutput')));
    lanesPropList{2}=matlab.system.display.internal.Property(...
    'LaneBoundaryDistance','Description',getString(message('driving:scenarioReader:LaneBoundaryDistance')));
    lanesPropList{3}=matlab.system.display.internal.Property(...
    'LaneBoundaryLocation','Description',getString(message('driving:scenarioReader:LaneBoundaryLocation')));
    groupLanes=matlab.system.display.Section(...
    'Title',getString(message('driving:scenarioReader:LanesSectionTitle')),...
    'PropertyList',lanesPropList);
end

function portUtil=getPortsGroup(portUtil)


    portPropList=portUtil.PropertyList;
    portPropList{1}.Description=getString(message('driving:scenarioReader:BusActorSource'));
    portPropList{2}.Description=getString(message('driving:scenarioReader:BusActorName'));
    portPropList{3}=matlab.system.display.internal.Property(...
    'BusNumActorsSource','Description',getString(message('driving:scenarioReader:BusNumActorsSource')));
    portPropList{4}=matlab.system.display.internal.Property(...
    'BusNumActors','Description',getString(message('driving:scenarioReader:BusNumActors')));
    portPropList{5}=matlab.system.display.internal.Property(...
    'BusName2Source','Description',getString(message('driving:scenarioReader:BusLaneBoundariesSource')));
    portPropList{6}=matlab.system.display.internal.Property(...
    'BusName2','Description',getString(message('driving:scenarioReader:BusLaneBoundariesName')));
    portPropList{7}=matlab.system.display.internal.Property(...
    'BusNumLaneBoundariesSource','Description',getString(message('driving:scenarioReader:BusNumLaneBoundariesSource')));
    portPropList{8}=matlab.system.display.internal.Property(...
    'BusNumLaneBoundaries','Description',getString(message('driving:scenarioReader:BusNumLaneBoundaries')));
    portPropList{9}=matlab.system.display.internal.Property(...
    'BusName3Source','Description',getString(message('driving:scenarioReader:BusEgoVehicleSource')));
    portPropList{10}=matlab.system.display.internal.Property(...
    'BusName3','Description',getString(message('driving:scenarioReader:BusEgoVehicleName')));
    portPropList{11}=matlab.system.display.internal.Property(...
    'BusName4Source','Description',getString(message('driving:scenarioReader:BusEgoVehicleStateSource')));
    portPropList{12}=matlab.system.display.internal.Property(...
    'BusName4','Description',getString(message('driving:scenarioReader:BusEgoVehicleStateName')));
    portPropList{13}=matlab.system.display.internal.Property(...
    'ShowCoordinateLabels','Description',getString(message('driving:scenarioReader:ShowCoordinateLabels')));
    portUtil.PropertyList=portPropList;
end
