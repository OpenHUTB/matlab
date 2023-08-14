classdef CodeDescriptorTypeVisitor<handle




    methods(Access=public)
        function self=CodeDescriptorTypeVisitor()
        end

        function accept(this,embeddedObj)
            if isempty(embeddedObj)
                return
            end


            if embeddedObj.isEnum
                this.visitEnumType(embeddedObj);
            elseif embeddedObj.isNumeric
                this.visitNumericType(embeddedObj);
            elseif embeddedObj.isMatrix
                this.visitMatrixType(embeddedObj);
            elseif embeddedObj.isStructure
                this.visitStructType(embeddedObj);
            elseif embeddedObj.isComplex
                this.visitComplexType(embeddedObj);
            elseif embeddedObj.isOpaque
                this.visitOpaqueType(embeddedObj);
            elseif embeddedObj.isPointer
                this.visitPointerType(embeddedObj);
            elseif embeddedObj.isVoid
                this.visitVoidType(embeddedObj);
            elseif embeddedObj.isChar
                this.visitCharType(embeddedObj);
            else
                assert(false,DAStudio.message('RTW:autosar:unrecognizedExportedDataType',class(embeddedObj)));
            end
        end


    end

    methods(Access=private)
        function ret=visitEnumType(self,type)
            ret=self.acceptEnumType(type);
        end

        function ret=visitCharType(self,type)
            ret=self.acceptCharType(type);
        end

        function ret=visitNumericType(self,type)
            ret=self.acceptNumericType(type);
        end

        function ret=visitMatrixType(self,type)
            ret=self.acceptMatrixType(type,type.BaseType);
        end

        function ret=visitStructType(self,type)

            self.acceptStructType(type,false);


            element=type.Elements;

            for ii=1:numel(element)
                self.acceptStructElement(element(ii),ii);
            end


            ret=self.acceptStructType(type,true);
        end

        function ret=visitComplexType(self,type)
            ret=self.acceptComplexType(type);
        end

        function ret=visitOpaqueType(self,type)
            ret=self.acceptOpaqueType(type);
        end

        function ret=visitPointerType(self,type)
            ret=self.acceptPointerType(type,type.BaseType);
        end

        function ret=visitVoidType(self,type)
            ret=self.acceptVoidType(type);
        end

    end

    methods(Abstract,Access=protected)
        ret=acceptEnumType(self,type)
        ret=acceptCharType(self,type)
        ret=acceptStructType(self,type,finish)
        ret=acceptStructElement(self,field,index)
        ret=acceptMatrixType(self,type,elemType)
        ret=acceptNumericType(self,type)
        ret=acceptComplexType(self,type)
        ret=acceptOpaqueType(self,type)
        ret=acceptPointerType(self,type,elemType)
        ret=acceptVoidType(self,type)
    end

end



