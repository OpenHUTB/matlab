classdef AxesParentableHelper<handle







    methods(Hidden)
        function newParent=getParentImpl(~,candidateParent)
            newParent=candidateParent;
            while~isempty(newParent)&&(newParent.Internal||~isprop(newParent,'Type'))
                newParent=newParent.NodeParent;
            end
            if isempty(newParent)
                newParent=candidateParent;
            end
        end
    end
end
