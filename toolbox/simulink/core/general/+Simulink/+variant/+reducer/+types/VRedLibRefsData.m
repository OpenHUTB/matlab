classdef(Hidden,Sealed)VRedLibRefsData<handle




    properties
        Name(1,:)char;
        IsProtected(1,1)logical;
        RootPathPrefix=[];
        RefInports=[];
        RefOutports=[];
    end
end
