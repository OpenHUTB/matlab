


classdef Text<hdlhtmlreporter.html.Element
    properties
content
    end

    methods
        function obj=Text(content)
            obj=obj@hdlhtmlreporter.html.Element('',{});

            obj.content=content;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)
            emitStr=sprintf('%s\n',obj.content);
        end
    end
end