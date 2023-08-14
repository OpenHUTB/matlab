function reqSet=getClipboardReqSet(this)







    reqSet=this.findRequirementSet('clipboard.slreqx');
    if isempty(reqSet)
        reqSet=this.addRequirementSet('clipboard.slreqx');
    end
end
