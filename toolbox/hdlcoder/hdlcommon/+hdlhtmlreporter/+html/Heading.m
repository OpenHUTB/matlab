


classdef Heading<hdlhtmlreporter.html.Element
    properties
content
order
    end

    methods
        function obj=Heading(content,order,id,cssStyles)
            obj=obj@hdlhtmlreporter.html.Element(id,cssStyles);

            obj.order=order;
            obj.content=content;


            obj.buildingTags(['h',num2str(order)])=true;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)
            if isempty(obj.id)
                emitStr=sprintf('<h%d>%s</h%d>\n',obj.order,obj.content,obj.order);
            else
                emitStr=sprintf('<h%s id="%s">%s</p>\n',obj.order,obj.id,obj.content,obj.order);
            end
        end
    end
end