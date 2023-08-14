classdef(ConstructOnLoad)MatrOpEntry<RTW.TflCOperationEntryML




    methods
        function obj=MatrOpEntry(varargin)
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




            ent.Implementation.Arguments(2).Value=hCSO.ConceptualArgs(2).DimRange(4);

            ent.Implementation.Arguments(3).Value=hCSO.ConceptualArgs(2).DimRange(2);

        end

    end
end
