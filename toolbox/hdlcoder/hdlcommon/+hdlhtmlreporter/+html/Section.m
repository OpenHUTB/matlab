


classdef Section<hdlhtmlreporter.html.GenericSection
    properties
title
    end

    methods
        function obj=Section(title,id,cssStyles)
            obj=obj@hdlhtmlreporter.html.GenericSection('div',id,cssStyles);
            obj.title=title;


            obj.buildingTags('h3')=true;
        end

        function setHeading(obj,title)
            obj.title=title;
        end

    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)

            if isempty(obj.id)
                emitStr=sprintf('<%s>\n',obj.tagName);
            else
                emitStr=sprintf('<%s id="%s">\n',obj.tagName,obj.id);
            end
            emitStr=[emitStr,sprintf('<h3>%s</h3>\n',obj.title)];


            emitStr=[emitStr,obj.internalElementsEmitStr];


            emitStr=[emitStr,sprintf('</%s>\n',obj.tagName)];
        end
    end

    methods(Static)
        function endtag=addEndTag()
            endtag=hdlhtmlreporter.html.EndTag('div');
        end
    end
end