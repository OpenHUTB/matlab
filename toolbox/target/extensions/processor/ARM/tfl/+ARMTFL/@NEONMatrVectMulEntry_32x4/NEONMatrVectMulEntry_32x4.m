classdef NEONMatrVectMulEntry_32x4<RTW.TflCOperationEntryML
    methods
        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong)%#ok








            ent=[];

            if mod(hCSO.ConceptualArgs(2).getNthDimension(1),4)==0...
                &&mod(hCSO.ConceptualArgs(2).getNthDimension(2),4)==0...
                &&mod(hCSO.ConceptualArgs(3).getNthDimension(1),4)==0...
                &&hCSO.ConceptualArgs(3).getNthDimension(2)==1

                ent=RTW.TflCOperationEntry(hThis);


                ent.ConceptualArgs(1)=hCSO.ConceptualArgs(1);
                ent.ConceptualArgs(2)=hCSO.ConceptualArgs(2);
                ent.ConceptualArgs(3)=hCSO.ConceptualArgs(3);





                ent.Implementation.Arguments(2).Value=hCSO.ConceptualArgs(2).DimRange(4);

                ent.Implementation.Arguments(3).Value=hCSO.ConceptualArgs(2).DimRange(2);





            end
        end

    end
end
