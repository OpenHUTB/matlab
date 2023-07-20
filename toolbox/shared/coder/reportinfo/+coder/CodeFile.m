classdef(Sealed)CodeFile<coder.File





















    properties(SetAccess=private)
        Text char=''
    end

    methods(Access={?codergui.internal.CodegenInfoBuilder,?coder.ScreenerInfo})
        function obj=CodeFile(text,path,extension,isMathWorks)
            if nargin==0
                super_args={'','',false};
            elseif nargin==4
                super_args={path,extension,isMathWorks};
            end
            obj@coder.File(super_args{:});
            narginchk(4,4);
            obj.Text=text;
        end

        function setText(obj,text)
            obj.Text=text;
        end
    end
end
