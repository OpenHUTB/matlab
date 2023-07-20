classdef MakeResult<handle




    properties(Hidden=true)
        Log=''
        message=''
        wrappedMakeCmd=''
        isBuildOnly=false
        success=false
    end

    methods
        function this=MakeResult...
            (buildLog,wrappedMakeCmd,isBuildOnly,message,success)
            if(nargin==0)
                return;
            end
            this.Log=buildLog;
            this.wrappedMakeCmd=wrappedMakeCmd;
            this.isBuildOnly=isBuildOnly;
            this.message=message;
            this.success=success;
        end

        function disp(this)
            disp(this.Log);
        end

        function this=propagateFromBTIMakeResult(this,makeMakeResult)
            this.Log=makeMakeResult.Log;
            this.wrappedMakeCmd=makeMakeResult.EvaluatedWrappedMakeCommand;
        end
    end
end
