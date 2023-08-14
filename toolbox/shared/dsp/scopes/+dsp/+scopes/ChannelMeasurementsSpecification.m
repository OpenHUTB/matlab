classdef ChannelMeasurementsSpecification<dsp.scopes.AbstractMeasurementsSpecification


































































    properties(AbortSet,Dependent)



        Algorithm;




        FrequencySpan;





        Span;






        CenterFrequency;







        StartFrequency;







        StopFrequency;






        PercentOccupiedBW;




        NumOffsets;




        AdjacentBW;




        FilterShape;





        FilterCoeff;






        ACPROffsets;
    end

    events(Hidden)
ChannelMeasurementsUpdated
    end

    properties(Constant,Hidden)

        AlgorithmSet={'Occupied BW','ACPR'};
        FrequencySpanSet={'Span and center frequency','Start and stop frequency'};
        FilterShapeSet={'None','Gaussian','RRC'};
    end

    properties(Access=protected)
        MeasurerName='channel'
    end

    methods

        function obj=ChannelMeasurementsSpecification(hApp)


            if nargin>0
                obj.setupMeasurementObject(hApp);

                obj.pMeasurementUpdatedListener=event.listener(obj.pMeasurementObject,...
                'ChannelMeasurementsSettingsUpdated',makeCallback(obj.hVisual,@updateChannelMeasurements));
            else
                obj.pMeasurementLocalObject=struct('Algorithm',1,...
                'FrequencySpan',1,...
                'Span',2000,...
                'CenterFrequency',0,...
                'StartFrequency',-1000,...
                'StopFrequency',1000,...
                'PercentOccupiedBW',99,...
                'NumOffsets',2,...
                'AdjacentBW',1000,...
                'FilterShape',1,...
                'FilterCoeff',0.5,...
                'ACPROffsets',[2000,3500],...
                'Enable',false);
            end
        end

        function set.Algorithm(obj,val)
            [~,ind]=validateEnum(obj,val,'Algorithm',obj.AlgorithmSet);
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.Algorithm=ind;
            else
                obj.pMeasurementLocalObject.Algorithm=ind;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.Algorithm(obj)
            if~isempty(obj.hVisual)
                val=obj.AlgorithmSet{obj.pMeasurementObject.Algorithm};
            else
                val=obj.AlgorithmSet{obj.pMeasurementLocalObject.Algorithm};
            end
        end

        function set.FrequencySpan(obj,val)
            [~,ind]=validateEnum(obj,val,'FrequencySpan',obj.FrequencySpanSet);
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.FrequencySpan=ind;
            else
                obj.pMeasurementLocalObject.FrequencySpan=ind;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.FrequencySpan(obj)
            if~isempty(obj.hVisual)
                val=obj.FrequencySpanSet{obj.pMeasurementObject.FrequencySpan};
            else
                val=obj.FrequencySpanSet{obj.pMeasurementLocalObject.FrequencySpan};
            end
        end

        function set.Span(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','finite','nonnan'},'','Span');
            span=val;
            Fstart=obj.CenterFrequency-span/2;
            Fstop=obj.CenterFrequency+span/2;


            if~isempty(obj.hVisual)
                validateSpan(obj,Fstart,Fstop);
                obj.pMeasurementObject.StartFrequency=Fstart;
                obj.pMeasurementObject.StopFrequency=Fstop;
            else
                obj.pMeasurementLocalObject.Span=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.Span(obj)
            if~isempty(obj.hVisual)
                Fstart=obj.pMeasurementObject.StartFrequency;
                Fstop=obj.pMeasurementObject.StopFrequency;
                val=Fstop-Fstart;
            else
                val=obj.pMeasurementLocalObject.Span;
            end

        end

        function set.CenterFrequency(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','CenterFrequency');
            CF=val;
            Fstart=CF-obj.Span/2;
            Fstop=CF+obj.Span/2;


            if~isempty(obj.hVisual)
                validateSpan(obj,Fstart,Fstop);
                obj.pMeasurementObject.StartFrequency=Fstart;
                obj.pMeasurementObject.StopFrequency=Fstop;
            else
                obj.pMeasurementLocalObject.CenterFrequency=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.CenterFrequency(obj)
            if~isempty(obj.hVisual)
                Fstart=obj.pMeasurementObject.StartFrequency;
                Fstop=obj.pMeasurementObject.StopFrequency;
                val=(Fstart+Fstop)/2;
            else
                val=obj.pMeasurementLocalObject.CenterFrequency;
            end
        end

        function set.StartFrequency(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','StartFrequency');
            Fstart=val;
            Fstop=obj.StopFrequency;


            if~isempty(obj.hVisual)
                validateSpan(obj,Fstart,Fstop);
                obj.pMeasurementObject.StartFrequency=val;
            else
                obj.pMeasurementLocalObject.StartFrequency=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.StartFrequency(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.StartFrequency;
            else
                val=obj.pMeasurementLocalObject.StartFrequency;
            end
        end

        function set.StopFrequency(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','finite','nonnan'},'','StopFrequency');
            Fstart=obj.StartFrequency;
            Fstop=val;


            if~isempty(obj.hVisual)
                validateSpan(obj,Fstart,Fstop);
                obj.pMeasurementObject.StopFrequency=val;
            else
                obj.pMeasurementLocalObject.StopFrequency=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.StopFrequency(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.StopFrequency;
            else
                val=obj.pMeasurementLocalObject.StopFrequency;
            end
        end

        function set.PercentOccupiedBW(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','>=',1,'<',100,'finite','nonnan'},'','PercentOccupiedBW');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.PercentOBW=val;
            else
                obj.pMeasurementLocalObject.PercentOccupiedBW=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.PercentOccupiedBW(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.PercentOBW;
            else
                val=obj.pMeasurementLocalObject.PercentOccupiedBW;
            end
        end

        function set.NumOffsets(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','real','scalar','integer','>=',1,'<=',12,'finite','nonnan'},'','PercentOBW');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.NumOffsets=val;
            else
                obj.pMeasurementLocalObject.NumOffsets=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.NumOffsets(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.NumOffsets;
            else
                val=obj.pMeasurementLocalObject.NumOffsets;
            end
        end

        function set.AdjacentBW(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','positive'},'','AdjacentBW');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.AdjacentBandwidth=val;
            else
                obj.pMeasurementLocalObject.AdjacentBW=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.AdjacentBW(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.AdjacentBandwidth;
            else
                val=obj.pMeasurementLocalObject.AdjacentBW;
            end
        end

        function set.FilterShape(obj,val)
            [~,ind]=validateEnum(obj,val,'FilterShape',obj.FilterShapeSet);
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.FilterShape=ind;
            else
                obj.pMeasurementLocalObject.FilterShape=ind;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.FilterShape(obj)
            if~isempty(obj.hVisual)
                val=obj.FilterShapeSet{obj.pMeasurementObject.FilterShape};
            else
                val=obj.FilterShapeSet{obj.pMeasurementLocalObject.FilterShape};
            end
        end

        function set.FilterCoeff(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','scalar','>=',0,'<=',1,'finite','nonnan'},'','FilterCoeff');
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.FilterCoeff=val;
            else
                obj.pMeasurementLocalObject.FilterCoeff=val;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.FilterCoeff(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.FilterCoeff;
            else
                val=obj.pMeasurementLocalObject.FilterCoeff;
            end
        end

        function set.ACPROffsets(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','vector'},'','ACPROffsets');
            acprOffsets=NaN.*ones(1,12);
            acprOffsets(1,1:obj.NumOffsets)=val;
            if~isempty(obj.hVisual)
                obj.pMeasurementObject.ACPROffsets=acprOffsets;
            else
                obj.pMeasurementLocalObject.ACPROffsets=acprOffsets;
            end
            notify(obj,'ChannelMeasurementsUpdated');
        end
        function val=get.ACPROffsets(obj)
            acprOffsets=NaN.*ones(1,12);
            if~isempty(obj.hVisual)
                acprOffsets(1:obj.NumOffsets)=obj.pMeasurementObject.ACPROffsets(1:obj.NumOffsets);
            else
                acprOffsets(1:obj.NumOffsets)=obj.pMeasurementLocalObject.ACPROffsets(1:obj.NumOffsets);
            end
            val=acprOffsets(1:obj.NumOffsets);
        end

        function varargout=set(obj,varargin)


            if nargin==2&&ischar(varargin{1})
                switch varargin{1}
                case{'Algorithm','FrequencySpan','FilterShape'}
                    varargout{1}=obj.([varargin{1},'Set']);
                otherwise
                    varargout{1}=[];
                end
            else
                if nargout
                    varargout{1}=set@matlab.mixin.SetGet(obj,varargin{:});
                else
                    set@matlab.mixin.SetGet(obj,varargin{:});
                end
            end
        end
    end

    methods(Access=protected)

        function groups=getPropertyGroups(obj)


            if~isscalar(obj)
                groups=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                propList={'Algorithm','FrequencySpan'};
                if strcmp(obj.FrequencySpan,'Span and center frequency')
                    propList=[propList,{'Span','CenterFrequency'}];
                else
                    propList=[propList,{'StartFrequency','StopFrequency'}];
                end
                if strcmp(obj.Algorithm,'Occupied BW')
                    propList=[propList,{'PercentOccupiedBW'}];
                else
                    propList=[propList,{'NumOffsets','AdjacentBW','FilterShape','FilterCoeff','ACPROffsets'}];
                end
                propList=[propList,{'Enable'}];
                groups=matlab.mixin.util.PropertyGroup(propList);
            end
        end

        function validateSpan(obj,Fstart,Fstop)
            if(~obj.Enable)

                return;
            end
            if Fstart>=Fstop
                error(message('dspshared:SpectrumAnalyzer:FstartGreaterThanFstop'));
            end




            if obj.isSimulinkScope()
                return;
            end
            NyquistRange=[(-obj.hVisual.pSampleRate/2)*obj.hVisual.pTwoSidedSpectrum,obj.hVisual.pSampleRate/2];
            if(Fstart<NyquistRange(1))||(Fstop>NyquistRange(2))

                [NyquistRange,~,unitsNyquistRange]=engunits(NyquistRange);
                [spanRange,~,unitsSpanRange]=engunits([Fstart,Fstop]);
                switch obj.FrequencySpan
                case 'Span and center frequency'
                    error(message('dspshared:SpectrumAnalyzer:InvalidSpanAndCenterFrequency',...
                    num2str(spanRange(1)),num2str(spanRange(2)),unitsSpanRange,...
                    num2str(NyquistRange(1)),num2str(NyquistRange(2)),unitsNyquistRange));
                case 'Start and stop frequencies'
                    error(message('dspshared:SpectrumAnalyzer:InvalidStartAndStopFrequencies',...
                    num2str(spanRange(1)),num2str(spanRange(2)),unitsSpanRange,...
                    num2str(NyquistRange(1)),num2str(NyquistRange(2)),unitsNyquistRange));
                end
            end
        end

        function eventName=getMeasurementUpdatedEventName(~)
            eventName='ChannelMeasurementsUpdated';
        end

        function setupMeasurementObject(obj,hApp)
            obj.Application=hApp;
            obj.hVisual=obj.Application.Visual;
            obj.pMeasurementObject=matlabshared.scopes.measurements.ChannelMeasurements(hApp);

            allMeasurementsMap=getExtension(obj.Application.ExtDriver,'Tools:Measurements');
            allMeasurementsMap.ListenerMap(obj.MeasurerName)=event.proplistener(obj,...
            obj.findprop('Enable'),'PostSet',...
            enableMeasurementsCallback(allMeasurementsMap,obj.MeasurerName));
        end

        function spec=getDefaultMeasurementsSpec(~)
            spec=dsp.scopes.ChannelMeasurementsSpecification;
        end
    end

    methods(Hidden)

        function name=getMeasurementName(~)
            name='Channel Measurements';
        end

        function name=getMeasurementObjectName(~)
            name='ChannelMeasurements';
        end
    end
end
