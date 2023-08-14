classdef CommDeviceWrapper<matlabshared.satellitescenario.internal.AttachedAssetWrapper %#codegen




    properties(Dependent)

























SystemLoss
    end

    properties(Dependent,SetAccess=protected)
















Antenna
    end

    properties(Dependent,SetAccess=?satcom.satellitescenario.Pattern)



Pattern
    end

    properties(Dependent,Hidden)
AntennaPatternResolution
    end

    properties(Dependent,Access=private)
PointingTarget




    end

    methods
        function loss=get.SystemLoss(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(asset.Handles);


                loss=zeros(1,numAssets);


                for idx=1:numAssets
                    loss(idx)=asset.Handles{idx}.SystemLoss;
                end

                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                loss=[];
            else
                loss=[handles.SystemLoss];
            end
        end

        function asset=set.SystemLoss(asset,loss)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'SystemLoss',class(asset));
            end

            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).SystemLoss=loss;
            end
        end

        function an=get.Antenna(asset)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(asset,...
                {'satcom.satellitescenario.Transmitter',...
                'satcom.satellitescenario.Receiver'},...
                {'scalar'},'get.Antenna','ASSET');
                an=asset.Handles{1}.Antenna;
                return
            end

            handles=[asset.Handles{:}];

            if isempty(handles)
                an=satcom.satellitescenario.GaussianAntenna.empty;
            else
                validateattributes(asset,{'satcom.satellitescenario.Transmitter',...
                'satcom.satellitescenario.Receiver'},{'scalar'},...
                'get.Antenna','ASSET',1);
                an=handles.Antenna;
            end
        end

        function asset=set.Antenna(asset,an)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                asset.Handles{1}.Antenna=an;
                return
            end

            validateattributes(asset,{'satcom.satellitescenario.Transmitter',...
            'satcom.satellitescenario.Receiver'},{'scalar'},...
            'set.Antenna','ASSET',1);

            handles=[asset.Handles{:}];
            handles.Antenna=an;
        end

        function an=get.Pattern(asset)


            handles=[asset.Handles{:}];

            if isempty(handles)
                an=satcom.satellitescenario.Pattern.empty;
            else
                an=[handles.Pattern];
            end
        end

        function asset=set.Pattern(asset,an)


            handles=[asset.Handles{:}];
            handles.Pattern=an;
        end

        function r=get.AntennaPatternResolution(asset)


            handles=[asset.Handles{:}];

            if isempty(handles)
                r=[];
            else
                r=[handles.AntennaPatternResolution];
            end
        end

        function asset=set.AntennaPatternResolution(asset,r)


            handles=[asset.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).AntennaPatternResolution=r;
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
    end

    methods(Hidden)
        function pat=createPattern(trx,fq,varargin)


            handles=[trx.Handles{:}];
            pat=createPattern(handles,fq,varargin{:});
        end
    end

    methods
        an=gaussianAntenna(trx,varargin)
        pointAt(trx,varargin)
    end
end

