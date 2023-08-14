


classdef GenericSection<hdlhtmlreporter.html.Element
    properties
tagName
disableNewLineOnBeginTag
internalElementsEmitStr
    end
    methods
        function obj=GenericSection(sectionTagName,id,cssStyles)
            obj=obj@hdlhtmlreporter.html.Element(id,cssStyles);
            obj.tagName=sectionTagName;


            obj.disableNewLineOnBeginTag=false;


            obj.buildingTags(sectionTagName)=true;


            obj.internalElementsEmitStr='';
        end
        function addElement(obj,elem)
            obj.internalElementsEmitStr=[obj.internalElementsEmitStr,elem.emitHTML];
            for ii=1:length(elem.localCssStyles)
                localStyle=elem.localCssStyles{ii};
                obj.localCssStyles{end+1}=localStyle;
            end
        end

        function addContentStr(obj,contentStr)
            obj.internalElementsEmitStr=[obj.internalElementsEmitStr,contentStr];
        end

        function setDisableNewLineOnBeginTag(obj,val)
            obj.disableNewLineOnBeginTag=val;
        end
    end
    methods(Access=protected)
        function emitStr=emitPreCSSstyledHTML(obj)

            if isempty(obj.id)
                if obj.disableNewLineOnBeginTag
                    emitStr=sprintf('<%s>',obj.tagName);
                else
                    emitStr=sprintf('<%s>\n',obj.tagName);
                end
            else
                if obj.disableNewLineOnBeginTag
                    emitStr=sprintf('<%s id="%s">',obj.tagName,obj.id);
                else
                    emitStr=sprintf('<%s id="%s">\n',obj.tagName,obj.id);
                end
            end


            emitStr=[emitStr,obj.internalElementsEmitStr];


            emitStr=[emitStr,sprintf('</%s>\n',obj.tagName)];
        end
    end

end