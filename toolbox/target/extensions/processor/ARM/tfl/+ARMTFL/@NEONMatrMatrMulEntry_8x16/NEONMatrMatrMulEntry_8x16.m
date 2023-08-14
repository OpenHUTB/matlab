classdef NEONMatrMatrMulEntry_8x16<RTW.TflCOperationEntryML
    methods
        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong)%#ok








            ent=[];

            if mod(hCSO.ConceptualArgs(1).getNthDimension(1),16)==0...
                &&mod(hCSO.ConceptualArgs(1).getNthDimension(2),16)==0...
                &&mod(hCSO.ConceptualArgs(2).getNthDimension(1),16)==0...
                &&mod(hCSO.ConceptualArgs(2).getNthDimension(2),16)==0

                ent=RTW.TflCOperationEntry(hThis);


                ent.ConceptualArgs(1)=hCSO.ConceptualArgs(1);
                ent.ConceptualArgs(2)=hCSO.ConceptualArgs(2);
                ent.ConceptualArgs(3)=hCSO.ConceptualArgs(3);





                ent.Implementation.Arguments(2).Value=hCSO.ConceptualArgs(2).DimRange(2);

                ent.Implementation.Arguments(3).Value=hCSO.ConceptualArgs(2).DimRange(4);



                ent.Implementation.Arguments(5).Value=hCSO.ConceptualArgs(3).DimRange(4);

            end
        end

    end
end
