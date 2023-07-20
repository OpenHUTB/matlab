classdef(CaseInsensitiveProperties=true)DiffRunResult<matlab.mixin.SetGet


















































































    properties(Hidden=true,SetAccess='private',GetAccess='public')
        ComparisonRunID;
        SDIEngine;
    end

    properties(SetAccess='private',GetAccess='public')
        MatlabVersion;
    end

    properties(Dependent=true,SetAccess='private',GetAccess='public')
        RunID1;
        RunID2;
        BaselineRunName;
        CompareToRunName;
        Count;
        DateCreated;
        GlobalTolerance;
        Summary;
        Options;

        Status;
        StopReason;
    end

    methods(Static=true)
        function ret=getLatest()

            ret=Simulink.sdi.DiffRunResult.empty();
            Simulink.sdi.internal.flushStreamingBackend();
            id=Simulink.sdi.getRecentValidComparisonRunID();
            if id
                ret=Simulink.sdi.DiffRunResult(id);
            end
        end
    end

    methods(Hidden=true)

        function this=DiffRunResult(varargin)
            this.ComparisonRunID=0;
            this.SDIEngine=Simulink.sdi.Instance.engine;

            if length(varargin)>=1&&isscalar(varargin{1})
                this.ComparisonRunID=varargin{1};
            end

            if length(varargin)>=2&&isa(varargin{2},'Simulink.sdi.internal.Engine')
                this.SDIEngine=varargin{2};
            end


            this.MatlabVersion=version;
        end

        function result=getResultBySignalIDs(this,signalID1,signalID2)
            compSigID=Simulink.sdi.getComparisonSignalID(this.SDIEngine.sigRepository,...
            this.ComparisonRunID,signalID1,signalID2);
            if 0==compSigID
                result=[];
                return;
            end

            result=Simulink.sdi.DiffSignalResult(compSigID,this.SDIEngine);
            [sync1ID,~]=result.getSynchronizedIDs();
            if isempty(sync1ID)
                result=[];
            end
        end

        function dsr=getLastDiffSignalResult(this)
            compSigID=Simulink.sdi.getLastDiffSignalResult(...
            this.SDIEngine.sigRepository,this.ComparisonRunID);
            if 0==compSigID
                dsr=[];
            else
                dsr=Simulink.sdi.DiffSignalResult(compSigID,this.SDIEngine);
            end
        end

        function result=getLastComparedPairIDs(this)










            result=Simulink.sdi.getLastComparedPairIDs(this.SDIEngine.sigRepository,this.ComparisonRunID);
        end
    end

    methods
        function out=get.Count(this)
            out=Simulink.sdi.getSignalComparisonsCount(this.SDIEngine.sigRepository,this.ComparisonRunID);
        end

        function out=get.DateCreated(this)
            value=this.SDIEngine.sigRepository.getDateCreated(this.ComparisonRunID);
            out=datetime(value,'ConvertFrom','posixtime','TimeZone','local');
        end

        function out=get.RunID1(this)
            out=this.SDIEngine.sigRepository.getBaselineRunID(this.ComparisonRunID);
        end

        function out=get.RunID2(this)
            out=this.SDIEngine.sigRepository.getCompareToRunID(this.ComparisonRunID);
        end

        function out=get.BaselineRunName(this)
            out=this.SDIEngine.sigRepository.getBaselineRunName(this.ComparisonRunID);
        end

        function out=get.CompareToRunName(this)
            out=this.SDIEngine.sigRepository.getCompareToRunName(this.ComparisonRunID);
        end

        function tolerance=get.GlobalTolerance(this)
            tolerance=Simulink.sdi.getTolerance(this.SDIEngine.sigRepository,this.ComparisonRunID);
        end

        function options=get.Options(this)
            options=Simulink.sdi.getComparisonOptions(this.SDIEngine.sigRepository,this.ComparisonRunID);
        end

        function status=get.Status(this)
            intStatus=Simulink.sdi.getStatusOfComparisonRun(...
            this.SDIEngine.sigRepository,this.ComparisonRunID);
            status=Simulink.sdi.ComparisonRunStatus(intStatus);
        end

        function dsr=get.StopReason(this)
            compSigID=Simulink.sdi.getStopReason(...
            this.SDIEngine.sigRepository,this.ComparisonRunID);

            if 0==compSigID
                dsr=[];
                return;
            end

            dsr=Simulink.sdi.DiffSignalResult(compSigID,this.SDIEngine);
        end

        function summary=get.Summary(this)
            summary=Simulink.sdi.getComparisonRunGroupStatus(...
            this.SDIEngine.sigRepository,this.ComparisonRunID);
        end

        function result=getResultByIndex(this,index)



























            compSigID=Simulink.sdi.getComparisonSignalIDByIndex(...
            this.SDIEngine.sigRepository,this.ComparisonRunID,index);


            result=Simulink.sdi.DiffSignalResult(compSigID,this.SDIEngine);
        end

        function results=getResultsByName(this,name)




            compSigIDs=Simulink.sdi.getComparisonSignalIDsByName(...
            this.SDIEngine.sigRepository,this.ComparisonRunID,name);

            results=Simulink.sdi.DiffSignalResult.empty();


            for idx=1:numel(compSigIDs)
                results(end+1)=Simulink.sdi.DiffSignalResult(compSigIDs(idx),this.SDIEngine);
            end
        end

        function saveResult(this,mldatxFileName,varargin)
            try
                [varargin{:}]=convertStringsToChars(varargin{:});
                mldatxFileName=convertStringsToChars(mldatxFileName);
                validateattributes(mldatxFileName,{'char','string'},{},'saveResult','filename',2);



                saveOriginalRuns=1;
                if length(varargin)>=1
                    if ischar(varargin{1})
                        saveOriginalRuns=strcmpi(varargin{1},'on');
                    else
                        validateattributes(varargin{1},{'numeric','logical'},{'scalar'},'saveResult','saveOriginalRuns',3);
                        if~varargin{1}
                            saveOriginalRuns=0;
                        end
                    end
                end

                Simulink.sdi.saveComparisonResult(this.SDIEngine.sigRepository,...
                this.ComparisonRunID,mldatxFileName,saveOriginalRuns);
            catch me
                me.throwAsCaller;
            end
        end
    end
end