




classdef MdlInitializeSampleTimesWriter<coder.internal.modelreference.FunctionInterfaceWriter
    properties(Access=private)
TimingInterfaceUtils
SampleTimes
    end



    methods
        function this=MdlInitializeSampleTimesWriter(codeInfoUtils,modelInterfaceUtils,timingInterfaceUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter([],modelInterfaceUtils,codeInfoUtils,writer);


            this.TimingInterfaceUtils=timingInterfaceUtils;
            this.SampleTimes=this.TimingInterfaceUtils.getSampleTimes;
        end
    end



    methods(Access=public)
        function write(this)
            this.writeFunctionHeader;
            this.writeFunctionBody;
            this.writeFunctionTrailer;
            if~isempty(this.HeaderWriter)
                assert(this.Linkage==coder.internal.modelreference.FunctionLinkage.External)
                this.declareInHeader(this.FunctionInterfaces);
            end
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlInitializeSampleTimes(SimStruct *S)';
        end

        function writeFunctionBody(this)


            if this.TimingInterfaceUtils.UsePortBasedSampleTimes
                this.Writer.writeLine('/* This block has port based sample time. */');
            else
                if this.ModelInterfaceUtils.isConstantBlock
                    if this.TimingInterfaceUtils.HasInternalParameterRate
                        [samplePeriodCExpr,sampleOffsetCExpr]=this.TimingInterfaceUtils.getConstantSampleTimeString();
                        this.writeSampleTimeFunctionCallString('ssSetSampleTime',0,samplePeriodCExpr);
                        this.writeSampleTimeFunctionCallString('ssSetOffsetTime',0,sampleOffsetCExpr);
                    else
                        this.writeSampleTimeFunctionCallString('ssSetSampleTime',0,'rtInf');
                        this.writeSampleTimeFunctionCallString('ssSetOffsetTime',0,'rtInf');
                    end

                    if this.TimingInterfaceUtils.HasConstantOutput



                        this.writeSampleTimeFunctionCallString('ssSetSampleTime',length(this.SampleTimes),'rtInf');
                        this.writeSampleTimeFunctionCallString('ssSetOffsetTime',length(this.SampleTimes),'rtInf');
                    end
                else
                    if(this.ModelInterfaceUtils.isAPeriodicTriggered||...
                        ~this.ModelInterfaceUtils.disallowSampleTimeInheritance)
                        this.writeSampleTimeFunctionCallString('ssSetSampleTime',0,'-1');
                        this.writeModelWideEvents(1);

                        if this.TimingInterfaceUtils.HasConstantOutput



                            constantRateIdx=length(this.SampleTimes)+1;
                            this.writeSampleTimeFunctionCallString('ssSetSampleTime',constantRateIdx,'rtInf');
                            this.writeSampleTimeFunctionCallString('ssSetOffsetTime',constantRateIdx,'rtInf');
                        end
                    else
                        if this.ModelInterface.IsExportFcnDiagram









                            numPortlessSimulinkFunctionPortGroups=this.ModelInterface.NumPortlessSimulinkFunctionPortGroups;
                            for index=1:numPortlessSimulinkFunctionPortGroups
                                this.writeSampleTimeFunctionCallString('ssSetSampleTime',index-1,'-1');
                                this.writeSampleTimeFunctionCallString('ssSetOffsetTime',index-1,'-mxGetInf()');
                            end
                            this.writeModelWideEvents(numPortlessSimulinkFunctionPortGroups);
                            if this.TimingInterfaceUtils.HasConstantOutput



                                constantRateIdx=numPortlessSimulinkFunctionPortGroups+length(this.TimingInterfaceUtils.getModelWideEvents);
                                this.writeSampleTimeFunctionCallString('ssSetSampleTime',constantRateIdx,'rtInf');
                                this.writeSampleTimeFunctionCallString('ssSetOffsetTime',constantRateIdx,'rtInf');
                            end
                        else
                            numberOfSampleTimes=length(this.SampleTimes);
                            for sampIdx=1:numberOfSampleTimes
                                sampleOffsetFunctionCallString='ssSetOffsetTime';
                                timingInterface=this.SampleTimes(sampIdx);
                                sampleTimeIndex=this.TimingInterfaceUtils.getSampleTimeIndex(timingInterface);

                                if this.TimingInterfaceUtils.isControllableRate(timingInterface)
                                    [samplePeriodCExpr,sampleOffsetCExpr]=this.TimingInterfaceUtils.getControllableRateString(timingInterface);
                                    this.writeSampleTimeFunctionCallString('ssSetControllableSampleTime',sampleTimeIndex,samplePeriodCExpr);
                                    this.writeSampleTimeFunctionCallString('ssSetControllableSampleTimeUID',sampleTimeIndex,sampleOffsetCExpr);
                                else
                                    if this.TimingInterfaceUtils.isAsynchronousSampleTime(timingInterface)
                                        [samplePeriodCExpr,sampleOffsetCExpr]=this.TimingInterfaceUtils.getAsynchronousSampleTimeString;
                                    elseif this.TimingInterfaceUtils.isVariableSampleTime(timingInterface)

                                        [samplePeriodCExpr,sampleOffsetCExpr]=this.TimingInterfaceUtils.getVariableSampleTimeString(timingInterface,sampIdx);
                                        sampleOffsetCExpr=this.ModelInterfaceUtils.getStringLiteralCast(sampleOffsetCExpr);
                                        sampleOffsetFunctionCallString='ssSetVariableSampleTimeUID';
                                    else
                                        [samplePeriodCExpr,sampleOffsetCExpr]=this.TimingInterfaceUtils.getSampleTimeString(timingInterface);
                                        if(strcmpi(samplePeriodCExpr,'inf'))
                                            samplePeriodCExpr='mxGetInf()';
                                        end
                                    end


                                    this.writeSampleTimeFunctionCallString('ssSetSampleTime',sampleTimeIndex,samplePeriodCExpr);
                                    this.writeSampleTimeFunctionCallString(sampleOffsetFunctionCallString,sampleTimeIndex,sampleOffsetCExpr);
                                end

                            end

                            if this.TimingInterfaceUtils.HasConstantOutput



                                this.writeSampleTimeFunctionCallString('ssSetSampleTime',length(this.SampleTimes),'rtInf');
                                this.writeSampleTimeFunctionCallString('ssSetOffsetTime',length(this.SampleTimes),'rtInf');
                            end
                        end
                    end
                end
            end
        end
    end



    methods(Access=private)
        function writeSampleTimeFunctionCallString(this,functionCallString,sampleTimeIndex,sampleTimeString)
            this.Writer.writeLine('%s(S, %d, %s);\n',functionCallString,sampleTimeIndex,sampleTimeString);
        end

        function writeModelWideEvents(this,mweStartIdx)
            modelWideEvents=this.TimingInterfaceUtils.getModelWideEvents;

            for sampIdx=1:length(modelWideEvents)
                timingInterface=modelWideEvents(sampIdx);
                stiInSfun=mweStartIdx+sampIdx-1;


                this.writeSampleTimeFunctionCallString('ssSetSampleTime',stiInSfun,'mxGetInf()');
                sampleOffsetCExpr=rtw.connectivity.CodeInfoUtils.double2str(timingInterface.SampleOffset);
                this.writeSampleTimeFunctionCallString('ssSetOffsetTime',stiInSfun,sampleOffsetCExpr);
            end
        end

    end
end


