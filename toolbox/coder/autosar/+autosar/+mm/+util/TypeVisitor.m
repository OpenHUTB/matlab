classdef TypeVisitor<m3i.Visitor





    properties(Hidden=true,GetAccess=public,SetAccess=private)
m3iModel
    end

    methods(Access='public')



        function self=TypeVisitor(model)
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



        function ret=visitSimulinkmetamodeltypesFixedPoint(self,type)
            ret=self.acceptFixedPoint(type);
        end



        function ret=visitSimulinkmetamodeltypesFloatingPoint(self,type)
            ret=self.acceptFloatingPoint(type);
        end



        function ret=visitSimulinkmetamodeltypesInteger(self,type)
            ret=self.acceptInteger(type);
        end



        function ret=visitSimulinkmetamodeltypesBoolean(self,type)
            ret=self.acceptBoolean(type);
        end



        function ret=visitSimulinkmetamodeltypesComplex(~,~)
            ret=[];
            assert(false,'Complex type doesn''t exist in AUTOSAR');
        end



        function ret=visitSimulinkmetamodeltypesMatrix(self,type)
            if type.Reference.isvalid()
                ret=self.acceptMatrix(type,type.Reference.BaseType);
            else
                ret=self.acceptMatrix(type,type.BaseType);
            end
        end



        function ret=visitSimulinkmetamodeltypesLookupTableType(self,type)
            ret=self.acceptLookupTableType(type,type.BaseType);
        end



        function ret=visitSimulinkmetamodeltypesSharedAxisType(self,type)
            ret=self.acceptSharedAxisType(type,type.Axis.BaseType);
        end



        function ret=visitSimulinkmetamodeltypesStructure(self,type)

            self.acceptStructure(type,false);


            if type.Reference.isvalid()
                attrs=type.Reference.Elements;
            else
                attrs=type.Elements;
            end

            for ii=1:size(attrs)
                self.acceptStructureField(type,attrs.at(ii));
            end


            ret=self.acceptStructure(type,true);
        end



        function ret=visitSimulinkmetamodeltypesEnumeration(self,type)

            self.acceptEnumeration(type,false);


            literals=type.OwnedLiteral;
            for ii=1:size(literals)
                self.acceptEnumerationLiteral(type,literals.at(ii),ii-1);
            end


            ret=self.acceptEnumeration(type,true);
        end



        function ret=visitSimulinkmetamodeltypesVoidPointer(self,type)

            ret=self.acceptVoidPointer(type);
        end



        function ret=visitSimulinkmetamodeltypesString(self,type)

            ret=self.acceptString(type);
        end



        function ret=visitM3IObject(self,~)%#ok
            assert(false,DAStudio.message('RTW:autosar:mmInvalidType'));
        end

    end

    methods(Abstract,Access='protected')
        ret=acceptEnumeration(self,type,finish)
        ret=acceptEnumerationLiteral(self,type,literal,value)
        ret=acceptStructure(self,type,finish)
        ret=acceptStructureField(self,type,field)
        ret=acceptMatrix(self,type,elemType)
        ret=acceptLookupTableType(self,type,elemType)
        ret=acceptSharedAxisType(self,type,elemType)
        ret=acceptInteger(self,type)
        ret=acceptBoolean(self,type)
        ret=acceptFloatingPoint(self,type)
        ret=acceptFixedPoint(self,type)
        ret=acceptVoidPointer(self,type)
        ret=acceptString(self,type)
    end

end


