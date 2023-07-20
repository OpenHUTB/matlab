



classdef TimingInterfaceUtils<handle
    properties(Access=public)
UsePortBasedSampleTimes
HasVariableSampleTimes
HasConstantOutput
HasParameterChangeEventOutput
HasInternalParameterRate
    end


    properties(Access=private)
CodeInfoUtils
ModelInterfaceUtils
CodeInfo
ModelInterface
        SampleTimes=[]
    end


    methods
        function this=TimingInterfaceUtils(codeInfoUtils,modelInterfaceUtils)
            this.CodeInfoUtils=codeInfoUtils;
            this.ModelInterfaceUtils=modelInterfaceUtils;

            this.CodeInfo=this.CodeInfoUtils.getCodeInfo;
            this.ModelInterface=this.ModelInterfaceUtils.getModelInterface;


            this.computeSampleTimes;


            this.UsePortBasedSampleTimes=this.ModelInterface.UsePortBasedTs;




            this.HasVariableSampleTimes=this.hasVariableSampleTimes;
            this.HasConstantOutput=this.hasConstantOutput;
            this.HasParameterChangeEventOutput=this.hasParameterChangeEventOutput;
            this.HasInternalParameterRate=this.hasInternalParameterRate;
        end
    end



    methods(Access=public)
        function sampleTimes=getSampleTimes(this)
            sampleTimes=this.SampleTimes;
        end


        function numberOfSampleTimes=getNumberOfSampleTimes(this)
            numberOfSampleTimes=length(this.SampleTimes);
        end
    end



    methods(Access=public)
        function computeSampleTimes(this)








            if~this.ModelInterfaceUtils.isAPeriodicTriggered

                this.SampleTimes=[this.getContinuousSampleTimes;...
                this.getFixedStepInMinorMode;...
                this.getDiscreteSampleTimes;...
                this.getAperiodicSampleTimes;...
                this.getControllableRates;...
                this.getVariableSampleTimes;...
                this.getAsynchronousSampleTimes;...
                this.getModelWideEvents;...
                this.getUnionSampleTimes];
            else
                this.SampleTimes=[this.getModelWideEvents;...
                this.getInheritedSampleTimes];
            end
        end


        function idx=getSampleTimeIndex(this,timingInterface)
            idx=find(this.SampleTimes==timingInterface)-1;
        end

























    end


    methods(Static,Access=public)
        function status=isSampleTimeUsedByPorts(ports,timingInterface)
            status=false;
            numberOfPorts=length(ports);
            for portIdx=1:numberOfPorts
                if isequal(timingInterface,ports(portIdx).Timing)
                    status=true;
                    return;
                end
            end
        end
    end


    methods(Access=public)
        function sampleTimes=getContinuousSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isContinuousSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end


            if~isempty(sampleTimes)

                sampleTimes=sampleTimes(end);
            end
        end


        function sampleTimes=getFixedStepInMinorMode(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isFixedStepInMinorMode(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getDiscreteSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isDiscreteSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getAperiodicSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isAperiodicSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getControllableRates(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isControllableRate(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getConstantSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isConstantSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getParameterChangeEvents(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isParameterChangeEvent(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getInheritedSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isInheritedSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getVariableSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isVariableSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end


        function sampleTimes=getAsynchronousSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isAsynchronousSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end

        function sampleTimes=getModelWideEvents(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isModelWideEvent(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end

        function status=unionRateHasTask(this,timingInterface)




            allUnionElementsAsynchronous=true;
            for i=1:length(timingInterface.UnionTimingInfo)
                if~this.isLegacyAsynchronousSampleTime(timingInterface.UnionTimingInfo(i))
                    allUnionElementsAsynchronous=false;
                    break;
                end
            end

            status=allUnionElementsAsynchronous||...
            this.ModelInterface.IsExportFcnDiagram;
        end

        function sampleTimes=getUnionSampleTimes(this)
            sampleTimes=[];
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isUnionSampleTime(this.CodeInfo.TimingProperties(sampIdx))...
...
                    &&this.unionRateHasTask(this.CodeInfo.TimingProperties(sampIdx))
                    sampleTimes=[sampleTimes;this.CodeInfo.TimingProperties(sampIdx)];%#ok
                end
            end
        end

    end



    methods(Access=public)
        function status=hasVariableSampleTimes(this)
            status=true;
            numberOfSampleTimes=length(this.CodeInfo.TimingProperties);
            for sampIdx=1:numberOfSampleTimes
                if this.isVariableSampleTime(this.CodeInfo.TimingProperties(sampIdx))
                    status=false;
                    return;
                end
            end
        end


        function status=hasConstantOutput(this)

            status=false;


            constantSampleTimes=this.getConstantSampleTimes;


            numberOfSampleTimes=length(constantSampleTimes);
            for sampIdx=1:numberOfSampleTimes
                if this.isSampleTimeUsedByPorts(this.CodeInfo.Outports,constantSampleTimes)
                    status=true;
                    return;
                end
            end
        end


        function status=hasParameterChangeEventOutput(this)

            status=false;


            parameterSampleTimes=this.getParameterChangeEvents;


            numberOfSampleTimes=length(parameterSampleTimes);
            for sampIdx=1:numberOfSampleTimes
                if this.isSampleTimeUsedByPorts(this.CodeInfo.Outports,parameterSampleTimes)
                    status=true;
                    return;
                end
            end
        end

        function status=hasParameterChangeEventInput(this)
            status=false;


            parameterSampleTimes=this.getParameterChangeEvents;


            numberOfSampleTimes=length(parameterSampleTimes);
            for sampIdx=1:numberOfSampleTimes
                if this.isSampleTimeUsedByPorts(this.CodeInfo.Inports,parameterSampleTimes)
                    status=true;
                    return;
                end
            end
        end

        function status=hasInternalParameterRate(this)
            parameterSampleTimes=this.getParameterChangeEvents;
            status=~isempty(parameterSampleTimes)&&...
            ~this.hasParameterChangeEventOutput&&...
            ~this.hasParameterChangeEventInput;
            return;
        end

        function[samplePeriodCExpr,sampleOffsetCExpr]=getVariableSampleTimeString(this,timingInterface,sampIdx)

            samplePeriodCExpr=rtw.connectivity.CodeInfoUtils.double2str(timingInterface.SamplePeriod);
            sampleOffsetCExpr=['"',this.ModelInterface.VariableSampleTime{sampIdx}.uid,'"'];
        end

        function[samplePeriodCExpr,sampleOffsetCExpr]=getControllableRateString(this,timingInterface)
            samplePeriodCExpr=rtw.connectivity.CodeInfoUtils.double2str(timingInterface.SamplePeriod);
            sampleOffsetCExpr='';
            if(length(this.ModelInterface.ControllableRateUIDs)==1)
                controllableRateUIDs={this.ModelInterface.ControllableRateUIDs};
            else
                controllableRateUIDs=this.ModelInterface.ControllableRateUIDs;
            end
            for idx=1:length(controllableRateUIDs)
                if(controllableRateUIDs{idx}.ctrlRateOffset==timingInterface.SampleOffset)
                    sampleOffsetCExpr=['"',controllableRateUIDs{idx}.uid,'"'];
                end
            end

        end

        function[tidInSubMdl,id,eventType]=getModelWideEventsInfo(this,offsetInput)
            tidInSubMdl=-1;
            id='';
            eventType='';
            if(length(this.ModelInterface.ModelWideEvents)==1)
                modelWideEvents={this.ModelInterface.ModelWideEvents};
            else
                modelWideEvents=this.ModelInterface.ModelWideEvents;
            end
            for idx=1:length(modelWideEvents)
                if(modelWideEvents{idx}.offset==offsetInput)
                    tidInSubMdl=modelWideEvents{idx}.tid;
                    id=modelWideEvents{idx}.id;
                    eventType=modelWideEvents{idx}.eventType;
                end
            end
        end
    end



    methods(Static)
        function status=isContinuousSampleTime(timingInterface)

            status=(timingInterface.SamplePeriod==0)&&...
            (timingInterface.SampleOffset==0)&&...
            (strcmp(timingInterface.TimingMode,'CONTINUOUS')||...
            strcmp(timingInterface.TimingMode,'PERIODIC'));
        end


        function status=isFixedStepInMinorMode(timingInterface)
            status=(timingInterface.SamplePeriod==0)&&(timingInterface.SampleOffset==1);
        end


        function status=isDiscreteSampleTime(timingInterface)



            status=(timingInterface.SamplePeriod>0)&&...
            strcmp(timingInterface.TimingMode,'PERIODIC');
        end

        function status=isAperiodicSampleTime(timingInterface)
            status=strcmp(timingInterface.TimingMode,'APERIODIC');
        end

        function status=isVariableSampleTime(timingInterface)
            status=timingInterface.SamplePeriod==-2;
        end

        function status=isControllableRate(timingInterface)
            status=timingInterface.SamplePeriod>0&&...
            strcmp(timingInterface.TimingMode,'CONTROLLABLE');
        end

        function status=isInheritedSampleTime(timingInterface)
            status=strcmp(timingInterface.TimingMode,'INHERITED');
        end

        function status=isAsynchronousSampleTime(timingInterface)







            status=coder.internal.modelreference.TimingInterfaceUtils.isLegacyAsynchronousSampleTime(timingInterface)||...
            (strcmp(timingInterface.TimingMode,'ASYNCHRONOUS')&&(timingInterface.SamplePeriod~=Inf));
        end

        function status=isLegacyAsynchronousSampleTime(timingInterface)
            status=timingInterface.SamplePeriod==-1&&timingInterface.SampleOffset<-1;
        end

        function status=isExplicitTaskingSampleTime(timingInterface)
            status=(strcmp(timingInterface.TaskingMode,'EXPLICIT_TASKING'));
        end




        function status=isModelWideEvent(timingInterface)
            status=(timingInterface.SamplePeriod==Inf)&&...
            (timingInterface.SampleOffset~=Inf);
        end

        function status=isConstantSampleTime(timingInterface)
            status=strcmp(timingInterface.TimingMode,'ONESHOT');
        end

        function status=isParameterChangeEvent(timingInterface)
            status=strcmp(timingInterface.TimingMode,'PARAMETERCHANGE')&&...
            (timingInterface.SamplePeriod==Inf)&&...
            (timingInterface.SampleOffset==0);
        end

        function status=isUnionSampleTime(timingInterface)
            status=strcmp(timingInterface.TimingMode,'UNION');
        end

        function[samplePeriodCExpr,sampleOffsetCExpr]=getSampleTimeString(timingInterface)
            samplePeriodCExpr=rtw.connectivity.CodeInfoUtils.double2str(timingInterface.SamplePeriod);
            sampleOffsetCExpr=rtw.connectivity.CodeInfoUtils.double2str(timingInterface.SampleOffset);
        end


        function[samplePeriodCExpr,sampleOffsetCExpr]=getConstantSampleTimeString()
            samplePeriodCExpr='rtInf';
            sampleOffsetCExpr='0';
        end


        function[samplePeriodCExpr,sampleOffsetCExpr]=getAsynchronousSampleTimeString()
            samplePeriodCExpr='INHERITED_SAMPLE_TIME';
            sampleOffsetCExpr='rtMinusInf';
        end
    end
end


