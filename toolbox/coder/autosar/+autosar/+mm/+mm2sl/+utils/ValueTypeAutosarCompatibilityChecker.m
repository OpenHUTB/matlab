classdef ValueTypeAutosarCompatibilityChecker<handle






    properties(Access=private)
        UnsupportedADTs autosar.mm.util.Set
    end

    methods
        function self=ValueTypeAutosarCompatibilityChecker(unsupportedADTs)
            self.UnsupportedADTs=unsupportedADTs;
        end
    end

    methods(Access=public)
        function selectUnsupportedTypes(self,app2DataTypeMapObjMap)
            appDataTypeSet=values(app2DataTypeMapObjMap);
            for ii=1:numel(appDataTypeSet)
                appDataType=appDataTypeSet{ii}.ApplicationType;
                implDataType=appDataTypeSet{ii}.ImplementationType;
                if~isa(appDataType,"Simulink.metamodel.types.Matrix")&&...
                    strcmp(appDataType.Name,implDataType.Name)



                    self.setTypeAsUnsupported(appDataType);
                end
            end
        end
    end

    methods(Access=private)
        function setTypeAsUnsupported(self,m3iType)
            self.UnsupportedADTs.set(m3iType.Name);
        end
    end
end


