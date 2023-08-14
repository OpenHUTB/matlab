




classdef MdlSetSimStateWriter<coder.internal.modelreference.MdlGetSetSimStateWriterBase

    methods(Access=public)
        function this=MdlSetSimStateWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.MdlGetSetSimStateWriterBase(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlSetSimState(SimStruct *S, const mxArray* ss)';
        end

        function writeFunctionBody(this)
            isSingleInstance=~this.ModelInterface.OkToMultiInstance;
            xDataType=this.ModelInterface.xDataType;
            if~isempty(xDataType)
                this.writeLocalXSection(xDataType,isSingleInstance);
            end

            fcnName=this.ModelInterface.ModelSetDWorkFcnName;
            if isSingleInstance
                this.Writer.writeLine([fcnName,'(mxGetFieldByNumber(ss, 0, 1));']);
            else
                this.Writer.writeLine([fcnName,'(',this.getSsGetDWorkCall(false),', mxGetFieldByNumber(ss, 0, 1));']);
            end

            this.writeSampleTimeInfo;
            this.writeNonContDerivSigInfo;
            this.writeCoverageNotify('covrtModelFastRestart');
        end
    end

    methods(Access=private)
        function writeNonContDerivSigInfo(this)
            if strcmp(this.ModelInterface.SolverType,'VariableStep')
                numNonContDerivSignals=this.ModelInterface.SolverResetInfo.NumNonContDerivSignals;
                if numNonContDerivSignals~=0
                    this.Writer.writeLine('{');
                    this.Writer.writeLine('mxArray* nonContDerivSigInfo = mxGetFieldByNumber(ss, 0, 5);\n');
                    if~this.ModelInterfaceUtils.isMultiInstance
                        dworkIdentifier=this.ModelInterface.SFcnDWorkIdentifier;
                        this.Writer.writeLine('%s * rtm = &(%s.rtm);',this.ModelInterface.RTMTypeName,dworkIdentifier);
                    else
                        this.Writer.writeLine('%s * dw = (%s *) ssGetDWork(S, 0);',this.ModelInterface.DWorkType,this.ModelInterface.DWorkType);
                        this.Writer.writeLine('%s * rtm = &(dw->rtm);',this.ModelInterface.RTMTypeName);
                    end

                    this.Writer.writeLine('for(int i = 0; i < %d; ++i) {',numNonContDerivSignals);
                    this.Writer.writeLine('mxArray* prevValmxArray = mxGetCell(nonContDerivSigInfo, i);');
                    this.Writer.writeLine('(void) memcpy(rtm->nonContDerivSignal[i].pPrevVal, (char*)mxGetData(prevValmxArray), rtm->nonContDerivSignal[i].sizeInBytes);');
                    this.Writer.writeLine('}');
                    this.Writer.writeLine('}');
                end
            end
        end
        function writeSampleTimeInfo(this)
            this.Writer.writeLine('ssSetTNext(S, (time_T) mxGetScalar(mxGetFieldByNumber(ss, 0, 3)));\n');
            this.Writer.writeLine('ssSetTNextTid(S, (int_T) mxGetScalar(mxGetFieldByNumber(ss, 0, 4)));\n');
        end

        function writeLocalXSection(this,xDataType,isSingleInstance)
            this.Writer.writeLine('{\n');
            this.writeLocalXPreamble(xDataType,false,isSingleInstance);

            this.Writer.writeLine('const mxArray * storedX = mxGetFieldByNumber(ss, 0, 0);\n');
            this.Writer.writeLine('const UINT8_T * rawData = (const UINT8_T *) mxGetData(storedX);\n');
            this.Writer.writeLine('memcpy(localX, &rawData[0], numBytes);\n');
            this.Writer.writeLine('}\n');
        end
    end
end











