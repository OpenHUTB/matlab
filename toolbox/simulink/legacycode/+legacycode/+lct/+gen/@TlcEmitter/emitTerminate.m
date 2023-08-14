



function emitTerminate(this,codeWriter)




    funKind='Terminate';
    funSpec=this.LctSpecInfo.Fcns.(funKind);
    canDeallocPWork=this.LctSpecInfo.DWorksForBus.Numel>=1;
    if~funSpec.IsSpecified&&~canDeallocPWork
        return
    end


    this.emitBlockMethod(codeWriter,funKind,funKind,false,false,canDeallocPWork);


