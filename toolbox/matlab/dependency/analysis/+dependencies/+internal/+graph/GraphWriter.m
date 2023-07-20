classdef(Abstract)GraphWriter<handle&matlab.mixin.Heterogeneous




    properties(Abstract,Constant)

        Extensions(1,:)string;
    end

    methods(Abstract)

        write(this,graph,file,root);
    end

end
