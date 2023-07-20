classdef(CaseInsensitiveProperties=true)DiffSignalResult<matlab.mixin.SetGet











































































    properties(Hidden=true,SetAccess='private',GetAccess='public')
        ComparisonSignalID;
        SDIEngine;
    end



    properties(Dependent=true,Hidden=true,SetAccess=private)
        Match;
        UnitsMatch;
        Tol;
    end



    properties(Dependent=true,SetAccess=private)
        Name;
        Status;
        AlignBy;
        SignalID1;
        SignalID2;
MaxDifference
        Sync1;
        Sync2;
        Diff;
    end

    properties(Dependent=true,Hidden)
        Signal1Obj;
        Signal2Obj;
    end

    methods(Access='public',Hidden)
        function this=DiffSignalResult(varargin)
            this.ComparisonSignalID=0;
            this.SDIEngine=Simulink.sdi.Instance.engine;

            if length(varargin)>=1&&isscalar(varargin{1})
                this.ComparisonSignalID=varargin{1};
            end

            if length(varargin)>=2&&isa(varargin{2},'Simulink.sdi.internal.Engine')
                this.SDIEngine=varargin{2};
            end
        end

        function delete(this)
            this.ComparisonSignalID=0;
        end


        function[d,t,tolLower,tolUpper,diffTolLower,diffTolUpper,...
            compMinusBase,pass,failureRegion]=getAllCompMetaIDs(this)

            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            d=ret.diffID;
            t=ret.tolID;
            tolLower=ret.tolLowerID;
            tolUpper=ret.tolUpperID;
            diffTolLower=ret.diffTolLowerID;
            diffTolUpper=ret.diffTolUpperID;
            compMinusBase=ret.compMinusBaseID;
            pass=ret.passID;
            failureRegion=ret.failureRegionID;
        end



        function[Sync1ID,Sync2ID]=getSynchronizedIDs(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            Sync1ID=ret.sync1ID;
            Sync2ID=ret.sync2ID;
        end
    end


    methods

        function result=get.Name(this)
            result=Simulink.sdi.getSignal(this.ComparisonSignalID).Name;
        end

        function result=get.Match(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=ret.match;
        end

        function result=get.UnitsMatch(this)
            result=Simulink.sdi.isUnitsMatchForComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
        end

        function result=get.Status(this)
            intValue=Simulink.sdi.getStatusOfComparisonSignal(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=Simulink.sdi.ComparisonSignalStatus(intValue);
        end

        function ret=get.AlignBy(this)
            ret=this.SDIEngine.sigRepository.getSignalAlignedBy(this.ComparisonSignalID);
        end

        function result=get.SignalID1(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=ret.sigID1;
        end

        function result=get.SignalID2(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=ret.sigID2;
        end

        function result=get.MaxDifference(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=ret.maxDiff;
        end


        function result=get.Sync1(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=this.SDIEngine.exportSignalToTimeSeries(ret.sync1ID);
        end

        function result=get.Sync2(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=this.SDIEngine.exportSignalToTimeSeries(ret.sync2ID);
        end

        function result=get.Tol(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=this.SDIEngine.exportSignalToTimeSeries(ret.tolID);
        end

        function result=get.Diff(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            result=this.SDIEngine.exportSignalToTimeSeries(ret.compMinusBaseID);
        end

        function val=get.Signal1Obj(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            if~isempty(ret.sigID1)
                val=this.SDIEngine.getSignal(ret.sigID1);
            else
                val=[];
            end
        end

        function set.Signal1Obj(~,~)
        end

        function val=get.Signal2Obj(this)
            ret=Simulink.sdi.getDiffSignalResultByComparisonSignalID(...
            this.SDIEngine.sigRepository,this.ComparisonSignalID);
            if~isempty(ret.sigID2)
                val=this.SDIEngine.getSignal(ret.sigID2);
            else
                val=[];
            end
        end

        function set.Signal2Obj(~,~)
        end
    end

end
