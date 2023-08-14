
classdef(ConstructOnLoad)Ifx_IntMapCustomEntry<RTW.TflCFunctionEntryML
    methods
        function obj=Ifx_IntMapCustomEntry(varargin)
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



            if(isequivalent(hCSO.ConceptualArgs(2).Type,hCSO.ConceptualArgs(4).Type.BaseType)&&...
                isequivalent(hCSO.ConceptualArgs(3).Type,hCSO.ConceptualArgs(5).Type.BaseType)&&...
                isequivalent(hCSO.ConceptualArgs(1).Type,hCSO.ConceptualArgs(6).Type.BaseType))

                ent=RTW.TflCFunctionEntry(hThis);



                ent.ConceptualArgs(2).Type=hCSO.ConceptualArgs(2).Type;
                ent.ConceptualArgs(2).CheckSlope=true;
                ent.ConceptualArgs(2).CheckBias=true;
                ent.ConceptualArgs(4).Type=hCSO.ConceptualArgs(4).Type;
                ent.ConceptualArgs(4).CheckSlope=true;
                ent.ConceptualArgs(4).CheckBias=true;
                ent.ConceptualArgs(3).Type=hCSO.ConceptualArgs(3).Type;
                ent.ConceptualArgs(3).CheckSlope=true;
                ent.ConceptualArgs(3).CheckBias=true;
                ent.ConceptualArgs(5).Type=hCSO.ConceptualArgs(5).Type;
                ent.ConceptualArgs(5).CheckSlope=true;
                ent.ConceptualArgs(5).CheckBias=true;
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
