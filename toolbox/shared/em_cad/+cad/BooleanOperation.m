classdef BooleanOperation<cad.Operation

    methods
        function self=BooleanOperation(name,shapes,Id)
            self@cad.Operation(name,name,Id);
            for i=1:numel(shapes)
                addParent(shapes(i),self);
            end
        end

        function boolshape=performOperation(self,shape)

            if isempty(self.Children)
                boolshape=shape;
                return;
            end
            if isempty(shape)
                shape=getShape(self.Parent);
            end

            switch self.Name
            case 'Add'
                for i=1:numel(self.Children)
                    shape=shape+getOperatedShape(self.Children(i));
                end
            case 'Subtract'
                for i=1:numel(self.Children)
                    shape=shape-getOperatedShape(self.Children(i));
                end
            case 'Intersect'
                for i=1:numel(self.Children)
                    shape=self.shapeIntersect(shape,getOperatedShape(self.Children(i)));
                end
            case 'Xor'
                for i=1:numel(self.Children)
                    shape=self.shapeXor(shape,getOperatedShape(self.Children(i)));
                end
            end

            boolshape=shape;
        end

        function sout=shapeXor(self,s1,s2)

            try

                sout=(s1+s2)-shapeIntersect(self,s1,s2);
            catch
                sout=(s1+s2);
            end
        end


        function sout=shapeIntersect(self,s1,s2)

            sout=s1&s2;
            return;

        end


        function obj=copy(self,varargin)
            obj=cad.BooleanOperation(self.Name,[],self.Id);
            for i=1:numel(self.Children)
                shapeobj=copy(self.Children(i),varargin{:});
                addParent(shapeobj,obj);
            end
        end
    end
end

