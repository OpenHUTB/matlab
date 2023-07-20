



classdef TlcEmitter<legacycode.lct.gen.CodeEmitter

    properties(Constant,Hidden=true)
        SimulationCodeFormatTestStr='IsModelReferenceSimTarget() || CodeFormat=="S-Function" || ::isRAccel'
        SkipNDMarshalingTestStr='FEVAL("legacycode.lct.util.isRowMajorFeatureEnabled", "%<::CompiledModel.Name>")==TLC_TRUE'
    end


    properties(Access=protected)
        HasWrapperOrIsCxx logical=false
HeaderFileInfo
    end


    methods




        function this=TlcEmitter(lctObj)

            narginchk(1,1);
            this@legacycode.lct.gen.CodeEmitter(lctObj);
        end




        emit(this,varargin)

    end


    methods(Access=protected)


        emitHeader(this,codeWriter)
        emitBlockTypeSetup(this,codeWriter)
        emitBlockInstanceSetup(this,codeWriter)
        emitStart(this,codeWriter)
        emitInitializeConditions(this,codeWriter)
        emitOutputs(this,codeWriter)
        emitBlockOutputSignal(this,codeWriter)
        emitTerminate(this,codeWriter)
        emitTrailer(this,codeWriter)

        emitBlockMethod(this,codeWriter,funKind,methKind,canOutputExpr,canAllocPWork,canDeallocPWork)

        emitWrapperHeaderConstruction(this,codeWriter)
        emitWrapperSourceConstruction(this,codeWriter)

        emitLocalsForNDMarshaling(this,codeWriter,funSpec,fromWrapper)
        localDecl=emitLocalsForWrapperFunCall(this,codeWriter,funSpec)
        emitLocalsForFunCall(this,codeWriter,funSpec,isBlockOutputSignal)

        emitFunCall(this,codeWriter,funSpec,skipLhs,skipNDMarshaling)
        emitFunCallInWrapper(this,codeWriter,funSpec)
        emitWrapperFunCall(this,codeWriter,funSpec,funKind)

        emitNDArrayConversion(this,codeWriter,funSpec,col2Row,skipCast)
        emitStructConversion(this,codeWriter,funSpec,sl2User)

        emitPWorkAllocation(this,codeWriter,forDynArray)
        emitPWorkDeallocation(this,codeWriter,forDynArray)

        emitReturnIfSimTarget(this,codeWriter,methKind,assertNeverCalled)

        stmts=genPWorkAllocFreeFuns(this,forDef)
        [lhs,fcnName,argList]=genWrapperPrototype(this,funSpec,funKind)
        [lhs,fcnName,argList]=genFunCall(this,funSpec,skipNDMarshaling)




        function emitTestCodeFormatBlockStart(this,codeWriter)
            if this.LctSpecInfo.hasWrapper

                codeWriter.wBlockStart(['%if ',this.SimulationCodeFormatTestStr]);
            else

                codeWriter.wBlockStart('%if IsModelReferenceSimTarget()');
            end
        end




        function emitTestCodeFormatBlockEnd(~,codeWriter)
            codeWriter.wBlockEnd();
        end




        function emitExtraDeclBlockStart(~,codeWriter,declStmts)
            if~isempty(declStmts)


                codeWriter.wBlockStart('{');
                cellfun(@(aLine)codeWriter.wLine(aLine),declStmts);
            end
        end




        function emitExtraDeclBlockEnd(~,codeWriter,declStmts)
            if~isempty(declStmts)
                codeWriter.wBlockEnd();
                codeWriter.wLine('}');
            end
        end




        function emitNDMarshalingBeforeCall(this,codeWriter,funSpec)
            if this.LctSpecInfo.hasRowMajorNDArray

                codeWriter.wComment('');
                codeWriter.wBlockStart(['%if ',this.SkipNDMarshalingTestStr]);
                this.emitFunCall(codeWriter,funSpec,false,true);
                codeWriter.wBlockMiddle('%else');


                codeWriter.wBlockStart('{');
                this.emitLocalsForNDMarshaling(codeWriter,funSpec);

                this.emitNDArrayConversion(codeWriter,funSpec,true,true);
                codeWriter.wNewLine;
            end
        end




        function emitNDMarshalingAfterCall(this,codeWriter,funSpec)
            if this.LctSpecInfo.hasRowMajorNDArray

                this.emitNDArrayConversion(codeWriter,funSpec,false,true);

                codeWriter.wBlockEnd();
                codeWriter.wLine('}');


                codeWriter.wBlockEnd()
            end
        end




        function emitAddToCommonIncludes(~,codeWriter,fileList)
            if~isempty(fileList)
                for ii=1:numel(fileList)
                    theFile=fileList{ii};
                    if theFile(1)=='"'


                        theFile=theFile(2:end-1);
                    end
                    codeWriter.wLine(sprintf('%%<LibAddToCommonIncludes("%s")>',...
                    theFile));
                end
            end
        end




        function emitAddToStaticSources(~,codeWriter,fileList)
            if~isempty(fileList)
                for ii=1:numel(fileList)


                    theFile=strrep(fileList{ii},'\','\\');
                    codeWriter.wLine(sprintf('%%<SLibAddToStaticSources("%s")>',...
                    theFile));
                end
            end
        end

    end


    methods(Static)



        function emitFile(def)
            narginchk(1,1)
            o=legacycode.lct.gen.TlcEmitter(def);
            o.emit();
        end
    end

end


