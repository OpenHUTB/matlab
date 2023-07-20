classdef(Abstract)GraphReader<handle&matlab.mixin.Heterogeneous




    properties(Abstract,Constant)

        Extensions(1,:)string;
    end

    methods(Abstract)

        graph=read(this,file,root);
    end

end
