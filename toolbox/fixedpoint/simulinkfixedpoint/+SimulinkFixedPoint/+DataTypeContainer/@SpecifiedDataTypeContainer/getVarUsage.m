function varUsages=getVarUsage(this)




    varUsages=[];



    if this.isVarName&&...
        (getSimulinkBlockHandle(this.contextPath)~=-1...
        ||isvarname(this.contextPath))
        varUsages=Simulink.findVars(...
        this.contextPath,...
        'Name',this.origDTString,'SearchMethod','cached');
    end

end

