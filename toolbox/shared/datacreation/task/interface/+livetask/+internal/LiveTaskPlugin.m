classdef(Hidden)LiveTaskPlugin<handle&matlab.mixin.Heterogeneous






    properties(Access=public,Transient,Constant,Abstract)


        LiveTaskKey char

        LiveTaskKeyValue char

    end


    methods(Access=public,Static,Abstract)




        aContributor=getContributor;





        boolOut=isSupported;
    end
end
