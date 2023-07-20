



function emitOutputs(this,codeWriter)


    funKind='Output';
    funSpec=this.LctSpecInfo.Fcns.(funKind);
    if~funSpec.IsSpecified
        return
    end







    canOutputExpr=funSpec.LhsArgs.Numel==1&&...
    (this.LctSpecInfo.Outputs.Numel<=1)&&...
    (this.LctSpecInfo.hasRowMajorNDArray==false);


    this.emitBlockMethod(codeWriter,funKind,'Outputs',canOutputExpr,false,false);
