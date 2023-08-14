


classdef Element<handle
    properties
id
groupCssStylesInfo
localCssStyles
buildingTags
    end
    methods
        function obj=Element(id,cssStyles)
            obj.id=id;
            obj.processCssStyles(cssStyles);


            obj.buildingTags=containers.Map;
        end

        function emitCSSstyledHTMLstr=emitHTML(obj)
            emitCSSstyledHTMLstr=obj.emitPreCSSstyledHTML;
            for ii=1:length(obj.groupCssStylesInfo)
                emitCSSstyledHTMLstr=obj.applySingleCSSstyle(emitCSSstyledHTMLstr,obj.groupCssStylesInfo(ii));
            end
        end

        function emitStr=emitCss(obj)
            emitStr='';
            for ii=1:length(obj.localCssStyles)
                localCssStyle=obj.localCssStyles;
                emitStr=[emitStr,localCssStyle.emitCss];
            end
        end

        function setCSSstyles(obj,cssStyles)
            obj.processCssStyles(cssStyles);
        end
    end
    methods(Abstract,Access=protected)
        emitStr=emitPreCSSstyledHTML(obj)
    end

    methods(Access=protected)
        function singleCSSstyledEmitHTMLstr=applySingleCSSstyle(obj,htmlStr,groupCssStylesInfo)
            singleCSSstyledEmitHTMLstr=htmlStr;
            element=groupCssStylesInfo.elementName;
            if obj.buildingTags.isKey(element)
                elemLen=length(element);
                delimitPos=regexp(htmlStr,['(\w?)<',element,'(\w?)']);
                delimitedEmitHTMLStr=obj.delimitEmitHTMLStr(htmlStr,elemLen,delimitPos);
                numDelimitedEmitHTMLSubStr=length(delimitedEmitHTMLStr);
                attachedCSSstyleSubStr=cell(1,numDelimitedEmitHTMLSubStr);
                attachedCSSstyleSubStr{end}=delimitedEmitHTMLStr{end};
                for ii=1:numDelimitedEmitHTMLSubStr-1
                    attachedCSSstyleSubStr{ii}=[delimitedEmitHTMLStr{ii},' class="',groupCssStylesInfo.className,'"'];
                end
                singleCSSstyledEmitHTMLstr='';
                for jj=1:numDelimitedEmitHTMLSubStr
                    singleCSSstyledEmitHTMLstr=[singleCSSstyledEmitHTMLstr,attachedCSSstyleSubStr{jj}];
                end
            end
        end
        function delimitedEmitHTMLStr=delimitEmitHTMLStr(~,htmlStr,elemLen,delimitPos)
            delimitedEmitHTMLStr={};
            for ii=1:length(delimitPos)+1
                if ii==1
                    startPos=1;
                else
                    startPos=delimitPos(ii-1)+elemLen+1;
                end

                if ii==length(delimitPos)+1
                    endPos=length(htmlStr);
                else
                    endPos=delimitPos(ii)+elemLen;
                end

                delimitedEmitHTMLStr{end+1}=htmlStr(startPos:endPos);
            end

        end

        function processCssStyles(obj,cssStyles)
            groupIndex=1;
            for ii=1:length(cssStyles)
                cssStyle=cssStyles{ii};
                switch cssStyle.selector
                case 'class'
                    obj.groupCssStylesInfo(groupIndex).className=cssStyle.className;
                    obj.groupCssStylesInfo(groupIndex).elementName=cssStyle.elementName;
                    groupIndex=groupIndex+1;
                case 'id'


                    if~isempty(obj.id)
                        cssStyle.id=obj.id;
                        obj.localCssStyles{end+1}=cssStyle;
                    end
                end
            end
        end


    end

end