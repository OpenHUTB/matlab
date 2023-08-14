classdef SchedulerInfo<handle





    properties(SetAccess='private')
        mNumSampleTimes=0;
        mBaseSampleTime=0;
        mNumSynchronousSampleTimes=0;
        mAsyncTaskNeedsAbsoluteTime=0;
        mTimerIntNeeded=0;
        mTimerIntPeriod=0;
        mTimerIntPriority=0;
        mManageTaskTime=0;
        mSampleTime=[];
        mIsSingleTasking=0;
        mFunctionName=[];
        mErrorCheck=[];
        mRunStepFunc=[];
        mRunStepFuncParam=[];
        mInitializeFunc=[];
        mTerminateFunc=[];
        mErrorStatusStr=[];

    end

    methods
        function h=SchedulerInfo
        end

        function setNumSampleTimes(h,numSampleTimes)
            h.mNumSampleTimes=numSampleTimes;
        end

        function numSampleTimes=getNumSampleTimes(h)
            numSampleTimes=h.mNumSampleTimes;
        end

        function ret=getSampleTimeRecord(h)
            ret=h.mSampleTime;
        end

        function ret=getFunctionName(h)
            ret=h.mFunctionName;
        end

        function ret=getErrorCheck(h)
            ret=h.mErrorCheck;
        end

        function ret=getNumSubTasks(h)
            ret=length(h.mSampleTime)-1;
        end

        function ret=getRunStepFunc(h)
            ret=h.mRunStepFunc;
        end

        function ret=getRunStepFuncParam(h)
            ret=h.mRunStepFuncParam;
        end

        function ret=getInitializeFunc(h)
            ret=h.mInitializeFunc;
        end

        function ret=getTerminateFunc(h)
            ret=h.mTerminateFunc;
        end

        function ret=getErrorStatusStr(h)
            ret=h.mErrorStatusStr;
        end


        function setAll(h,numSampleTimes,BaseSampleTime,numSynchronousSampleTimes,AsyncTaskNeedsAbsoluteTime,timerIntNeeded,timerIntPeriod,timerIntPriority,manageTaskTime)
            h.mNumSampleTimes=numSampleTimes;
            h.mBaseSampleTime=BaseSampleTime;
            h.mNumSynchronousSampleTimes=numSynchronousSampleTimes;
            h.mAsyncTaskNeedsAbsoluteTime=AsyncTaskNeedsAbsoluteTime;
            h.mTimerIntNeeded=timerIntNeeded;
            h.mTimerIntPeriod=timerIntPeriod;
            h.mTimerIntPriority=timerIntPriority;
            h.mManageTaskTime=manageTaskTime;
        end

        function ret=setFromTLC(h,varargin)
            h.mSampleTime=evalin('base',varargin{1});
            h.mIsSingleTasking=varargin{2};
            h.mFunctionName=varargin{3};
            h.mErrorCheck=varargin{4};
            h.mRunStepFunc=varargin{5};
            h.mRunStepFuncParam=varargin{6};
            h.mInitializeFunc=varargin{7};
            h.mTerminateFunc=varargin{8};
            h.mErrorStatusStr=varargin{9};

            ret=true;
        end

        function ret=setFromCodeInfo(h,codeInfo)

            h.mFunctionName=codeInfo.OutputFunctions.Prototype.Name;
            h.mErrorCheck=codeInfo.OutputFunctions.Prototype.Name;
            h.mRunStepFunc=codeInfo.OutputFunctions.Prototype.Name;
            h.mRunStepFuncParam=codeInfo.OutputFunctions.Prototype.Name;
            h.mInitializeFunc=codeInfo.InitializeFunctions.Prototype.Name;
            h.mTerminateFunc=codeInfo.TerminateFunctions.Prototype.Name;
            h.mErrorStatusStr=codeInfo.Name;
            ret=true;
        end
    end

end


















































































