classdef XMLOptionsLookupTableUtils<handle




    methods(Static,Access=public)
        function isTrue=canExportLUTApplicationValueSpecification(m3iComp)


            import autosar.mm.util.XMLOptionsLookupTableUtils.hasLUTApplicationValueSpecification;

            isTrue=true;
            if isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
                return;
            end
            m3iBehavior=m3iComp.Behavior;
            for ii=1:m3iBehavior.Parameters.size()
                m3iType=m3iBehavior.Parameters.at(ii).Type;
                if m3iType.isvalid()&&...
                    (isa(m3iType,'Simulink.metamodel.types.SharedAxisType')||...
                    isa(m3iType,'Simulink.metamodel.types.LookupTableType'))
                    if hasLUTApplicationValueSpecification(m3iBehavior.Parameters.at(ii).InitValue)
                        isTrue=true;
                        return;
                    else
                        isTrue=false;
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function isTrue=hasLUTApplicationValueSpecification(m3iConst)


            import autosar.mm.util.XMLOptionsLookupTableUtils.hasLUTApplicationValueSpecification;
            if isa(m3iConst,'Simulink.metamodel.types.ConstantReference')
                isTrue=hasLUTApplicationValueSpecification(m3iConst.Value);
            elseif isa(m3iConst,'Simulink.metamodel.types.ConstantSpecification')
                isTrue=hasLUTApplicationValueSpecification(m3iConst.ConstantValue);
            else
                isTrue=isa(m3iConst,'Simulink.metamodel.types.LookupTableSpecification')||...
                isa(m3iConst,'Simulink.metamodel.types.ApplicationValueSpecification');
            end
        end
    end
end


