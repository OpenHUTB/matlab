classdef(ConstructOnLoad)SSEMatrMatrAddEntry<RTW.TflCOperationEntryML




    methods
        function obj=SSEMatrMatrAddEntry(varargin)
            mlock;
            obj@RTW.TflCOperationEntryML(varargin{:});
        end

        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong)%#ok






            ent=[];


            ent=RTW.TflCOperationEntry(hThis);


            ent.ConceptualArgs(1)=hCSO.ConceptualArgs(1);
            ent.ConceptualArgs(2)=hCSO.ConceptualArgs(2);
            ent.ConceptualArgs(3)=hCSO.ConceptualArgs(3);





            ent.Implementation.Arguments(2).Value=hCSO.ConceptualArgs(2).DimRange(1);

            ent.Implementation.Arguments(3).Value=hCSO.ConceptualArgs(2).DimRange(3);

        end

    end
end
