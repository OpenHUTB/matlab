classdef AssetWrapper<matlabshared.satellitescenario.internal.ObjectArray %#codegen




    properties(Dependent,SetAccess=private)



ID
    end

    properties(Dependent,Access=protected)
pName
    end

    properties(Dependent,Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.PrimaryAsset,...
        ?matlabshared.satellitescenario.internal.AttachedAsset,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?satcom.satellitescenario.internal.Link,...
        ?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.AssetWrapper})

Scenario
Simulator
SimulatorID
Type
    end

    properties(Dependent,Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.PrimaryAsset,...
        ?matlabshared.satellitescenario.internal.AttachedAsset,...
        ?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AssetWrapper})
pPosition
pPositionHistory
pVelocity
pVelocityHistory
pPositionITRF
pPositionITRFHistory
pVelocityITRF
pVelocityITRFHistory
pLatitude
pLatitudeHistory
pLongitude
pLongitudeHistory
pAltitude
pAltitudeHistory
pAttitude
pAttitudeHistory
pItrf2BodyTransform
pItrf2BodyTransformHistory
    end

    methods
        function id=get.ID(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                id=zeros(1,numel(obj.Handles));
                for idx=1:numel(obj.Handles)
                    id(idx)=obj.Handles{idx}.ID;
                end
                return
            end

            objHandles=[obj.Handles{:}];

            if isempty(objHandles)
                id=[];
            else
                id=[objHandles.ID];
            end
        end

        function position=get.pPosition(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                position=obj.Handles{1}.pPosition;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                position=zeros(3,0);
            else
                position=[handles.pPosition];
            end
        end

        function positionHistory=get.pPositionHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                positionHistory=obj.Handles{1}.pPositionHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                positionHistory=zeros(3,0);
            else
                positionHistory=[handles.pPositionHistory];
            end
        end

        function velocity=get.pVelocity(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                velocity=obj.Handles{1}.pVelocity;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                velocity=zeros(3,0);
            else
                velocity=[handles.pVelocity];
            end
        end

        function velocityHistory=get.pVelocityHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                velocityHistory=obj.Handles{1}.pVelocityHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                velocityHistory=zeros(3,0);
            else
                velocityHistory=[handles.pVelocityHistory];
            end
        end

        function positionITRF=get.pPositionITRF(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                positionITRF=obj.Handles{1}.pPositionITRF;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                positionITRF=zeros(3,0);
            else
                positionITRF=[handles.pPositionITRF];
            end
        end

        function positionITRFHistory=get.pPositionITRFHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                positionITRFHistory=obj.Handles{1}.pPositionITRFHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                positionITRFHistory=zeros(3,0);
            else
                positionITRFHistory=[handles.pPositionITRFHistory];
            end
        end

        function velocityITRF=get.pVelocityITRF(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                velocityITRF=obj.Handles{1}.pVelocityITRF;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                velocityITRF=zeros(3,0);
            else
                velocityITRF=[handles.pVelocityITRF];
            end
        end

        function velocityITRFHistory=get.pVelocityITRFHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                velocityITRFHistory=obj.Handles{1}.pVelocityITRFHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                velocityITRFHistory=zeros(3,0);
            else
                velocityITRFHistory=[handles.pVelocityITRFHistory];
            end
        end

        function latitude=get.pLatitude(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                latitude=obj.Handles{1}.pLatitude;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                latitude=[];
            else
                latitude=[handles.pLatitude];
            end
        end

        function latitudeHistory=get.pLatitudeHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                latitudeHistory=obj.Handles{1}.pLatitudeHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                latitudeHistory=[];
            else
                latitudeHistory=[handles.pLatitudeHistory];
            end
        end

        function longitude=get.pLongitude(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                longitude=obj.Handles{1}.pLongitude;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                longitude=[];
            else
                longitude=[handles.pLongitude];
            end
        end

        function longitudeHistory=get.pLongitudeHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                longitudeHistory=obj.Handles{1}.pLongitudeHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                longitudeHistory=[];
            else
                longitudeHistory=[handles.pLongitudeHistory];
            end
        end

        function altitude=get.pAltitude(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                altitude=obj.Handles{1}.pAltitude;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                altitude=[];
            else
                altitude=[handles.pAltitude];
            end
        end

        function altitudeHistory=get.pAltitudeHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                altitudeHistory=obj.Handles{1}.pAltitudeHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                altitudeHistory=[];
            else
                altitudeHistory=[handles.pAltitudeHistory];
            end
        end

        function attitude=get.pAttitude(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                attitude=obj.Handles{1}.pAttitude;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                attitude=zeros(3,0);
            else
                attitude=[handles.pAttitude];
            end
        end

        function attitudeHistory=get.pAttitudeHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                attitudeHistory=obj.Handles{1}.pAttitudeHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                attitudeHistory=zeros(3,0);
            else
                attitudeHistory=[handles.pAttitudeHistory];
            end
        end

        function itrf2bodyTransform=get.pItrf2BodyTransform(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                itrf2bodyTransform=obj.Handles{1}.pItrf2BodyTransform;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                itrf2bodyTransform=zeros(3,3,0);
            else
                itrf2bodyTransform=[handles.pItrf2BodyTransform];
            end
        end

        function itrf2bodyTransformHistory=get.pItrf2BodyTransformHistory(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                itrf2bodyTransformHistory=obj.Handles{1}.pItrf2BodyTransformHistory;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                itrf2bodyTransformHistory=zeros(3,3,0);
            else
                itrf2bodyTransformHistory=[handles.pItrf2BodyTransformHistory];
            end
        end

        function sc=get.Scenario(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                sc=obj.Handles{1}.Scenario;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                sc=satelliteScenario.empty;
            else
                sc=[handles.Scenario];
            end
        end

        function obj=set.Scenario(obj,sc)


            coder.allowpcode('plain');

            obj.Handles{1}.Scenario=sc;
        end

        function s=get.Simulator(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                s=obj.Handles{1}.Simulator;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                s=matlabshared.satellitescenario.internal.Simulator.empty;
            else
                s=[handles.Simulator];
            end
        end

        function obj=set.Simulator(obj,s)


            coder.allowpcode('plain');

            obj.Handles{1}.Simulator=s;
        end

        function id=get.SimulatorID(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                id=obj.Handles{1}.SimulatorID;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                id=[];
            else
                id=[handles.SimulatorID];
            end
        end

        function obj=set.SimulatorID(obj,id)


            coder.allowpcode('plain');

            obj.Handles{1}.SimulatorID=id;
        end

        function t=get.Type(obj)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                t=obj.Handles{1}.Type;
                return
            end

            handles=[obj.Handles{:}];

            if isempty(handles)
                t=[];
            else
                t=[handles.Type];
            end
        end

        function obj=set.Type(obj,t)


            coder.allowpcode('plain');

            obj.Handles{1}.Type=t;
        end

        function t=get.pName(obj)


            coder.allowpcode('plain');

            handles=[obj.Handles{:}];

            if isempty(handles)
                t=[];
            else
                t=[handles.pName];
            end
        end

        function obj=set.pName(obj,t)


            coder.allowpcode('plain');

            obj.Handles{1}.pName=t;
        end
    end

    methods(Hidden)
        function idx=getIdxInSimulatorStruct(obj)



            coder.allowpcode('plain');

            idx=getIdxInSimulatorStruct(obj.Handles{1});
        end
    end

    methods(Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG})
        [az,el,r]=currentAzimuthAndElevationAngle(obj,target,varargin)
    end

    methods
        [az,el,r,time]=aer(obj,target,varargin)
    end
end

