classdef ConstantVisitor<m3i.Visitor





    properties(Hidden=true,GetAccess=public,SetAccess=private)
m3iModel
    end

    methods(Access='public')



        function self=ConstantVisitor(model)
            self=self@m3i.Visitor();
            if isa(model,'autosar.mm.Model')
                self.m3iModel=model.getModel();
            elseif isa(model,'Simulink.metamodel.foundation.Domain')
                self.m3iModel=model;
            else
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgModel',1));
            end

            tmp=Simulink.metamodel.types.Factory();
            delete(tmp);
        end



        function model=getModel(self)
            model=self.m3iModel;
        end



        function ret=visitM3IObject(self,~)%#ok
            assert(false,DAStudio.message('RTW:autosar:mmInvalidType'));
        end



        function ret=visitSimulinkmetamodeltypesConstantSpecification(self,m3iConst)
            ret=self.apply(m3iConst.ConstantValue);
        end



        function ret=visitSimulinkmetamodeltypesEnumerationLiteralReference(self,m3iConst)
            ret=self.acceptEnumerationLiteralReference(m3iConst);
        end



        function ret=visitSimulinkmetamodeltypesLiteralReal(self,m3iConst)


            mc=m3iConst.Type.getMetaClass();
            switch mc
            case Simulink.metamodel.types.Boolean.MetaClass()
                ret=self.acceptBoolean(m3iConst);
            case Simulink.metamodel.types.Integer.MetaClass()
                ret=self.acceptInteger(m3iConst);
            case Simulink.metamodel.types.FloatingPoint.MetaClass()
                ret=self.acceptFloatingPoint(m3iConst);
            case Simulink.metamodel.types.FixedPoint.MetaClass()
                ret=self.acceptFixedPoint(m3iConst);
            case Simulink.metamodel.types.Enumeration.MetaClass()
                ret=self.acceptEnumerationLiteralReference(m3iConst);
            case Simulink.metamodel.types.LookupTableType.MetaClass()
                ret=self.acceptLookupTableSpecification(m3iConst);
            case Simulink.metamodel.types.SharedAxisType.MetaClass()
                if m3iConst.Type.SharedFrom.isEmpty()||m3iConst.Type.SharedFrom.size()==0
                    ret=self.acceptApplicationValueSpecification(m3iConst);
                else
                    ret=self.acceptLookupTableSpecification(m3iConst);
                end
            case Simulink.metamodel.types.VoidPointer.MetaClass()
                ret=self.acceptVoidPointer(m3iConst);
            case Simulink.metamodel.types.String.MetaClass()
                ret=self.acceptChar(m3iConst);
            otherwise
                DAStudio.error('autosarstandard:importer:unsupportedTypeForLiteral',...
                mc.qualifiedName,autosar.api.Utils.getQualifiedName(m3iConst));
            end
        end



        function ret=visitSimulinkmetamodeltypesMatrixValueSpecification(self,m3iConst)

            self.acceptMatrix(m3iConst,false);


            attrs=m3iConst.ownedCell;
            for ii=1:size(attrs)
                if~attrs.at(ii).Value.Type.isvalid()

                    if isa(m3iConst.Type,'Simulink.metamodel.types.Matrix')
                        attrs.at(ii).Value.Type=m3iConst.Type.BaseType;
                    elseif isa(m3iConst.Type,'Simulink.metamodel.types.LookupTableType')
                        attrs.at(ii).Value.Type=m3iConst.Type.BaseType;
                    elseif isa(m3iConst.Type,'Simulink.metamodel.types.SharedAxisType')
                        attrs.at(ii).Value.Type=m3iConst.Type.Axis.BaseType;
                    else
                        metaClass=m3iConst.Type.getMetaClass();
                        assert(false,'Unexpected type %s for Matrix Values of Constant Parameter',...
                        metaClass.qualifiedName);
                    end
                end
                self.acceptMatrixElement(attrs.at(ii).Value,ii);
            end


            ret=self.acceptMatrix(m3iConst,true);

        end



        function ret=visitSimulinkmetamodeltypesStructureValueSpecification(self,m3iConst)

            self.acceptStructure(m3iConst,false);


            attrs=m3iConst.OwnedSlot;
            for ii=1:size(attrs)

                attrs.at(ii).Value.Type=m3iConst.Type.Elements.at(ii).ReferencedType;
                self.acceptStructureField(attrs.at(ii).Value,ii);
            end


            ret=self.acceptStructure(m3iConst,true);
        end



        function ret=visitSimulinkmetamodeltypesConstantReference(self,m3iConst)
            ret=[];
            if m3iConst.Value.isvalid()
                ret=self.apply(m3iConst.Value);
            end
        end




        function ret=visitSimulinkmetamodeltypesLookupTableSpecification(self,m3iConst)
            ret=self.acceptLookupTableSpecification(m3iConst);
        end



        function ret=visitSimulinkmetamodeltypesApplicationValueSpecification(self,m3iConst)
            ret=self.acceptApplicationValueSpecification(m3iConst);
        end
    end

    methods(Abstract,Access='protected')
        ret=acceptLookupTableSpecification(self,m3iConst)
        ret=acceptApplicationValueSpecification(self,m3iConst)
        ret=acceptEnumerationLiteralReference(self,m3iConst)
        ret=acceptStructure(self,m3iConst,finish)
        ret=acceptStructureField(self,m3iConst,slotIdx)
        ret=acceptMatrix(self,m3iConst,finish)
        ret=acceptMatrixElement(self,m3iConst,cellIdx)
        ret=acceptInteger(self,m3iConst)
        ret=acceptBoolean(self,m3iConst)
        ret=acceptFloatingPoint(self,m3iConst)
        ret=acceptFixedPoint(self,m3iConst)
        ret=acceptVoidPointer(self,m3iConst)
    end

end


