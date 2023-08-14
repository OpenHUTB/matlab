



function safeSlvnv(fcnHandle,analyzedModel,type,args)
    try
        fcnHandle(args{:});
    catch me

        if me.identifier=="Simulink:Commands:InvSimulinkObjHandle"||...
            me.identifier=="Slvnv:simcoverage:cvhtml:IncompatibleModel"
            MException(stm.internal.Coverage.getCovErrorMsg(analyzedModel,type)).throw;
        elseif me.identifier=="MATLAB:MKDIR:OSError"
            model=args{1}.modelinfo.analyzedModel;
            dir=get_param(model,'CovOutputDir');
            MException(message('stm:CoverageStrings:NoPermissions',dir,model)).throw;
        end

        rethrow(me);
    end
end
