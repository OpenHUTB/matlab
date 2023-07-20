


classdef Image<hdlhtmlreporter.html.Element
    properties
imageFilePath
    end

    methods
        function obj=Image(imageFilePath,id,cssStyles)
            if nargin<3
                cssStyles=[];
            end
            if nargin<2
                id='';
            end
            if nargin<1
                imageFilePath='';
            end

            obj=obj@hdlhtmlreporter.html.Element(id,cssStyles);
            obj.imageFilePath=imageFilePath;


            obj.buildingTags('img')=true;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)
            if isempty(obj.id)
                emitStr=sprintf('<img src="%s"/>\n',obj.imageFilePath);
            else
                emitStr=sprintf('<img id="%s" src="%s"/>\n',obj.id,obj.imageFilePath);
            end
        end
    end
end