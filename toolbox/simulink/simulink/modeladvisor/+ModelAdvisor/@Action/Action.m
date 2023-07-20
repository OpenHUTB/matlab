classdef(CaseInsensitiveProperties=true)Action<matlab.mixin.Heterogeneous&matlab.mixin.Copyable
    properties(Hidden=true)

        CallbackHandle=[];


        Enable=false;


        Success=false;


        ResultInHTML='';
    end

    properties(SetAccess=public)



        Name='';


        Description='';
    end

    methods
        function obj=Action
mlock
        end

        function setCallbackFcn(this,value)
            this.CallbackHandle=value;
        end
    end

end