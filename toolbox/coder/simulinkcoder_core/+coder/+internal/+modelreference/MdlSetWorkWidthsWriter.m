




classdef MdlSetWorkWidthsWriter<coder.internal.modelreference.FunctionInterfaceWriter
    properties(Access=private)
        UniqueToFiles={}
        UniqueFromFiles={}
        ModelOutputSizeDependOnlyInputSize=false;
    end


    methods(Access=public)
        function this=MdlSetWorkWidthsWriter(modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter([],modelInterfaceUtils,codeInfoUtils,writer);
            this.init;
        end
    end



    methods(Access=public)
        function write(this)
            this.writeFunctionHeader;
            this.writeFunctionBody;
            this.writeFunctionTrailer;
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~,~)
            p='void mdlSetWorkWidths(SimStruct *S)';
        end

        function writeFunctionHeader(this,~)
            this.Writer.writeLine('\n#define MDL_SET_WORK_WIDTHS\n');
            writeFunctionHeader@coder.internal.modelreference.FunctionInterfaceWriter(...
            this);
        end

        function writeFunctionBody(this)
            this.Writer.writeString('if (S->mdlInfo->genericFcn != (NULL)) {')
            this.Writer.writeString('_GenericFcn fcn  = S->mdlInfo->genericFcn;');
            this.writeOutputSizeComputeSize;
            this.writeRegisterSetOutputSizeRuleTerms;
            this.writeAllowInStateEnabledSubsystem;
            this.Writer.writeLine('}');
            this.writeFromAndToFileInformation;
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end


        function writeFromAndToFileInformation(this)
            this.Writer.writeString('{');
            this.Writer.writeLine('static const char* toFileNames[]   =  {%s};',this.getToFileString);
            this.Writer.writeLine('static const char* fromFileNames[] =  {%s};',this.getFromFileString);

            this.Writer.writeLine('if(!ssSetModelRefFromFiles(S, %d, fromFileNames)) return;',length(this.UniqueFromFiles));
            this.Writer.writeLine('if(!ssSetModelRefToFiles(S, %d, toFileNames)) return;',length(this.UniqueToFiles));
            this.Writer.writeString('}');
        end
    end


    methods(Access=private)
        function init(this)
            this.ModelOutputSizeDependOnlyInputSize=this.ModelInterfaceUtils.isModelOutputSizeDependOnlyInputSize;
            this.UniqueToFiles=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'UniqueToFiles');
            this.UniqueFromFiles=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'UniqueFromFiles');
        end


        function writeOutputSizeComputeSize(this)
            if this.ModelOutputSizeDependOnlyInputSize
                this.Writer.writeString('ssSetSignalSizesComputeType(S, SS_VARIABLE_SIZE_FROM_INPUT_SIZE);');
            else
                this.Writer.writeString('ssSetSignalSizesComputeType(S, SS_VARIABLE_SIZE_FROM_INPUT_VALUE_AND_SIZE);');
            end
        end


        function writeRegisterSetOutputSizeRuleTerms(this)
            if this.ModelOutputSizeDependOnlyInputSize
                if isfield(this.ModelInterface,'Outports')
                    outports=this.ModelInterface.Outports;
                    num=length(outports);
                    if(num==1)
                        this.writeRegisterSetOutputSizeRuleTermsForPort(outports,1);
                    else
                        for portIdx=1:num
                            this.writeRegisterSetOutputSizeRuleTermsForPort(outports{portIdx},portIdx);
                        end
                    end

                    if~this.ModelInterface.LibSystemFcnIsEmpty
                        this.Writer.writeLine('ssRegMdlRefFinalizeDimsMethod(S, mdlFinalizeDimsFcn);');
                    end
                end
            end
        end


        function writeRegisterSetOutputSizeRuleTermsForPort(this,port,portIdx)
            if port.IsVarDim
                this.Writer.writeLine('{');
                this.Writer.writeLine('int ninps[] = {%s};',this.DataTypeUtils.int2str(port.NumInputsDimsDependRules));
                this.Writer.writeLine('int inputs[]  = {%s};',this.DataTypeUtils.int2str(port.DimsDependRulesInputIndices));
                this.Writer.writeLine('MdlRefOutDimsInfo_T ruleInfo;');
                this.Writer.writeLine('ruleInfo.numRules = %d;',length(port.NumInputsDimsDependRules));
                this.Writer.writeLine('ruleInfo.numInpsRule = ninps;');
                this.Writer.writeLine('ruleInfo.inpIndices = inputs;');
                this.Writer.writeLine('ruleInfo.setOutputDimsRuleFcn = mdlSetOutputDimsRuleFcn;');
                this.Writer.writeLine('ssRegMdlRefSetOutputDimsMethods(S, %d, &ruleInfo);',portIdx-1);
                this.Writer.writeLine('}');
            end
        end

        function writeAllowInStateEnabledSubsystem(this)
            if isfield(this.ModelInterface,'AllowInStateEnabledSubsystem')
                if this.ModelInterface.AllowInStateEnabledSubsystem
                    this.Writer.writeLine('ssSetModelReferenceAllowInStateEnabledSubsystem(S, true);');
                else
                    this.Writer.writeLine('ssSetModelReferenceAllowInStateEnabledSubsystem(S, false);');
                end
            end
        end


        function toFileStr=getToFileString(this)
            if isempty(this.UniqueToFiles)
                toFileStr='""';
            else
                num=length(this.UniqueToFiles);
                toFileStr=['"',this.UniqueToFiles{1}.Name,'"'];
                for idx=2:num
                    toFileStr=[toFileStr,',"',this.UniqueToFiles{idx}.Name,'"'];%#ok
                end
            end
        end


        function fromFileStr=getFromFileString(this)
            if isempty(this.UniqueFromFiles)
                fromFileStr='""';
            else
                num=length(this.UniqueFromFiles);
                fromFileStr=['"',this.UniqueFromFiles{1}.Name,'"'];
                for idx=2:num
                    fromFileStr=[fromFileStr,', "',this.UniqueFromFiles{idx}.Name,'"'];%#ok
                end
            end
        end
    end
end


