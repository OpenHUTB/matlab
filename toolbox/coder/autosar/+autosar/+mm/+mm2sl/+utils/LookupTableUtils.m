classdef LookupTableUtils




    methods(Static)
        function isFixAxisLUT=isFixAxisLUT(m3iType)

            isFixAxisLUT=false;
            if isa(m3iType,'Simulink.metamodel.types.LookupTableType')
                m3iAxis=m3iType.Axes.at(1);
                isFixAxisLUT=autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxis(m3iAxis);
            end
        end
        function isFixAxis=isFixAxis(m3iAxis)
            isFixAxis=m3iAxis.SwGenericAxisParamType.isvalid()&&...
            m3iAxis.SwGenericAxisParamType.size>0;
        end
    end
end


