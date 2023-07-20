



function emitStart(this,codeWriter)




    funKind='Start';

    if iscell(this.LctSpecInfo.Fcns.(funKind))
        funSpec=this.LctSpecInfo.Fcns.(funKind){1};
    else
        funSpec=this.LctSpecInfo.Fcns.(funKind);
    end
    canAllocPWork=this.LctSpecInfo.DWorksForBus.Numel>=1;
    needsGlobalIOPointerAssign=this.LctSpecInfo.GlobalIO.HasPointerIO;
    if~funSpec.IsSpecified&&~canAllocPWork&&~needsGlobalIOPointerAssign
        return
    end


    this.emitBlockMethod(codeWriter,funKind,funKind,false,canAllocPWork,false);


