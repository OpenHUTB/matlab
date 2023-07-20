classdef ShapeFactory<handle





    methods
        function shapeObj=createShape(self,Group,Type,BBox,Id,varargin)
            switch Type
            case 'Rectangle'
                shapeObj=cad.Polygon(Group,Id,'Rectangle',...
                'Length',BBox.Length,'Width',BBox.Width,'Center',BBox.Center,'Angle',0);
            case 'Circle'
                shapeObj=cad.Polygon(Group,Id,'Circle',...
                'Radius',BBox.Radius,'Center',BBox.Center,'Angle',0);
            case 'Ellipse'
                shapeObj=cad.Polygon(Group,Id,'Ellipse',...
                'MinorAxis',BBox.MinorAxis,'MajorAxis',BBox.MajorAxis,'Center',BBox.Center,'Angle',0);
            case 'Polygon'
                Vertices=varargin{1};
                shapeObj=cad.Polygon(Group,Id,'Polygon','Vertices',Vertices,'Angle',0);
            end
        end
    end
end
