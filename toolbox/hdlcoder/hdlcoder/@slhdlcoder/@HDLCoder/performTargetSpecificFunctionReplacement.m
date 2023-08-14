function tcgInventory=performTargetSpecificFunctionReplacement(this,p)
    tcgInventory=[];
    gp=pir;
    if~gp.getTargetCodeGenSuccess
        return;
    end
    gp.setTargetCodeGenSuccess(false);

    targetDriver=this.getTargetCodeGenDriver(p);
    if~isempty(targetDriver)
        if this.getParameter('ResourceReport')
            gp.initNumOfNetworkInstances();
        end
        targetDriver.replaceWithTargetFunctions(p,this);
        tcgInventory=targetDriver.getInventory;
    end
end