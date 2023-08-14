classdef ConicalSensor<matlabshared.satellitescenario.internal.AttachedAssetWrapper %#codegen




    properties(Dependent,SetAccess=protected)


















Name
    end

    properties(Dependent,SetAccess={?satelliteScenario,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.internal.Access})


Accesses
    end

    properties(Dependent)


















MaxViewAngle
    end

    properties(Dependent,SetAccess={?matlabshared.satellitescenario.Satellite,...
        ?matlabshared.satellitescenario.GroundStation,?matlabshared.satellitescenario.Gimbal,...
        ?matlabshared.satellitescenario.Viewer})


FieldOfView
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
pAccessesAddedBefore
    end

    methods(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AssetWrapper,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG})
        function sensor=ConicalSensor(varargin)


            coder.allowpcode('plain');


            if~coder.target('MATLAB')
                sensor.Handles={matlabshared.satellitescenario.internal.ConicalSensor};
                sensor.Handles=cell(1,0);
            else
                sensor.Handles=cell(1,0);
            end

            if nargin~=0


                handles={matlabshared.satellitescenario.internal.ConicalSensor(...
                varargin{:})};


                sensor.Handles=handles;
            end
        end
    end

    methods
        function name=get.Name(sensor)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(sensor,...
                {'matlabshared.satellitescenario.ConicalSensor'},...
                {'scalar'},'get.Name','SENSOR');
                name=sensor.Handles{1}.Name;
                return
            end

            handles=[sensor.Handles{:}];

            if isempty(handles)
                name=strings(0,0);
            else
                name=[handles.Name];
            end
        end

        function maxViewAngle=get.MaxViewAngle(sensor)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                n=numel(sensor.Handles);
                maxViewAngle=zeros(1,n);
                for idx=1:n
                    maxViewAngle(idx)=sensor.Handles{idx}.MaxViewAngle;
                end
                return
            end

            handles=[sensor.Handles{:}];

            if isempty(handles)
                maxViewAngle=[];
            else
                maxViewAngle=[handles.MaxViewAngle];
            end
        end

        function sensor=set.MaxViewAngle(sensor,maxViewAngle)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'MaxViewAngle','matlabshared.satellitescenario.ConicalSensor');
            end

            handles=[sensor.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).MaxViewAngle=maxViewAngle;
            end
        end

        function ac=get.Accesses(sensor)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(sensor,...
                {'matlabshared.satellitescenario.ConicalSensor'},...
                {'scalar'},'get.Accesses','SENSOR');
                ac=sensor.Handles{1}.Accesses;
                return
            end

            handles=[sensor.Handles{:}];

            if isempty(handles)
                ac=matlabshared.satellitescenario.Access;
            else
                ac=[handles.Accesses];
            end
        end

        function sensor=set.Accesses(sensor,ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                sensor.Handles{1}.Accesses=ac;
                return
            end

            handles=[sensor.Handles{:}];
            handles.Accesses=ac;
        end

        function fov=get.FieldOfView(sensor)


            handles=[sensor.Handles{:}];

            if isempty(handles)
                fov=matlabshared.satellitescenario.FieldOfView.empty;
            else
                fov=[handles.FieldOfView];
            end
        end

        function sensor=set.FieldOfView(sensor,fov)


            handles=[sensor.Handles{:}];
            handles.FieldOfView=fov;
        end

        function tf=get.pAccessesAddedBefore(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=asset.Handles{1}.pAccessesAddedBefore;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pAccessesAddedBefore];
            end
        end

        function asset=set.pAccessesAddedBefore(asset,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.pAccessesAddedBefore=tf;
                return
            end

            handles=[asset.Handles{:}];
            handles.pAccessesAddedBefore=tf;
        end
    end

    methods
        fov=fieldOfView(s,varargin)
    end

    methods(Hidden)
        disp(sensor)
    end

    methods(Hidden,Static)
        function sensor=loadobj(s)


            coder.allowpcode('plain');

            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                sensor=s;
            else





                sensor=matlabshared.satellitescenario.ConicalSensor;

                if isfield(s,'Handles')


                    sensor.Handles=s.Handles;
                else





                    sensorHandle=matlabshared.satellitescenario.internal.ConicalSensor;
                    sensor.Handles={sensorHandle};

                    if isa(s.Accesses,'double')




                        sensorHandle.Accesses=matlabshared.satellitescenario.Access;
                    else







                        handles=[s.Accesses.Handles];
                        if~isempty(handles)
                            sensorHandle.pAccessesAddedBefore=true;
                            handles=reshape(handles,1,[]);
                        end



                        for idx=1:numel(handles)
                            handles{idx}.Parent=sensor;
                        end



                        ac=matlabshared.satellitescenario.Access;
                        ac.Handles=handles;



                        sensorHandle.Accesses=ac;
                    end


                    sensorHandle.FieldOfView=s.FieldOfView;
                    sensorHandle.ParentSimulatorID=s.ParentSimulatorID;
                    sensorHandle.ParentType=s.ParentType;
                    sensorHandle.Graphic=s.Graphic;
                    sensorHandle.pMarkerColor=s.pMarkerColor;
                    sensorHandle.pName=s.pName;
                    sensorHandle.Simulator=s.Simulator;
                    sensorHandle.SimulatorID=s.SimulatorID;
                    sensorHandle.Type=s.Type;
                    sensorHandle.VisibilityMode=s.VisibilityMode;
                    sensorHandle.pMarkerSize=s.pMarkerSize;
                    sensorHandle.ZoomHeight=s.ZoomHeight;
                    sensorHandle.ColorConverter=s.ColorConverter;


                    if~isempty(s.Parent)



                        sensorHandle.Parent=s.Parent;
                        s.Parent.ConicalSensors=[s.Parent.ConicalSensors,sensor];



                        ids=s.Parent.ConicalSensors.ID;
                        [~,sortIdx]=sort(ids);
                        s.Parent.ConicalSensors=s.Parent.ConicalSensors(sortIdx);
                    end
                end
            end
        end
    end
end

