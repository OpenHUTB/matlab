classdef AttachedAssetWrapper<matlabshared.satellitescenario.internal.AssetWrapper %#codegen





    properties(Dependent)

























MountingLocation





























MountingAngles
    end

    properties(Hidden,Dependent,SetAccess=private)
Position
PositionHistory
Velocity
VelocityHistory
Attitude
AttitudeHistory
    end

    properties(Hidden,Dependent,SetAccess=protected)
Parent
    end

    properties(Dependent,Access=protected)
ParentSimulatorID
ParentType
    end

    properties(Dependent,Hidden)
VisibilityMode
    end

    properties(Dependent,Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.ScenarioGraphic,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AttachedAssetWrapper,...
        ?matlabshared.satellitescenario.ConicalSensor,?matlabshared.satellitescenario.Gimbal,...
        ?satcom.satellitescenario.Transmitter,...
        ?satcom.satellitescenario.Receiver})
Graphic
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.internal.AttachedAssetWrapper,...
        ?matlabshared.satellitescenario.ConicalSensor,?matlabshared.satellitescenario.Gimbal,...
        ?satcom.satellitescenario.Transmitter,...
        ?satcom.satellitescenario.Receiver})
pMarkerColor
pMarkerSize
    end

    methods
        function mountingLocation=get.MountingLocation(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(asset.Handles);


                mountingLocation=zeros(3,numAssets);


                for idx=1:numAssets
                    mountingLocation(:,idx)=asset.Handles{idx}.MountingLocation;
                end

                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                mountingLocation=zeros(3,0);
            else
                mountingLocation=[handles.MountingLocation];
            end
        end

        function asset=set.MountingLocation(asset,mountingLocation)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'MountingLocation',class(asset));
            end

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).MountingLocation=mountingLocation;
            end
        end

        function mountingAngles=get.MountingAngles(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(asset.Handles);


                mountingAngles=zeros(3,numAssets);


                for idx=1:numAssets
                    mountingAngles(:,idx)=asset.Handles{idx}.MountingAngles;
                end

                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                mountingAngles=zeros(3,0);
            else
                mountingAngles=[handles.MountingAngles];
            end
        end

        function asset=set.MountingAngles(asset,mountingAngles)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'MountingAngles',class(asset));
            end

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).MountingAngles=mountingAngles;
            end
        end

        function p=get.Position(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                p=asset.Handles{1}.Position;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                p=zeros(3,0);
            else
                p=[handles.Position];
            end
        end

        function asset=set.Position(asset,p)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Position=p;
                return
            end

            handles=[asset.Handles{:}];
            handles.Position=p;
        end

        function p=get.PositionHistory(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                p=asset.Handles{1}.PositionHistory;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                p=zeros(3,0);
            else
                p=[handles.PositionHistory];
            end
        end

        function asset=set.PositionHistory(asset,p)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.PositionHistory=p;
                return
            end

            handles=[asset.Handles{:}];
            handles.PositionHistory=p;
        end

        function v=get.Velocity(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                v=asset.Handles{1}.Velocity;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                v=zeros(3,0);
            else
                v=[handles.Velocity];
            end
        end

        function asset=set.Velocity(asset,v)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Velocity=v;
                return
            end

            handles=[asset.Handles{:}];
            handles.Velocity=v;
        end

        function v=get.VelocityHistory(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                v=asset.Handles{1}.VelocityHistory;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                v=zeros(3,0);
            else
                v=[handles.VelocityHistory];
            end
        end

        function asset=set.VelocityHistory(asset,v)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.VelocityHistory=v;
                return
            end

            handles=[asset.Handles{:}];
            handles.VelocityHistory=v;
        end

        function a=get.Attitude(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                a=asset.Handles{1}.Attitude;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                a=zeros(3,0);
            else
                a=[handles.Attitude];
            end
        end

        function asset=set.Attitude(asset,a)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Attitude=a;
                return
            end

            handles=[asset.Handles{:}];
            handles.Attitude=a;
        end

        function a=get.AttitudeHistory(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                a=asset.Handles{1}.AttitudeHistory;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                a=zeros(3,0);
            else
                a=[handles.AttitudeHistory];
            end
        end

        function asset=set.AttitudeHistory(asset,a)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.AttitudeHistory=a;
                return
            end

            handles=[asset.Handles{:}];
            handles.AttitudeHistory=a;
        end

        function p=get.Parent(asset)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];

            if isempty(handles)
                p=matlabshared.satellitescenario.internal.AssetWrapper;
            else
                p=[handles.Parent];
            end
        end

        function asset=set.Parent(asset,p)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];
            handles.Parent=p;
        end

        function p=get.ParentSimulatorID(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                p=asset.Handles{1}.ParentSimulatorID;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                p=[];
            else
                p=[handles.ParentSimulatorID];
            end
        end

        function asset=set.ParentSimulatorID(asset,p)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.ParentSimulatorID=p;
                return
            end

            handles=[asset.Handles{:}];
            handles.ParentSimulatorID=p;
        end

        function p=get.ParentType(asset)


            if~coder.target('MATLAB')
                p=asset.Handles{1}.ParentType;
                return
            end

            coder.allowpcode('plain');

            handles=[asset.Handles{:}];

            if isempty(handles)
                p=[];
            else
                p=[handles.ParentType];
            end
        end

        function asset=set.ParentType(asset,p)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.ParentType=p;
                return
            end

            handles=[asset.Handles{:}];
            handles.ParentType=p;
        end

        function v=get.VisibilityMode(asset)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];

            if isempty(handles)
                v=char.empty;
            else
                v=[handles.VisibilityMode];
            end
        end

        function asset=set.VisibilityMode(asset,v)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).VisibilityMode=v;
            end
        end

        function g=get.Graphic(asset)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];

            if isempty(handles)
                g=string.empty;
            else
                g=[handles.Graphic];
            end
        end

        function asset=set.Graphic(asset,g)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];
            handles.Graphic=g;
        end

        function c=get.pMarkerColor(asset)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];

            if isempty(handles)
                c=[];
            else
                c=[handles.pMarkerColor];
            end
        end

        function asset=set.pMarkerColor(asset,c)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];
            handles.pMarkerColor=c;
        end

        function s=get.pMarkerSize(asset)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];

            if isempty(handles)
                s=[];
            else
                s=[handles.pMarkerSize];
            end
        end

        function asset=set.pMarkerSize(asset,s)


            coder.allowpcode('plain');

            handles=[asset.Handles{:}];
            handles.pMarkerSize=s;
        end
    end
end

