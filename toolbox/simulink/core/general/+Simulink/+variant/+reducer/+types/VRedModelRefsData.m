classdef(Hidden,Sealed)VRedModelRefsData<handle




    properties
        Name(1,:)char;
        IsProtected=[];
        RootPathPrefix=[];
        RefInports=[];
        RefOutports=[];
    end

    methods
        function tf=eq(obj,other)



            assert(isscalar(other));
            if isempty(obj)
                tf=false;
                return;
            end


            tf(size(obj))=false;
            for oidx=1:numel(obj)
                tf(oidx)=isequal(obj(oidx),other);
            end
            tf=tf(:);
        end
    end
end
