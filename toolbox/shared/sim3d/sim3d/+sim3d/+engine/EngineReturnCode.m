classdef(Hidden)EngineReturnCode




    properties(Constant=true)
        No_Subscriber=-2
        No_Data=-1
        OK=0
        Error=1
        Unsupported=2
        Bad_Parameter=3
        Precondition_Not_Met=4
        Out_Of_Resources=5
        Not_Enabled=6
        Immutable_Policy=7
        Inconsistent_Policy=8
        Already_Deleted=9
        Timeout=10
        Illegal_Operation=11
        Incompatible=12
        EntryPointNotFound=13
    end

    methods(Static)
        function assertObject(obj)
            if isempty(obj)||obj==uint64(0)
                callStack=dbstack;
                callerID=replace(callStack(2).name,".",":");
                errID="sim3d:"+callerID+":InvalidObject";
                msgTest='3D Simulation %s Error: Is the 3D Simulation engine running?';
                me=MException(errID,msgTest,callerID);
                throwAsCaller(me);
            end
        end

        function assertReturnCodeIgnoreWarnings(retcode)
            if retcode>sim3d.engine.EngineReturnCode.OK
                callStack=dbstack;
                callerID=replace(callStack(2).name,".",":");
                errID="sim3d:"+callerID+":IgnoreWarningsError";
                msgTest='3D Simulation %s: error code: %d.';
                me=MException(errID,msgTest,callerID,retcode);
                throwAsCaller(me);
            end
        end

        function assertReturnCode(retcode)
            if retcode~=sim3d.engine.EngineReturnCode.OK
                callStack=dbstack;
                callerID=replace(callStack(2).name,".",":");
                errID="sim3d:"+callerID+":Error";
                msgTest='3D Simulation %s: error code: %d.';
                me=MException(errID,msgTest,callerID,retcode);
                throwAsCaller(me);
            end
        end

        function assertReturnCodeAndWarnNoData(retcode,block,steps)
            sim3d.engine.EngineReturnCode.assertReturnCodeIgnoreWarnings(retcode);
            if retcode==sim3d.engine.EngineReturnCode.No_Data
                if(steps==1)
                    warning(message("shared_sim3d:sim3dEngine:BlockPriorityWarning",block,retcode));
                else
                    warning(message("shared_sim3d:sim3dEngine:BlockNoDataWarning",block,retcode));
                end
            end
        end
    end
end

