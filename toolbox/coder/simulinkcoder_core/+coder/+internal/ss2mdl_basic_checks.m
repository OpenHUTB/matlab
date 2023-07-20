function mExc=ss2mdl_basic_checks(origMdlHdl,block_hdl,thisHdl,wrapError)
    mExc=[];
    ssType=Simulink.SubsystemType(block_hdl);
    if~ssType.isSubsystem
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'NotASubsystem',[],thisHdl);
    elseif ssType.isSimulinkFunction
        mExc=MException(message('RTW:buildProcess:BuildFromSimulinkFunction'));
        if wrapError
            mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'CheckFailed',mExc,thisHdl);
        end
    else
        if~strcmp(get_param(block_hdl,'Commented'),'off')
            mExc=MException(message('RTW:buildProcess:CommentedSubsystem'));
        end

        try
            if ssType.isPhysmodSubsystem
                mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'PhysmodSystem',[],thisHdl);
            elseif ssType.isActionSubsystem
                mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'IfActionSystem',[],thisHdl);
            end
        catch exc
            mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetPortHandles',exc,thisHdl);
        end
    end
end
