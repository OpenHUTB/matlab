


classdef Paragraph<hdlhtmlreporter.html.Element
    properties
content
    end

    methods
        function obj=Paragraph(content,id,cssStyles)
            obj=obj@hdlhtmlreporter.html.Element(id,cssStyles);
            obj.content=content;


            obj.buildingTags('p')=true;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)
            if isempty(obj.id)
                emitStr=sprintf('<p>%s</p>\n',obj.content);
            else
                emitStr=sprintf('<p id="%s">%s</p>\n',obj.id,obj.content);
            end
        end
    end
end