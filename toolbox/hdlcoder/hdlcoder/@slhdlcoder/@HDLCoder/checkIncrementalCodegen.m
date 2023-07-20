function regen=checkIncrementalCodegen(this,p)









    isIPCoreWorkFlow=this.isCodeGenForIPCore;
    targetConfig=hdlget_param(p.ModelName,'FloatingPointTargetConfig');

    if isIPCoreWorkFlow&&~isempty(targetConfig)
        changedNFPSettings=serializeOutMScripts(targetConfig);
        isRegenRequired=~strcmp(changedNFPSettings,'hdlcoder.createFloatingPointTargetConfig(''NativeFloatingPoint'')');
        if isRegenRequired
            regen=true;
            return;
        end
    end

    regen=this.getIncrementalCodeGenDriver.codeGenerationPredicate(p)...
    ||~incrementalcodegen.IncrementalCodeGenDriver.topModelPredicate(p.ModelName)...
    ||this.getParameter('Backannotation')...
    ||this.getParameter('MulticyclePathConstraints')...
    ||strcmp(this.getParameter('compilestrategy'),'CompileChanged');





end

