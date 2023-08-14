
function[packageError,messages]=checkDefiningClassPackage(this,classdefNode,messages)




    packageError=0;
    if~isempty(strfind(this.className,'.'))
        classLink=coder.internal.Helper.getPrintLinkStrFor(which(this.className),classdefNode.lineno,classdefNode.charno);
        messages=this.addClassConstraintFailureMessage(messages,...
        classdefNode,'Coder:FXPCONV:ClassWithinPackage',classLink);
        packageError=1;
    end
end


