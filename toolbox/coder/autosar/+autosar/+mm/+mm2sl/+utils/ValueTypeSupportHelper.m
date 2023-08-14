classdef ValueTypeSupportHelper<handle













    properties(Access=private)
        UnsupportedADTs autosar.mm.util.Set
    end

    methods
        function self=ValueTypeSupportHelper(m3iModel,app2DataTypeMapObjMap,useValueTypes)
            self.UnsupportedADTs=autosar.mm.util.Set();

            if useValueTypes
                autosarCompatibilityChecker=autosar.mm.mm2sl.utils.ValueTypeAutosarCompatibilityChecker(self.UnsupportedADTs);
                autosarCompatibilityChecker.selectUnsupportedTypes(app2DataTypeMapObjMap);
                autosar.mm.mm2sl.utils.ValueTypeSimulinkCompatibilityChecker(m3iModel,self.UnsupportedADTs);
            end
        end

        function isAllowed=canM3ITypeBeModeledAsValueType(self,m3iType)
            isAllowed=false;
            if~m3iType.IsApplication
                return;
            end
            if~self.UnsupportedADTs.isKey(m3iType.Name)
                isAllowed=true;
            end
        end
    end
end


