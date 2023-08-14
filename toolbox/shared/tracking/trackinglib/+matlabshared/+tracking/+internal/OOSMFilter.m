classdef(Hidden,Abstract)OOSMFilter<handle











%#codegen

    properties(Dependent)


















MaxNumOOSMSteps
    end

    properties(Access=private)
pMaxNumOOSMSteps
    end

    properties(Constant,Access=private)


        pOOSMVersion=1;
    end

    properties(Access={?matlabshared.tracking.internal.OOSMFilter,...
        ?matlabshared.tracking.internal.fusion.ObjectTrack,...
        ?matlab.unittest.TestCase})
pPredictionDeltaTFromLastCorrection
pCorrectionTimestamps
pCorrectionDistributions
        pShouldWarn=true
    end

    properties(Access=private,Constant)
        DefaultMaxNumOOSMSteps=0;
    end

    methods
        function obj=OOSMFilter(varargin)
            coder.allowpcode('plain');
            opArgs={};
            poptions=struct('CaseSensitivity',true,...
            'IgnoreNulls',true,...
            'SupportOverrides',false);
            NVPairNames={'MaxNumOOSMSteps'};
            pstruct=coder.internal.parseInputs(opArgs,NVPairNames,...
            poptions,varargin{:});



            if coder.target('MATLAB')||pstruct.MaxNumOOSMSteps>0
                obj.MaxNumOOSMSteps=coder.internal.getParameterValue(...
                pstruct.MaxNumOOSMSteps,...
                obj.DefaultMaxNumOOSMSteps,...
                varargin{:});
            end
        end

        function set.MaxNumOOSMSteps(obj,val)
            setMaxNumOOSMSteps(obj,val);
        end

        function val=get.MaxNumOOSMSteps(obj)

            assertMaxNumDefined(obj);
            val=getMaxNumOOSMSteps(obj);
        end
    end

    methods(Abstract,Access=protected)
        dist=getDistribution(obj);
    end

    methods(Hidden)
        function setShouldWarn(obj,val)
            validateattributes(val,{'numerical','logical'},{'binary','scalar'},'shouldWarn');
            obj.pShouldWarn(1)=val;
        end
    end

    methods(Access=protected)
        function setMaxNumOOSMSteps(obj,val)

            if~coder.target('MATLAB')
                coder.internal.assert(~coder.internal.is_defined(obj.pMaxNumOOSMSteps),...
                'shared_tracking:OOSMFilter:MustBeSetOnce','MaxNumOOSMSteps');
            end
            validateattributes(val,{'numeric'},{'integer','nonnegative'},class(obj),'MaxNumOOSMSteps');
            if val>0
                checkOutSFTTLicense(obj);
                obj.pMaxNumOOSMSteps=val+1;
                createHistory(obj);
            else
                obj.pMaxNumOOSMSteps=0;
            end


        end

        function val=getMaxNumOOSMSteps(obj)
            val=max(0,obj.pMaxNumOOSMSteps-1);
        end

        function loadOOSMProperties(obj,s)


            if isfield(s,'pPredictionDeltaTFromLastCorrection')
                obj.pPredictionDeltaTFromLastCorrection=s.pPredictionDeltaTFromLastCorrection;
            end
            if isfield(s,'pPredictionDeltaTFromLastCorrection')
                obj.pPredictionDeltaTFromLastCorrection=s.pPredictionDeltaTFromLastCorrection;
            end
            if isfield(s,'pCorrectionTimestamps')
                obj.pCorrectionTimestamps=s.pCorrectionTimestamps;
            end
            if isfield(s,'pCorrectionDistributions')
                obj.pCorrectionDistributions=s.pCorrectionDistributions;
            end
            if isfield(s,'pMaxNumOOSMSteps')
                obj.pMaxNumOOSMSteps=s.pMaxNumOOSMSteps;


                if~isfield(s,'pOOSMVersion')
                    fixMaxNumOOSMSteps(obj);
                end
            end
            if isfield(s,'pShouldWarn')
                obj.pShouldWarn=s.pShouldWarn;
            end
        end

        function fixMaxNumOOSMSteps(obj)

            if obj.pMaxNumOOSMSteps~=0
                obj.pMaxNumOOSMSteps=obj.pMaxNumOOSMSteps+1;




                [~,ind]=min(obj.pCorrectionTimestamps);
                obj.pCorrectionDistributions=[obj.pCorrectionDistributions,...
                obj.pCorrectionDistributions(ind)];
                obj.pCorrectionTimestamps=[obj.pCorrectionTimestamps,...
                obj.pCorrectionTimestamps(ind)];
            end
        end

        function s=saveOOSMProperties(obj,sIn)

            s=struct;
            if nargin==2
                inFields=fieldnames(sIn);
                for i=1:numel(inFields)
                    s.(inFields{i})=sIn.(inFields{i});
                end
            end
            if coder.internal.is_defined(obj.pMaxNumOOSMSteps)
                s.pMaxNumOOSMSteps=obj.pMaxNumOOSMSteps;
            end
            s.pShouldWarn=obj.pShouldWarn;
            s.pPredictionDeltaTFromLastCorrection=obj.pPredictionDeltaTFromLastCorrection;
            s.pCorrectionTimestamps=obj.pCorrectionTimestamps;
            s.pCorrectionDistributions=obj.pCorrectionDistributions;
            s.pOOSMVersion=obj.pOOSMVersion;
        end
    end

    methods(Access={?matlabshared.tracking.internal.OOSMFilter,...
        ?matlab.unittest.TestCase})
        function createHistory(obj)

            if obj.pMaxNumOOSMSteps>0
                dist=getDistribution(obj);
                obj.pPredictionDeltaTFromLastCorrection=zeros(1,1,'like',dist.State);
                obj.pCorrectionTimestamps=zeros(1,obj.pMaxNumOOSMSteps,'like',dist.State);
                obj.pCorrectionDistributions=repmat(dist,1,obj.pMaxNumOOSMSteps);
            end
        end

        function syncOOSMFilter(this,that)
            this.pPredictionDeltaTFromLastCorrection=that.pPredictionDeltaTFromLastCorrection;
            this.pCorrectionTimestamps=that.pCorrectionTimestamps;
            this.pCorrectionDistributions=that.pCorrectionDistributions;
        end

        function cloneOOSMFilter(obj2,obj)


            assertMaxNumDefined(obj);
            obj2.pMaxNumOOSMSteps=obj.pMaxNumOOSMSteps;
            obj2.pShouldWarn=obj.pShouldWarn;
            syncOOSMFilter(obj2,obj);
        end

        function updateHistoryAfterCorrection(obj)
            assertMaxNumDefined(obj);
            if obj.pMaxNumOOSMSteps>0
                if obj.pPredictionDeltaTFromLastCorrection==0


                    [~,maxInd]=max(obj.pCorrectionTimestamps);
                    obj.pCorrectionDistributions(maxInd)=getDistribution(obj);
                else
                    [~,minInd]=min(obj.pCorrectionTimestamps);
                    maxT=max(obj.pCorrectionTimestamps);
                    obj.pCorrectionTimestamps(minInd)=maxT+obj.pPredictionDeltaTFromLastCorrection;
                    obj.pCorrectionDistributions(minInd)=getDistribution(obj);
                    obj.pPredictionDeltaTFromLastCorrection(:)=0;
                end
            end
        end

        function updateLastCorrectionDistribution(obj)
            assertMaxNumDefined(obj);
            if obj.pMaxNumOOSMSteps>0
                [~,maxInd]=max(obj.pCorrectionTimestamps);
                obj.pCorrectionDistributions(maxInd)=getDistribution(obj);
            end
        end

        function[success,dist,t]=fetchDistributionByTime(obj,time)
            [distTimes,I]=sort(obj.pCorrectionTimestamps);


            distTimes=round(distTimes*1e6)/1e6;
            time=round(time*1e6)/1e6;


            ind1=find(distTimes==time,1,'first');
            ind2=find(distTimes<time,1,'last');
            ind=max([ind1,ind2],[],1);
            if~isempty(ind)
                dist=obj.pCorrectionDistributions(I(ind(1,1)));
                t=obj.pCorrectionTimestamps(I(ind(1,1)));
                success=true;
            else

                if obj.pShouldWarn
                    coder.internal.warning('shared_tracking:OOSMFilter:RetrodictionLimit',...
                    'MaxNumOOSMSteps');
                end
                dist=obj.pCorrectionDistributions(1);
                t=obj.pCorrectionTimestamps(1);
                success=false;
            end
        end

        function assertMaxNumDefined(obj)
            if~coder.internal.is_defined(obj.pMaxNumOOSMSteps)
                obj.pMaxNumOOSMSteps=obj.DefaultMaxNumOOSMSteps;
            end
        end
    end

    methods(Sealed,Access=private)
        function checkOutSFTTLicense(~)

            if coder.target('MATLAB')
                try
                    isSFTTAvailable=builtin('license','test','Sensor_Fusion_and_Tracking');
                    success=false;
                    if isSFTTAvailable
                        [success,~]=builtin('license','checkout','Sensor_Fusion_and_Tracking');
                    end
                    coder.internal.assert(success,'shared_tracking:OOSMFilter:SFTTLicenseNeeded');
                catch ME
                    throwAsCaller(ME);
                end
            else
                coder.license('checkout','Sensor_Fusion_and_Tracking');
            end
        end
    end

    methods(Hidden,Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'pMaxNumOOSMSteps'};
        end

        function[oosmArgs,idx1]=parseOOSMNVPairs(varargin)
            idx1=matlabshared.smoothers.internal.findProp('MaxNumOOSMSteps',varargin{:});
            hasOOSM=idx1<=numel(varargin);
            if hasOOSM
                oosmArgs={varargin{idx1:idx1+1}};
            else
                oosmArgs={};
            end
        end
    end
end