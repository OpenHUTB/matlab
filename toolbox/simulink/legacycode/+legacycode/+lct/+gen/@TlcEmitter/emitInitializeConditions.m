



function emitInitializeConditions(this,codeWriter)


    funKind='InitializeConditions';
    funSpec=this.LctSpecInfo.Fcns.(funKind);
    if~funSpec.IsSpecified
        return
    end


    this.emitBlockMethod(codeWriter,funKind,funKind,false,false,false);
