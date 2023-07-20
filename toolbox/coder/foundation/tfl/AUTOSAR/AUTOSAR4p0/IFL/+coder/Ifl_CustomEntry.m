
classdef(ConstructOnLoad)Ifl_CustomEntry<RTW.TflCFunctionEntryML
    methods
        function obj=Ifl_CustomEntry(varargin)
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

            ent=RTW.TflCFunctionEntry(hThis);




            if(slfeature('MacroAccessLookupTables'))
                if((strcmp(hThis.Key,'lookup1D')||strcmp(hThis.Key,'lookup2D'))||...
                    (strcmp(hThis.Key,'prelookup')||strcmp(hThis.Key,'interp1D')||strcmp(hThis.Key,'interp2D')))
                    fcnName=hThis.getImplementationFunctionName(hCSO);







                    if~isempty(fcnName)
                        if(isempty(coder.getObjectName(hCSO)))


                            ent=[];
                        else


                            ent.Implementation.Name=fcnName;
                            ent.EntryInfo.ObjectName=coder.getObjectName(hCSO);
                        end
                    end
                end
            end

        end
        function fcnName=getImplementationFunctionName(hThis,hCSO)%#ok
            fcnName='';
        end
    end
end
