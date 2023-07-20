function info=setupHDLEmlWorkflow(data,entryPoint)


    info=emlhdlcoder.WorkFlow.Manager.instance.wfa_setupHDLWorkflow(data,char(entryPoint.getAbsolutePath()));
end
