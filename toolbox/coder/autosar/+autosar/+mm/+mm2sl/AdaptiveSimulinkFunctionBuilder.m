classdef AdaptiveSimulinkFunctionBuilder<autosar.mm.mm2sl.SimulinkFunctionBuilder




    properties(Access=protected)
        M3IMethod;
    end

    properties(Access=protected,Dependent)
M3IPort
    end

    methods
        function this=AdaptiveSimulinkFunctionBuilder(m3iPort,m3iMethod,changeLogger)
            this@autosar.mm.mm2sl.SimulinkFunctionBuilder(m3iPort,changeLogger);
            this.M3IMethod=m3iMethod;
        end

        function m3iPort=get.M3IPort(this)



            m3iPort=this.M3iRunnable;
        end
    end

    methods(Access=protected)
        function subsystemPath=createOrUpdate(this,blockPath,parentSystem)

            [subsystemPath,triggerPortBlkPath]=...
            this.addOrGetSLFunctionAndTriggerBlock(blockPath,parentSystem);

            autosar.mm.mm2sl.SLModelBuilder.set_param(...
            this.ChangeLogger,triggerPortBlkPath,...
            'ScopeName',this.M3IPort.Name);
            autosar.mm.mm2sl.SLModelBuilder.set_param(...
            this.ChangeLogger,triggerPortBlkPath,...
            'FunctionVisibility','port');
        end

        function functionName=getFunctionName(this)
            functionName=this.M3IMethod.Name;
        end

        function subSysName=getSubsysName(this)

            subSysName=[...
            autosar.mm.util.FcnCallerHelper.getDefaultFunctionName(...
            this.M3IPort.Name,this.M3IMethod.Name),'_sys'];
        end
    end
end
