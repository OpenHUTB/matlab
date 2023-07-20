classdef MdlInitSystemMatricesWriter<handle




    properties(Access=protected)
ModelInterface
Writer
        HeaderWriter=coder.internal.modelreference.SimTargetCodeWriter.empty;
        Linkage=coder.internal.modelreference.FunctionLinkage.Internal
    end


    methods(Access=public)
        function this=MdlInitSystemMatricesWriter(modelInterface,writer)
            this.ModelInterface=modelInterface;
            this.Writer=writer;
        end


        function write(this)
            if this.ModelInterface.ModelIsLinearlyImplicit
                this.writeFunctionHeader;
                this.writeFunctionBody;
                this.writeFunctionTrailer;
                if~isempty(this.HeaderWriter)
                    assert(this.Linkage==coder.internal.modelreference.FunctionLinkage.External)
                    this.declareInHeader();
                end
            end
        end
    end



    methods(Access=protected)
        function p=getFunctionPrototype(~)
            p='void mdlInitSystemMatrices(SimStruct *S)';
        end

        function writeFunctionHeader(this)
            this.Writer.writeLine('\n#define MDL_INIT_SYSTEM_MATRICES\n');
            prototype=this.getFunctionPrototype();
            if this.Linkage==...
                coder.internal.modelreference.FunctionLinkage.Internal
                linkageString='static';
            else
                linkageString='';
            end
            this.Writer.writeLine('%s %s {',linkageString,prototype);
        end

        function declareInHeader(this)
            this.HeaderWriter.writeLine('%s;',this.getFunctionPrototype());
        end

        function writeFunctionBody(this)
            numberOfContinuousStates=this.ModelInterface.NumContStates;
            modelMassMatrixIr=this.ModelInterface.ModelMassMatrixIr;
            modelMassMatrixJc=this.ModelInterface.ModelMassMatrixJc;
            numberOfNonZero=modelMassMatrixJc(numberOfContinuousStates+1);


            this.Writer.writeLine('static int_T modelMassMatrixIr[%d] = {',numberOfNonZero);
            this.Writer.writeLine(this.convertIntArrayToString(modelMassMatrixIr,numberOfNonZero));
            this.Writer.writeLine('};');


            this.Writer.writeLine('static int_T modelMassMatrixJc[%d] = {',numberOfContinuousStates+1);
            this.Writer.writeLine(this.convertIntArrayToString(modelMassMatrixJc,numberOfContinuousStates+1));
            this.Writer.writeLine('};');


            this.Writer.writeLine('static real_T modelMassMatrixPr[%d] = {',numberOfNonZero);
            this.Writer.writeLine(this.convertIntArrayToString(ones(numberOfNonZero,1),numberOfNonZero));
            this.Writer.writeLine('};');

            this.Writer.writeLine('int_T *massMatrixIr = ssGetMassMatrixIr(S);');
            this.Writer.writeLine('int_T *massMatrixJc = ssGetMassMatrixJc(S);');
            this.Writer.writeLine('real_T *massMatrixPr = ssGetMassMatrixPr(S);');
            this.Writer.writeLine('(void) memcpy(massMatrixIr, modelMassMatrixIr, %d*sizeof(int_T));',numberOfNonZero);
            this.Writer.writeLine('(void) memcpy(massMatrixJc, modelMassMatrixJc, %d*sizeof(int_T));',numberOfContinuousStates+1);
            this.Writer.writeLine('(void) memcpy(massMatrixPr, modelMassMatrixPr, %d*sizeof(real_T));',numberOfNonZero);
        end


        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end
    end


    methods(Static,Access=protected)
        function strbuf=convertIntArrayToString(values,numberOfElements)
            strbuf='';
            for idx=1:numberOfElements
                val=values(idx);
                if(idx>1)
                    strbuf=[strbuf,', ',int2str(val)];%#ok
                else
                    strbuf=[strbuf,int2str(val)];%#ok
                end
            end
        end
    end
end
