





classdef convertStateVector

    methods(Static)
        function[X0,P]=toAmount(X0,P,...
            speciesIndexToConstantCompartment,speciesIndexToVaryingCompartment)
            convertSpeciesToAmount=@(x,v)x.*v;
            [X0,P]=SimBiology.internal.convertStateVector.conversionHelper(convertSpeciesToAmount,X0,P,...
            speciesIndexToConstantCompartment,speciesIndexToVaryingCompartment);
        end

        function[X0,P]=toConcentration(X0,P,...
            speciesIndexToConstantCompartment,speciesIndexToVaryingCompartment)
            convertSpeciesToConcentration=@(x,v)x./v;
            [X0,P]=SimBiology.internal.convertStateVector.conversionHelper(convertSpeciesToConcentration,X0,P,...
            speciesIndexToConstantCompartment,speciesIndexToVaryingCompartment);
        end
    end

    methods(Static,Access=private)
        function[X0,P]=conversionHelper(convertSpeciesFcn,X0,P,...
            speciesIndexToConstantCompartment,speciesIndexToVaryingCompartment)

            X0P=[X0;P];


            speciesIndex=speciesIndexToConstantCompartment(:,1);
            constantVolumeIndex=speciesIndexToConstantCompartment(:,2);
            X0P(speciesIndex)=convertSpeciesFcn(X0P(speciesIndex),P(constantVolumeIndex));


            speciesIndex=speciesIndexToVaryingCompartment(:,1);
            varyingVolumeIndex=speciesIndexToVaryingCompartment(:,2);
            X0P(speciesIndex)=convertSpeciesFcn(X0P(speciesIndex),X0(varyingVolumeIndex));

            nX0=numel(X0);
            X0=X0P(1:nX0);
            P=X0P(nX0+1:end);
        end
    end
end
