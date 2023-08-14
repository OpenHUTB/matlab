classdef RWGBasis<matlab.mixin.SetGet&matlab.mixin.CustomDisplay&matlab.mixin.Copyable



    properties

        Mesh(1,1)struct{isfield(Mesh,{'P','t'})}
    end

    methods
        generateBasis(obj)
    end

    properties(Hidden)
Normals
SolidIndicator
SelfIntegral
MetalBasis
NumRWG
    end

    methods(Hidden)
        generateNormals(obj)
        calculateSelfIntegrals(obj)
        tf=isMeshSolid(obj)
        out=findEdgeGroups(obj,t)
    end

end