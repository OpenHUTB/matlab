function[success,errors,fatalError,portInfo]=getHDLEmlPortInfo(data,entryPoint)


    [success,errors,fatalError,portInfo]=emlhdlcoder.WorkFlow.Manager.instance.wfa_getPortInfo(data,char(entryPoint.getAbsolutePath()));
end
