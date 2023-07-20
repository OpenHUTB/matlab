classdef ValueTypeSimulinkCompatibilityChecker<autosar.mm.util.TypeVisitor











    properties(Access=private)
        UnsupportedADTs autosar.mm.util.Set
    end

    methods
        function self=ValueTypeSimulinkCompatibilityChecker(m3iModel,unsupportedADTs)

            self=self@autosar.mm.util.TypeVisitor(m3iModel);

            self.UnsupportedADTs=unsupportedADTs;
            self.selectUnsupportedTypes();
        end
    end

    methods(Access=protected)
        function ret=acceptEnumeration(~,~,~)
            ret=[];
        end

        function ret=acceptEnumerationLiteral(~,~,~,~)
            ret=[];
        end

        function ret=acceptStructure(self,type,~)
            ret=[];
            self.setTypeAsUnsupported(type);
        end

        function ret=acceptStructureField(self,~,field)
            ret=[];
            self.setTypeAsUnsupported(field.ReferencedType);
            self.apply(field.ReferencedType);
        end

        function ret=acceptMatrix(self,type,elemType)
            ret=[];
            self.setTypeAsUnsupported(type);
            self.apply(elemType);
        end

        function ret=acceptLookupTableType(self,type,elemType)
            ret=[];
            self.setTypeAsUnsupported(type);
            self.apply(elemType);
            if type.ValueAxisDataType.isvalid()
                self.apply(type.ValueAxisDataType);
            end
            for ii=1:type.Axes.size()
                axis=type.Axes.at(ii);
                if axis.SharedAxis.isvalid()
                    self.apply(axis.SharedAxis);
                else
                    if autosar.mm.mm2sl.TypeBuilder.hasValidInputVariableType(axis)
                        self.apply(axis.InputVariableType);
                    else
                        self.apply(axis.BaseType);
                    end
                end
            end
        end

        function ret=acceptSharedAxisType(self,type,elemType)
            ret=[];
            self.setTypeAsUnsupported(type);
            self.apply(elemType);
            if type.ValueAxisDataType.isvalid()
                self.setTypeAsUnsupported(type.ValueAxisDataType);
            elseif autosar.mm.mm2sl.TypeBuilder.hasValidInputVariableType(type.Axis)
                self.apply(type.Axis.InputVariableType);
            else
                self.apply(type.Axis.BaseType);
            end
        end

        function ret=acceptInteger(self,type)
            ret=[];
            self.setTypeAsUnsupported(type);
        end

        function ret=acceptBoolean(self,type)
            ret=[];
            self.setTypeAsUnsupported(type);
        end

        function ret=acceptFloatingPoint(self,type)
            ret=[];
            self.setTypeAsUnsupported(type);
        end

        function ret=acceptFixedPoint(self,type)
            ret=[];
            self.setTypeAsUnsupported(type);
        end

        function ret=acceptVoidPointer(self,type)
            ret=[];
            self.setTypeAsUnsupported(type);
        end

        function ret=acceptString(self,type)
            ret=[];
            self.setTypeAsUnsupported(type);
        end

    end

    methods(Access=private)
        function selectUnsupportedTypes(self)



            paramDatas=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,...
            Simulink.metamodel.arplatform.interface.ParameterData.MetaClass());
            for ii=1:paramDatas.size()

                m3iType=paramDatas.at(ii).Type;
                if m3iType.isvalid()
                    self.apply(m3iType);
                end
            end
            argDatas=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,...
            Simulink.metamodel.arplatform.interface.ArgumentData.MetaClass());
            for ii=1:argDatas.size()

                m3iType=argDatas.at(ii).Type;
                if m3iType.isvalid()
                    self.apply(m3iType);
                end
            end
            sigDatas=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,...
            Simulink.metamodel.arplatform.interface.VariableData.MetaClass());
            for ii=1:sigDatas.size()

                m3iType=sigDatas.at(ii).Type;
                if m3iType.isvalid()
                    self.apply(m3iType);
                end
            end

            matrixes=autosar.mm.Model.findObjectByMetaClass(self.m3iModel,...
            Simulink.metamodel.types.Matrix.MetaClass());
            for ii=1:matrixes.size()
                elemType=matrixes.at(ii).BaseType;
                while isa(elemType,'Simulink.metamodel.types.Matrix')
                    elemType=elemType.BaseType;
                end
                if isa(elemType,"Simulink.metamodel.types.Structure")





                    self.setTypeAsUnsupported(matrixes.at(ii));
                end
            end
        end

        function setTypeAsUnsupported(self,m3iType)
            self.UnsupportedADTs.set(m3iType.Name);
        end
    end
end


