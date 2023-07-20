classdef Gimbal<matlabshared.satellitescenario.internal.AttachedAssetWrapper %#codegen





    properties(Dependent,SetAccess=protected)

















Name
    end

    properties(Dependent,SetAccess={?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.internal.Access})


ConicalSensors


Transmitters


Receivers
    end

    properties(Dependent,Access=private)
GimbalAzimuth
GimbalElevation
GimbalAzimuthHistory
GimbalElevationHistory
    end

    properties(Dependent,Access=private)
PointingTarget



    end

    properties(Dependent,Access={?matlabshared.satellitescenario.Gimbal,...
        ?matlabshared.satellitescenario.coder.Gimbal,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
pConicalSensorsAddedBefore
pTransmittersAddedBefore
pReceiversAddedBefore
    end

    methods(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function gim=Gimbal(varargin)


            coder.allowpcode('plain');


            if~coder.target('MATLAB')
                gim.Handles={matlabshared.satellitescenario.internal.Gimbal};
                gim.Handles=cell(1,0);
            else
                gim.Handles=cell(1,0);
            end

            if nargin~=0


                handles={matlabshared.satellitescenario.internal.Gimbal(...
                varargin{:})};


                gim.Handles=handles;
            end
        end
    end

    methods
        function name=get.Name(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(gim,...
                {'matlabshared.satellitescenario.Gimbal'},...
                {'scalar'},'get.Name','gim');
                name=gim.Handles{1}.Name;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                name=strings(0,0);
            else
                name=[handles.Name];
            end
        end

        function sensors=get.ConicalSensors(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(gim,...
                {'matlabshared.satellitescenario.Gimbal'},...
                {'scalar'},'get.ConicalSensors','gim');
                sensors=gim.Handles{1}.ConicalSensors;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                sensors=matlabshared.satellitescenario.ConicalSensor;
            else
                sensors=[handles.ConicalSensors];
            end
        end

        function gim=set.ConicalSensors(gim,sensors)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gim.Handles{1}.ConicalSensors=sensors;
                return
            end

            handles=[gim.Handles{:}];
            handles.ConicalSensors=sensors;
        end

        function tx=get.Transmitters(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(gim,...
                {'matlabshared.satellitescenario.Gimbal'},...
                {'scalar'},'get.Transmitters','gim');
                tx=gim.Handles{1}.Transmitters;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                tx=satcom.satellitescenario.Transmitter;
            else
                tx=[handles.Transmitters];
            end
        end

        function gim=set.Transmitters(gim,tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gim.Handles{1}.Transmitters=tx;
                return
            end

            handles=[gim.Handles{:}];
            handles.Transmitters=tx;
        end

        function rx=get.Receivers(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(gim,...
                {'matlabshared.satellitescenario.Gimbal'},...
                {'scalar'},'get.Receivers','gim');
                rx=gim.Handles{1}.Receivers;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                rx=satcom.satellitescenario.Receiver;
            else
                rx=[handles.Receivers];
            end
        end

        function gim=set.Receivers(gim,rx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gim.Handles{1}.Receivers=rx;
                return
            end

            handles=[gim.Handles{:}];
            handles.Receivers=rx;
        end

        function gimbalAzimuth=get.GimbalAzimuth(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gimbalAzimuth=gim.Handles{1}.GimbalAzimuth;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                gimbalAzimuth=[];
            else
                gimbalAzimuth=[handles.GimbalAzimuth];
            end
        end

        function gimbalElevation=get.GimbalElevation(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gimbalElevation=gim.Handles{1}.GimbalElevation;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                gimbalElevation=[];
            else
                gimbalElevation=[handles.GimbalElevation];
            end
        end

        function gimbalAzimuthHistory=get.GimbalAzimuthHistory(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gimbalAzimuthHistory=gim.Handles{1}.GimbalAzimuthHistory;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                gimbalAzimuthHistory=[];
            else
                gimbalAzimuthHistory=[handles.GimbalAzimuthHistory];
            end
        end

        function gimbalElevationHistory=get.GimbalElevationHistory(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gimbalElevationHistory=gim.Handles{1}.GimbalElevationHistory;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                gimbalElevationHistory=[];
            else
                gimbalElevationHistory=[handles.GimbalElevationHistory];
            end
        end

        function target=get.PointingTarget(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                target=gim.Handles{1}.PointingTarget;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                target=[];
            else
                target=[handles.PointingTarget];
            end
        end

        function gim=set.PointingTarget(gim,target)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gim.Handles{1}.PointingTarget=target;
                return
            end

            handles=[gim.Handles{:}];
            handles.PointingTarget=target;
        end

        function tf=get.pConicalSensorsAddedBefore(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=gim.Handles{1}.pConicalSensorsAddedBefore;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pConicalSensorsAddedBefore];
            end
        end

        function gim=set.pConicalSensorsAddedBefore(gim,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gim.Handles{1}.pConicalSensorsAddedBefore=tf;
                return
            end

            handles=[gim.Handles{:}];
            handles.pConicalSensorsAddedBefore=tf;
        end

        function tf=get.pTransmittersAddedBefore(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=gim.Handles{1}.pTransmittersAddedBefore;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pTransmittersAddedBefore];
            end
        end

        function gim=set.pTransmittersAddedBefore(gim,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gim.Handles{1}.pTransmittersAddedBefore=tf;
                return
            end

            handles=[gim.Handles{:}];
            handles.pTransmittersAddedBefore=tf;
        end

        function tf=get.pReceiversAddedBefore(gim)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=gim.Handles{1}.pReceiversAddedBefore;
                return
            end

            handles=[gim.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pReceiversAddedBefore];
            end
        end

        function gim=set.pReceiversAddedBefore(gim,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                gim.Handles{1}.pReceiversAddedBefore=tf;
                return
            end

            handles=[gim.Handles{:}];
            handles.pReceiversAddedBefore=tf;
        end
    end

    methods(Static,Access={?matlabshared.satellitescenario.internal.Simulator})
        [positionITRF,positionGeographic,attitude,itrf2BodyTransform,ned2bodyTransform,steeringAngles]=...
        getPositionOrientationAndSteeringAngles(mountingLocation,mountingAngles,...
        parentItrf2BodyTransform,parentPositionITRF,...
        parentNed2BodyTransform,targetPositionITRF,needToSteer)

        [positionITRFHistory,positionGeographicHistory,attitudeHistory,...
        itrf2BodyTransformHistory,ned2bodyTransformHistory,steeringAnglesHistory]=...
        cg_getPositionOrientationAndSteeringAngles(mountingLocation,mountingAngles,...
        parentItrf2BodyTransformHistory,parentPositionITRFHistory,...
        parentNed2BodyTransformHistory,targetPositionITRFHistory,needToSteer)
    end

    methods
        pointAt(gim,target)
        sensors=conicalSensor(gim,varargin)
        [az,el,time]=gimbalAngles(gim,varargin)
        tx=transmitter(gim,varargin)
        rx=receiver(asset,varargin)
    end

    methods(Hidden)
        disp(gim)
    end

    methods(Hidden,Static)
        function gim=loadobj(s)


            coder.allowpcode('plain');

            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                gim=s;
            else





                gim=matlabshared.satellitescenario.Gimbal;

                if isfield(s,'Handles')


                    gim.Handles=s.Handles;
                else





                    gimHandle=matlabshared.satellitescenario.internal.Gimbal;
                    gim.Handles={gimHandle};

                    if isa(s.ConicalSensors,'double')




                        gimHandle.ConicalSensors=matlabshared.satellitescenario.ConicalSensor;
                    else







                        handles=[s.ConicalSensors.Handles];
                        if~isempty(handles)
                            gimHandle.pConicalSensorsAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gim;
                        end



                        cs=matlabshared.satellitescenario.ConicalSensor;
                        cs.Handles=handles;



                        gimHandle.ConicalSensors=cs;
                    end

                    if isa(s.Transmitters,'double')




                        gimHandle.Transmitters=satcom.satellitescenario.Transmitter;
                    else







                        handles=[s.Transmitters.Handles];
                        if~isempty(handles)
                            gimHandle.pTransmittersAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gim;
                        end



                        tx=satcom.satellitescenario.Transmitter;
                        tx.Handles=handles;



                        gimHandle.Transmitters=tx;
                    end

                    if isa(s.Receivers,'double')




                        gimHandle.Receivers=satcom.satellitescenario.Receiver;
                    else







                        handles=[s.Receivers.Handles];
                        if~isempty(handles)
                            gimHandle.pReceiversAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=gim;
                        end



                        rx=satcom.satellitescenario.Receiver;
                        rx.Handles=handles;



                        gimHandle.Receivers=rx;
                    end


                    gimHandle.ParentSimulatorID=s.ParentSimulatorID;
                    gimHandle.ParentType=s.ParentType;
                    gimHandle.Graphic=s.Graphic;
                    gimHandle.pMarkerColor=s.pMarkerColor;
                    gimHandle.pName=s.pName;
                    gimHandle.Simulator=s.Simulator;
                    gimHandle.SimulatorID=s.SimulatorID;
                    gimHandle.Type=s.Type;
                    gimHandle.VisibilityMode=s.VisibilityMode;
                    gimHandle.pMarkerSize=s.pMarkerSize;
                    gimHandle.ZoomHeight=s.ZoomHeight;
                    gimHandle.ColorConverter=s.ColorConverter;

                    if~isempty(s.Parent)



                        gimHandle.Parent=s.Parent;
                        s.Parent.Gimbals=[s.Parent.Gimbals,gim];



                        ids=s.Parent.Gimbals.ID;
                        [~,sortIdx]=sort(ids);
                        s.Parent.Gimbals=s.Parent.Gimbals(sortIdx);
                    end
                end
            end
        end
    end
end

