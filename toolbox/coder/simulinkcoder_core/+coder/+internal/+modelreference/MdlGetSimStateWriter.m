




classdef MdlGetSimStateWriter<coder.internal.modelreference.MdlGetSetSimStateWriterBase
    methods(Access=public)
        function this=MdlGetSimStateWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.MdlGetSetSimStateWriterBase(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end
    end


    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='mxArray* mdlGetSimState(SimStruct *S)';
        end

        function writeFunctionBody(this)
            this.writeSimStateStructureDeclaration;

            isSingleInstance=~this.ModelInterface.OkToMultiInstance;
            xDataType=this.ModelInterface.xDataType;
            if~isempty(xDataType)
                this.writeLocalXSection(xDataType,isSingleInstance);
            end

            this.Writer.writeLine('{\n');
            fcnName=this.ModelInterface.ModelGetDWorkFcnName;
            if isSingleInstance
                this.Writer.writeLine(['mxArray * mdlrefDW = ',fcnName,'();\n']);
            else
                this.Writer.writeLine(['mxArray * mdlrefDW = ',fcnName,'(',this.getSsGetDWorkCall(true),');\n']);
            end

            this.Writer.writeLine('mxSetFieldByNumber(ss, 0, 1, mdlrefDW);\n');

            this.Writer.writeLine('}\n');

            this.writeDisallowedStateInfo;

            this.writeSampleTimeInfo;

            this.writeNonContDerivSigInfo;

            this.Writer.writeLine('return ss;\n');
        end
    end

    methods(Access=private)
        function writeSampleTimeInfo(this)
            this.Writer.writeLine('mxSetFieldByNumber(ss, 0, 3, mxCreateDoubleScalar((double)ssGetTNext(S)));\n');
            this.Writer.writeLine('mxSetFieldByNumber(ss, 0, 4, mxCreateDoubleScalar((double)ssGetTNextTid(S)));\n');
        end

        function writeDisallowedStateInfo(this)
            this.Writer.writeLine('{\n');
            fcnName=this.ModelInterface.ModelGetSimStateDisallowedBlocksFcnName;
            this.Writer.writeLine(['mxArray * data = ',fcnName,'();\n']);
            this.Writer.writeLine('mxSetFieldByNumber(ss, 0, 2, data);\n');
            this.Writer.writeLine('};\n');
        end

        function writeSimStateStructureDeclaration(this)
            this.Writer.writeLine('static const char* simStateFieldNames[6] = {\n');
            this.Writer.writeLine('"localX",\n');
            this.Writer.writeLine('"mdlrefDW",\n');
            this.Writer.writeLine('"disallowedStateData",\n');
            this.Writer.writeLine('"tNext",\n');
            this.Writer.writeLine('"tNextTid",\n');
            this.Writer.writeLine('"nonContDerivSigInfoPrevVal",\n');
            this.Writer.writeLine('};\n');
            this.Writer.writeLine('mxArray* ss = mxCreateStructMatrix(1, 1, 6, simStateFieldNames);\n');
        end

        function writeNonContDerivSigInfo(this)
            if strcmp(this.ModelInterface.SolverType,'VariableStep')
                numNonContDerivSignals=this.ModelInterface.SolverResetInfo.NumNonContDerivSignals;
                if numNonContDerivSignals~=0
                    this.Writer.writeLine('{\n');
                    if~this.ModelInterfaceUtils.isMultiInstance
                        dworkIdentifier=this.ModelInterface.SFcnDWorkIdentifier;
                        this.Writer.writeLine('%s * rtm = &(%s.rtm);',this.ModelInterface.RTMTypeName,dworkIdentifier);
                    else
                        this.Writer.writeLine('%s * dw = (%s *) ssGetDWork(S, 0);',this.ModelInterface.DWorkType,this.ModelInterface.DWorkType);
                        this.Writer.writeLine('%s * rtm = &(dw->rtm);',this.ModelInterface.RTMTypeName);
                    end

                    this.Writer.writeLine('mxArray* nonContDerivSigInfo = mxCreateCellMatrix(%d, 1);\n',numNonContDerivSignals);
                    this.Writer.writeLine('for(int i = 0; i < %d; ++i) {',numNonContDerivSignals);
                    this.Writer.writeLine('mxArray* prevValmxArray = mxCreateNumericMatrix(1, rtm->nonContDerivSignal[i].sizeInBytes, mxUINT8_CLASS, mxREAL);');
                    this.Writer.writeLine('memcpy((uint8_T*)mxGetData(prevValmxArray), (const uint8_T*)rtm->nonContDerivSignal[i].pPrevVal, rtm->nonContDerivSignal[i].sizeInBytes);');
                    this.Writer.writeLine('mxSetCell(nonContDerivSigInfo, i, prevValmxArray);');
                    this.Writer.writeLine('}\n');
                    this.Writer.writeLine('mxSetFieldByNumber(ss, 0, 5, nonContDerivSigInfo);\n');
                    this.Writer.writeLine('}\n');
                end
            end
        end

        function writeLocalXSection(this,xDataType,isSingleInstance)

            this.Writer.writeLine('{\n');
            this.writeLocalXPreamble(xDataType,true,isSingleInstance);

            this.Writer.writeLine('mxArray * storedX = mxCreateNumericMatrix(1, numBytes, mxUINT8_CLASS, mxREAL);\n');
            this.Writer.writeLine('UINT8_T * rawData = (UINT8_T *) mxGetData(storedX);\n');
            this.Writer.writeLine('memcpy(&rawData[0], localX, numBytes);\n');
            this.Writer.writeLine('mxSetFieldByNumber(ss, 0, 0, storedX);\n');
            this.Writer.writeLine('}\n');
        end
    end
end


