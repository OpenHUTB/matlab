classdef autoblksGasMixture



    properties(SetAccess=private)
MixtureName
GasNames
GasMassFracs
MassFracStruct
    end

    methods

        function obj=autoblksGasMixture(MixName,SpecNames,MassFracs)
            obj.MixtureName=MixName;
            obj.GasNames=cellstr(SpecNames);
            obj.GasMassFracs=MassFracs;
            for i=1:length(obj.GasNames)
                obj.MassFracStruct.(obj.GasNames{i})=obj.GasMassFracs(i);
            end
        end




        function SpeciesMassFracs=SpeciesFrac(obj,MixtureFrac)
            SpeciesMassFracs=obj.GasMassFracs*MixtureFrac;
        end


        function Formula=ChemFormula(obj)
            [AtomMat,AtomNames]=autoblksatomic(obj.GasNames);
            AtomNames=cellstr(AtomNames);
            MWAll=autoblksmolweight(obj.GasNames);
            MoleFrac=obj.GasMassFracs(:)./MWAll(:)/sum(obj.GasMassFracs(:)./MWAll(:));
            Coeff=AtomMat*MoleFrac;
            Formula=[];
            for i=1:length(AtomNames)
                Formula=[Formula,AtomNames{i},num2str(Coeff(i),5)];
            end

        end
    end

end

