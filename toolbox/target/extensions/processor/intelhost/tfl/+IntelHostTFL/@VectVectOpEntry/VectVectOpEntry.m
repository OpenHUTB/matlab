classdef(ConstructOnLoad)VectVectOpEntry<RTW.TflCOperationEntryML




    methods
        function obj=VectVectOpEntry(varargin)
            mlock;
            obj@RTW.TflCOperationEntryML(varargin{:});
        end

        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong)%#ok






            ent=RTW.TflCOperationEntry(hThis);


            ent.ConceptualArgs(1)=hCSO.ConceptualArgs(1);
            ent.ConceptualArgs(2)=hCSO.ConceptualArgs(2);
            ent.ConceptualArgs(3)=hCSO.ConceptualArgs(3);





            ent.Implementation.Arguments(4).Value=max(max(hCSO.ConceptualArgs(2).DimRange));

        end

    end
end
