



classdef(Abstract)MathWorksOnly<handle
    methods
        function obj=MathWorksOnly()
            frames=dbstack(numel(superclasses(class(obj))),'-completenames');
            if isempty(frames)||~any(startsWith({frames.file},matlabroot))
                error(message('Coder:common:MathWorksUseOnlyMethod'));
            end
        end
    end
end
