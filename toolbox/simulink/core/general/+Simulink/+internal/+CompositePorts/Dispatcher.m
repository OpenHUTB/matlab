classdef Dispatcher<handle

    properties(Access=private)


        mClassType;
        mInstance;
    end


    methods(Access=public)

        function this=Dispatcher(instance,classType)
            narginchk(2,2);
            this.mInstance=instance;
            this.mClassType=classType;
        end



        function r=dispatch(this,method)
            f=str2func([this.mClassType,'.',method]);
            r=f(this.mInstance);
        end
    end
end
