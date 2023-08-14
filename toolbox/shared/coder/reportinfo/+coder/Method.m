classdef(Sealed)Method<coder.Function































































    properties(SetAccess=immutable)
        ClassName char=''
        ClassSpecialization double=0
    end

    methods(Access=?codergui.internal.CodegenInfoBuilder)
        function obj=Method(name,specialization,className,...
            classSpecialization,file,variables,showVariableTypeInfo)
            if nargin==0
                showVariableTypeInfo=false;
                super_args={'',0,coder.File.empty(),coder.Variable.empty(),showVariableTypeInfo};
            elseif nargin==7
                super_args={name,specialization,file,variables,showVariableTypeInfo};
            end
            obj@coder.Function(super_args{:});
            narginchk(7,7);
            obj.ClassName=className;
            obj.ClassSpecialization=classSpecialization;
        end
    end
end

