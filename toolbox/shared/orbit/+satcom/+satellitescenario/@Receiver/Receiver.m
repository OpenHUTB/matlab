classdef Receiver<satcom.satellitescenario.internal.CommDeviceWrapper %#codegen




    properties(Dependent,SetAccess=protected)

















Name
    end

    properties(Dependent)

















RequiredEbNo



















GainToNoiseTemperatureRatio


























PreReceiverLoss
    end

    methods
        pat=pattern(rx,fq,varargin)
    end

    methods(Hidden)
        disp(rx)
    end

    methods(Access={?satelliteScenario,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.ScenarioGraphic})
        function rx=Receiver(varargin)


            coder.allowpcode('plain');


            if~coder.target('MATLAB')
                rx.Handles={satcom.satellitescenario.internal.Receiver};
                rx.Handles=cell(1,0);
            else
                rx.Handles=cell(1,0);
            end

            if nargin~=0


                handles={satcom.satellitescenario.internal.Receiver(...
                varargin{:})};


                rx.Handles=handles;
            end
        end
    end

    methods
        function name=get.Name(rx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                validateattributes(rx,...
                {'satcom.satellitescenario.Receiver'},...
                {'scalar'},'get.Name','RX');
                name=rx.Handles{1}.Name;
                return
            end

            handles=[rx.Handles{:}];

            if isempty(handles)
                name=string.empty;
            else
                name=[handles.Name];
            end
        end

        function reqEbNo=get.RequiredEbNo(rx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(rx.Handles);


                reqEbNo=zeros(1,numAssets);


                for idx=1:numAssets
                    reqEbNo(idx)=rx.Handles{idx}.RequiredEbNo;
                end

                return
            end

            handles=[rx.Handles{:}];

            if isempty(handles)
                reqEbNo=[];
            else
                reqEbNo=[handles.RequiredEbNo];
            end
        end

        function rx=set.RequiredEbNo(rx,reqEbNo)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'RequiredEbNo','satcom.satellitescenario.Receiver');
            end

            handles=[rx.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).RequiredEbNo=reqEbNo;
            end
        end

        function gbyt=get.GainToNoiseTemperatureRatio(rx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(rx.Handles);


                gbyt=zeros(1,numAssets);


                for idx=1:numAssets
                    gbyt(idx)=rx.Handles{idx}.GainToNoiseTemperatureRatio;
                end

                return
            end

            handles=[rx.Handles{:}];

            if isempty(handles)
                gbyt=[];
            else
                gbyt=[handles.GainToNoiseTemperatureRatio];
            end
        end

        function rx=set.GainToNoiseTemperatureRatio(rx,gbyt)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'GainToNoiseTemperatureRatio','satcom.satellitescenario.Receiver');
            end

            handles=[rx.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).GainToNoiseTemperatureRatio=gbyt;
            end
        end

        function l=get.PreReceiverLoss(rx)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')

                numAssets=numel(rx.Handles);


                l=zeros(1,numAssets);


                for idx=1:numAssets
                    l(idx)=rx.Handles{idx}.PreReceiverLoss;
                end

                return
            end

            handles=[rx.Handles{:}];

            if isempty(handles)
                l=[];
            else
                l=[handles.PreReceiverLoss];
            end
        end

        function rx=set.PreReceiverLoss(rx,l)


            coder.allowpcode('plain');

            if~coder.target('MATLAB')
                msg='shared_orbit:orbitPropagator:UnsupportedPropertySetCodegen';
                coder.internal.error(msg,'PreReceiverLoss','satcom.satellitescenario.Receiver');
            end

            handles=[rx.Handles{:}];
            for idx=1:numel(handles)
                handles(idx).PreReceiverLoss=l;
            end
        end
    end

    methods(Hidden,Static)
        function rx=loadobj(s)


            coder.allowpcode('plain');

            if isa(s,'matlabshared.satellitescenario.internal.ObjectArray')


                rx=s;
            else





                rx=satcom.satellitescenario.Receiver;

                if isfield(s,'Handles')


                    rx.Handles=s.Handles;
                else





                    rxHandle=satcom.satellitescenario.internal.Receiver;
                    rx.Handles={rxHandle};


                    rxHandle.Antenna=s.Antenna;
                    rxHandle.ParentSimulatorID=s.ParentSimulatorID;
                    rxHandle.ParentType=s.ParentType;
                    rxHandle.Graphic=s.Graphic;
                    rxHandle.pMarkerColor=s.pMarkerColor;
                    rxHandle.pName=s.pName;
                    rxHandle.Simulator=s.Simulator;
                    rxHandle.SimulatorID=s.SimulatorID;
                    rxHandle.Type=s.Type;
                    rxHandle.VisibilityMode=s.VisibilityMode;
                    rxHandle.pMarkerSize=s.pMarkerSize;
                    rxHandle.ZoomHeight=s.ZoomHeight;
                    rxHandle.ColorConverter=s.ColorConverter;

                    if~isempty(s.Parent)



                        rxHandle.Parent=s.Parent;
                        s.Parent.Receivers=[s.Parent.Receivers,rx];



                        ids=s.Parent.Receivers.ID;
                        [~,sortIdx]=sort(ids);
                        s.Parent.Receivers=s.Parent.Receivers(sortIdx);
                    end
                end
            end
        end
    end
end

