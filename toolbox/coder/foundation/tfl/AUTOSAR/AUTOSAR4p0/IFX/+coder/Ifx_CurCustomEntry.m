
classdef(ConstructOnLoad)Ifx_CurCustomEntry<RTW.TflCFunctionEntryML
    methods
        function obj=Ifx_CurCustomEntry(varargin)
            mlock;
            obj@RTW.TflCFunctionEntryML(varargin{:});
        end
        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong,...
            targetBitPerLongLong)%#ok

            ent=[];


            if(isequivalent(hCSO.ConceptualArgs(1).Type,hCSO.ConceptualArgs(4).Type.BaseType))

                ent=RTW.TflCFunctionEntry(hThis);



                ent.ConceptualArgs(1).Type=hCSO.ConceptualArgs(1).Type;
                ent.ConceptualArgs(1).CheckSlope=true;
                ent.ConceptualArgs(1).CheckBias=true;
                ent.ConceptualArgs(4).Type=hCSO.ConceptualArgs(4).Type;
                ent.ConceptualArgs(4).CheckSlope=true;
                ent.ConceptualArgs(4).CheckBias=true;
                ent.ConceptualArgs(5).Type=hCSO.ConceptualArgs(5).Type;
                ent.ConceptualArgs(5).CheckType=true;


                if(slfeature('MacroAccessLookupTables'))
                    ent=coder.MacroAccessImplementation(ent,hThis,hCSO);
                end

            end
        end
        function fcnName=getImplementationFunctionName(hThis,hCSO)%#ok
            fcnName='';
        end
    end
end
