


classdef Link<hdlhtmlreporter.html.Element
    properties
href
content
    end

    methods
        function obj=Link(href,content,id,cssStyles)
            obj=obj@hdlhtmlreporter.html.Element(id,cssStyles);

            obj.href=href;
            obj.content=content;


            obj.buildingTags('a')=true;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)
            if isempty(obj.id)
                emitStr=sprintf('<a href="%s">%s</a>\n',obj.href,obj.content);
            else
                emitStr=sprintf('<a id="%s" href="%s">%s</a>\n',obj.id,obj.href,obj.content);
            end
        end
    end
end