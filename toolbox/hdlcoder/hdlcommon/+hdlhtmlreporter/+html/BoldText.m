


classdef BoldText<hdlhtmlreporter.html.Element
    properties
content
    end

    methods
        function obj=BoldText(content,id,cssStyles)
            obj=obj@hdlhtmlreporter.html.Element(id,cssStyles);
            obj.content=content;

            obj.buildingTags('b')=true;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)
            if isempty(obj.id)
                emitStr=sprintf('<b>%s</b>\n',obj.content);
            else
                emitStr=sprintf('<b id="%s">%s</b>\n',obj.id,obj.content);
            end
        end
    end
end