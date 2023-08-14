
classdef(ConstructOnLoad)Ifx_MapCustomEntry<RTW.TflCFunctionEntryML
    methods
        function obj=Ifx_MapCustomEntry(varargin)
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


            if(isequivalent(hCSO.ConceptualArgs(1).Type,hCSO.ConceptualArgs(6).Type.BaseType))

                ent=RTW.TflCFunctionEntry(hThis);



                ent.ConceptualArgs(1).Type=hCSO.ConceptualArgs(1).Type;
                ent.ConceptualArgs(1).CheckSlope=true;
                ent.ConceptualArgs(1).CheckBias=true;
                ent.ConceptualArgs(6).Type=hCSO.ConceptualArgs(6).Type;
                ent.ConceptualArgs(6).CheckSlope=true;
                ent.ConceptualArgs(6).CheckBias=true;
                ent.ConceptualArgs(7).Type=hCSO.ConceptualArgs(7).Type;
                ent.ConceptualArgs(7).CheckType=true;
                ent.ConceptualArgs(8).Type=hCSO.ConceptualArgs(8).Type;
                ent.ConceptualArgs(8).CheckType=true;



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
