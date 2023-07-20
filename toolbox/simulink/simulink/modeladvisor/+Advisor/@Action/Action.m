classdef(CaseInsensitiveProperties=true)Action<matlab.mixin.Heterogeneous&matlab.mixin.Copyable
    properties(SetAccess=public,Hidden=true)

        CallbackHandle=[];


        Enable=false;


        Success=false;



        Name='';


        Description='';


        ResultInHTML='';

    end

    methods
        function setCallbackFcn(this,value)




            this.CallbackHandle=value;
        end
    end
end