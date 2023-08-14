



function emitBlockMethod(this,codeWriter,funKind,methKind,canOutputExpr,canAllocPWork,canDeallocPWork)


    if nargin<7
        canDeallocPWork=false;
    end
    if nargin<6
        canAllocPWork=false;
    end
    if nargin<5
        canOutputExpr=false;
    end


    assert((canAllocPWork&&canDeallocPWork)==false);
    assert((canOutputExpr&&(canAllocPWork||canDeallocPWork))==false);
    isStartOrTerminate=canAllocPWork||canDeallocPWork;


    if iscell(this.LctSpecInfo.Fcns.(funKind))
        funSpec=this.LctSpecInfo.Fcns.(funKind){1};
    else
        funSpec=this.LctSpecInfo.Fcns.(funKind);
    end


    codeWriter.wFunctionDefStart(methKind,'(block, system) Output');

    if this.LctSpecInfo.Specs.Options.stubSimBehavior










        assertNeverCalled=~strcmp(methKind,'Start')&&~strcmp(methKind,'Terminate');
        this.emitReturnIfSimTarget(codeWriter,methKind,assertNeverCalled);
    end

    if this.HasWrapperOrIsCxx

        this.emitTestCodeFormatBlockStart(codeWriter);

        if canAllocPWork

            this.emitPWorkAllocation(codeWriter);
        end

        if funSpec.IsSpecified


            if funSpec.HasDynamicArrayOutputArg
                this.LctSpecInfo.Outputs.forEachData(@(o,id,d)setOutputCurrentDims(this,d,codeWriter));
                codeWriter.wComment('');
                if~isStartOrTerminate
                    this.emitPWorkAllocation(codeWriter,true);
                end
            end


            localDecls=this.emitLocalsForWrapperFunCall(codeWriter,funSpec);

            codeWriter.wComment('');
            codeWriter.wLine(sprintf('/* %%<Type> (%%<ParamSettings.FunctionName>): %%<Name> */'));


            this.emitExtraDeclBlockStart(codeWriter,localDecls);


            this.emitWrapperFunCall(codeWriter,funSpec,funKind);


            this.emitExtraDeclBlockEnd(codeWriter,localDecls);



            if funSpec.HasDynamicArrayOutputArg&&~isStartOrTerminate
                this.emitPWorkDeallocation(codeWriter,true);
            end
        end


        if canDeallocPWork
            this.emitPWorkDeallocation(codeWriter);
        end


        codeWriter.wBlockMiddle('%else');
    end

    if funSpec.IsSpecified
        emitBody(funSpec);
        numFunSpecs=numel(this.LctSpecInfo.Fcns.(funKind));
        if numFunSpecs>1
            for idx=2:numFunSpecs
                emitBody(this.LctSpecInfo.Fcns.(funKind){idx});
            end
        end
    else




        if strcmp(methKind,'Start')
            this.emitGlobalIO(codeWriter,methKind,this.LctSpecInfo.GlobalIO,'AssignPointer');
        end
    end


    if this.HasWrapperOrIsCxx
        this.emitTestCodeFormatBlockEnd(codeWriter);
    end


    codeWriter.wFunctionDefEnd();


    function emitBody(currentSpec)
        if canOutputExpr==true


            codeWriter.wBlockStart('%%if !LibBlockOutputSignalIsExpr(%d)',currentSpec.LhsArgs.Items(1).Id-1);
        end


        if currentSpec.HasDynamicArrayOutputArg
            this.LctSpecInfo.Outputs.forEachData(@(o,id,d)setOutputCurrentDims(this,d,codeWriter));
            codeWriter.wComment('');
        end


        this.emitLocalsForFunCall(codeWriter,currentSpec);


        this.emitNDMarshalingBeforeCall(codeWriter,currentSpec);

        if strcmp(methKind,'Outputs')


            this.emitGlobalIO(codeWriter,methKind,this.LctSpecInfo.GlobalIO,'Declare');
            this.emitGlobalIO(codeWriter,methKind,this.LctSpecInfo.GlobalIO,'Input');
        end

        if strcmp(methKind,'Start')||strcmp(methKind,'Outputs')
            this.emitGlobalIO(codeWriter,methKind,this.LctSpecInfo.GlobalIO,'AssignPointer');
        end


        codeWriter.wComment('');
        this.emitFunCall(codeWriter,currentSpec,false);

        if strcmp(methKind,'Outputs')||strcmp(methKind,'Start')




            this.emitGlobalIO(codeWriter,methKind,this.LctSpecInfo.GlobalIO,'Output');
        end


        this.emitNDMarshalingAfterCall(codeWriter,currentSpec);


        if canOutputExpr==true
            codeWriter.wBlockEnd();
        end
    end
end


function setOutputCurrentDims(this,dataSpec,codeWriter)

    if dataSpec.IsDynamicArray
        apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');
        dimStr=legacycode.lct.gen.ExprTlcEmitter.emitAllDims(this.LctSpecInfo,dataSpec,true);


        txt='';
        sep='';
        for ii=1:numel(dimStr)
            txt=sprintf('%s%s%s',txt,sep,dimStr{ii});
            sep=', ';
        end
        codeWriter.wLine('%%<%s>.set_size(%s);',apiInfo.Val,txt);

    end

end


