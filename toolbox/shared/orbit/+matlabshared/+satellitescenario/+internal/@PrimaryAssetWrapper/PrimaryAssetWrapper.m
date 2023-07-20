classdef PrimaryAssetWrapper<matlabshared.satellitescenario.internal.AssetWrapper %#codegen




    properties(Dependent,SetAccess={?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.internal.Access})



Gimbals



ConicalSensors



Transmitters



Receivers


Accesses
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.internal.PrimaryAsset,...
        ?matlabshared.satellitescenario.internal.PrimaryAssetWrapper,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
pGimbalsAddedBefore
pConicalSensorsAddedBefore
pTransmittersAddedBefore
pReceiversAddedBefore
pAccessesAddedBefore
    end

    methods
        function c=get.ConicalSensors(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(asset,...
                {'matlabshared.satellitescenario.Satellite',...
                'matlabshared.satellitescenario.GroundStation',...
                'matlabshared.satellitescenario.ConicalSensor'},...
                {'scalar'},'get.ConicalSensors','ASSET');
                c=asset.Handles{1}.ConicalSensors;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                c=matlabshared.satellitescenario.ConicalSensor;
            else
                c=[handles.ConicalSensors];
            end
        end

        function asset=set.ConicalSensors(asset,c)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.ConicalSensors=c;
                return
            end

            handles=[asset.Handles{:}];
            handles.ConicalSensors=c;
        end

        function g=get.Gimbals(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(asset,...
                {'matlabshared.satellitescenario.Satellite',...
                'matlabshared.satellitescenario.GroundStation'},...
                {'scalar'},'get.Gimbals','ASSET');
                g=asset.Handles{1}.Gimbals;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                g=matlabshared.satellitescenario.Gimbal;
            else
                g=[handles.Gimbals];
            end
        end

        function asset=set.Gimbals(asset,g)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Gimbals=g;
                return
            end

            handles=[asset.Handles{:}];
            handles.Gimbals=g;
        end

        function tx=get.Transmitters(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(asset,...
                {'matlabshared.satellitescenario.Satellite',...
                'matlabshared.satellitescenario.GroundStation'},...
                {'scalar'},'get.Transmitters','ASSET');
                tx=asset.Handles{1}.Transmitters;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                tx=satcom.satellitescenario.Transmitter;
            else
                tx=[handles.Transmitters];
            end
        end

        function asset=set.Transmitters(asset,tx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Transmitters=tx;
                return
            end

            handles=[asset.Handles{:}];
            handles.Transmitters=tx;
        end

        function rx=get.Receivers(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(asset,...
                {'matlabshared.satellitescenario.Satellite',...
                'matlabshared.satellitescenario.GroundStation'},...
                {'scalar'},'get.Receivers','ASSET');
                rx=asset.Handles{1}.Receivers;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                rx=satcom.satellitescenario.Receiver;
            else
                rx=[handles.Receivers];
            end
        end

        function asset=set.Receivers(asset,rx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Receivers=rx;
                return
            end

            handles=[asset.Handles{:}];
            handles.Receivers=rx;
        end

        function ac=get.Accesses(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(asset,...
                {'matlabshared.satellitescenario.Satellite',...
                'matlabshared.satellitescenario.GroundStation',...
                'matlabshared.satellitescenario.ConicalSensor'},...
                {'scalar'},'get.Accesses','ASSET');
                ac=asset.Handles{1}.Accesses;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                ac=matlabshared.satellitescenario.Access;
            else
                ac=[handles.Accesses];
            end
        end

        function asset=set.Accesses(asset,ac)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Accesses=ac;
                return
            end

            handles=[asset.Handles{:}];
            handles.Accesses=ac;
        end

        function tf=get.pGimbalsAddedBefore(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=asset.Handles{1}.pGimbalsAddedBefore;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pGimbalsAddedBefore];
            end
        end

        function asset=set.pGimbalsAddedBefore(asset,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.pGimbalsAddedBefore=tf;
                return
            end

            handles=[asset.Handles{:}];
            handles.pGimbalsAddedBefore=tf;
        end

        function tf=get.pConicalSensorsAddedBefore(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=asset.Handles{1}.pConicalSensorsAddedBefore;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pConicalSensorsAddedBefore];
            end
        end

        function asset=set.pConicalSensorsAddedBefore(asset,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.pConicalSensorsAddedBefore=tf;
                return
            end

            handles=[asset.Handles{:}];
            handles.pConicalSensorsAddedBefore=tf;
        end

        function tf=get.pTransmittersAddedBefore(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=asset.Handles{1}.pTransmittersAddedBefore;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pTransmittersAddedBefore];
            end
        end

        function asset=set.pTransmittersAddedBefore(asset,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.pTransmittersAddedBefore=tf;
                return
            end

            handles=[asset.Handles{:}];
            handles.pTransmittersAddedBefore=tf;
        end

        function tf=get.pReceiversAddedBefore(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                tf=asset.Handles{1}.pReceiversAddedBefore;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                tf=false(0,0);
            else
                tf=[handles.pReceiversAddedBefore];
            end
        end

        function asset=set.pReceiversAddedBefore(asset,tf)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.pReceiversAddedBefore=tf;
                return
            end

            handles=[asset.Handles{:}];
            handles.pReceiversAddedBefore=tf;
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
        ac=access(source,varargin)
        sensors=conicalSensor(asset,varargin)
        gim=gimbal(asset,varargin)
        tx=transmitter(asset,varargin)
        rx=receiver(asset,varargin)
    end
end

