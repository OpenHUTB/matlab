classdef RunnableAsSimulinkFunction<autosar.mm.mm2sl.SimulinkFunctionBuilder




    methods
        function this=RunnableAsSimulinkFunction(m3iRun,changeLogger)
            this@autosar.mm.mm2sl.SimulinkFunctionBuilder(m3iRun,changeLogger);
        end
    end

    methods(Access=protected)
        function subsystemPath=createOrUpdate(this,blockPath,parentSystem)

            [subsystemPath,triggerPortBlkPath]=...
            this.addOrGetSLFunctionAndTriggerBlock(blockPath,parentSystem);


            runnableAlreadyExists=~isempty(blockPath);
            if~runnableAlreadyExists
                this.throwWarningIfUnsupportedVariationPoint(triggerPortBlkPath);
            end

            this.updateDescription(subsystemPath);
        end

        function functionName=getFunctionName(this)

            functionName=this.M3iRunnable.symbol;
        end

        function subSysName=getSubsysName(this)

            subSysName=[this.M3iRunnable.Name,'_sys'];
        end
    end

    methods(Access=private)
        function throwWarningIfUnsupportedVariationPoint(this,triggerPortBlkPath)
            m3iRun=this.M3iRunnable;
            if~isempty(m3iRun.variationPoint)
                bindingTime=m3iRun.variationPoint.Condition.BindingTime.toString;
                if strcmp(bindingTime,'PreCompileTime')||strcmp(bindingTime,'CodeGenerationTime')
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                    triggerPortBlkPath,'Variant','on');
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                    triggerPortBlkPath,'VariantControl',m3iRun.variationPoint.Name);

                    gpcFlag.PreCompileTime='on';
                    gpcFlag.CodeGenerationTime='off';
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                    triggerPortBlkPath,'GeneratePreprocessorConditionals',gpcFlag.(bindingTime));
                else
                    warnId='autosarstandard:importer:unsupportedBindingTime';
                    warnParams={variationPoint.Condition.BindingTime.toString};
                    messageStream=autosar.mm.util.MessageStreamHandler.instance();
                    messageStream.createWarning(warnId,warnParams,...
                    triggerPortBlkPath,'modelImport');
                end
            end
        end
    end
end


