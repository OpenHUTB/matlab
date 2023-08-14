classdef EmbeddedWebViewDocument<slreportgen.webview.WebViewDocument




    properties
        ValidateLinksAndAnchors=true;
    end

    properties(Access=private)
        m_anchorIds;
        m_idCount;
    end

    methods
        function h=EmbeddedWebViewDocument(outputFileName,varargin)
            h@slreportgen.webview.WebViewDocument(outputFileName,varargin{:});


            h.TemplatePath=fullfile(slreportgen.webview.TemplatesDir,'embedded_webview.htmtx');

            h.WebViewLibraryPath=fullfile(matlabroot,"toolbox/slreportgen/webview/resources/lib/embedded_webview");


            h.m_anchorIds=containers.Map();


            h.m_idCount=0;
        end


        function fillTOC(h)
            append(h,mlreportgen.dom.TOC());
        end







        function fillContent(h)%#ok
        end

        function linkDomObj=createDiagramLink(h,diagram,label,webviewHoleId)
            if(nargin<4)
                webviewHoleId=getWebViewHoleId(h);
            end

            validateDiagram(h,diagram,webviewHoleId);
            linkDomObj=createObjLink(h,diagram,'diag',label,webviewHoleId);
        end

        function anchorDomObj=createDiagramAnchor(h,diagram,label,webviewHoleId)
            if(nargin<4)
                webviewHoleId=getWebViewHoleId(h);
            end

            validateDiagram(h,diagram,webviewHoleId);
            anchorDomObj=createObjAnchor(h,diagram,'diag',label,webviewHoleId);
        end

        function linkDomObj=createDiagramTwoWayLink(h,diagram,label,webviewHoleId)
            if(nargin<4)
                webviewHoleId=getWebViewHoleId(h);
            end

            validateDiagram(h,diagram,webviewHoleId);
            linkDomObj=createObjLink(h,diagram,'diag',label,webviewHoleId);
            linkDomObj=createObjAnchor(h,diagram,'diag',linkDomObj,webviewHoleId);
        end

        function linkDomObj=createElementLink(h,element,label,webviewHoleId)
            if(nargin<4)
                webviewHoleId=getWebViewHoleId(h);
            end

            validateElement(h,element,webviewHoleId);
            linkDomObj=createObjLink(h,element,'elem',label,webviewHoleId);
        end

        function anchorDomObj=createElementAnchor(h,element,label,webviewHoleId)
            if(nargin<4)
                webviewHoleId=getWebViewHoleId(h);
            end

            validateElement(h,element,webviewHoleId);
            anchorDomObj=createObjAnchor(h,element,'elem',label,webviewHoleId);
        end

        function linkDomObj=createElementTwoWayLink(h,element,label,webviewHoleId)
            if(nargin<4)
                webviewHoleId=getWebViewHoleId(h);
            end

            validateElement(h,element,webviewHoleId);
            linkDomObj=createObjLink(h,element,'elem',label,webviewHoleId);
            linkDomObj=createObjAnchor(h,element,'elem',linkDomObj,webviewHoleId);
        end
    end

    methods(Access=private)
        function anchorDomObj=createObjAnchor(h,obj,objType,label,webviewHoleId)

            if isa(label,'mlreportgen.dom.Element')
                anchorDomObj=label;
            else
                anchorDomObj=mlreportgen.dom.Text(label);
            end


            webviewObjId=h.getWebViewObjectId(obj,webviewHoleId);


            h.addStyleNameToDomObj('slwebview-anchor',anchorDomObj);


            anchorAttributeName=['data-slwebview-',objType,'-anchor'];




            anchorPattern=['^',anchorAttributeName,'(?!-id)'];
            anchorCount=0;
            for attribute=anchorDomObj.CustomAttributes
                if~isempty(regexp(attribute.Name,anchorPattern,'once'))
                    anchorCount=anchorCount+1;
                    if strcmp(attribute.Value,webviewObjId)
                        return;
                    end
                end
            end


            if h.ValidateLinksAndAnchors
                anchorId=[objType,'-',webviewObjId];
                if isKey(h.m_anchorIds,anchorId)
                    obj=slreportgen.webview.SlProxyObject(obj);
                    label=regexprep(getFullName(obj.Handle),'\s',' ');
                    warning(message(...
                    'slreportgen_webview:document:MultipleAnchors',...
                    sprintf('%s (%s)',label,anchorId)));
                else

                    h.m_anchorIds(anchorId)=[];
                end
            end

            if(anchorCount>0)

                anchorAttributeName=sprintf('%s-%d',anchorAttributeName,anchorCount+1);
            end


            anchorDomObj.CustomAttributes=[anchorDomObj.CustomAttributes...
            ,mlreportgen.dom.CustomAttribute(anchorAttributeName,webviewObjId)];
        end

        function linkDomObj=createObjLink(h,obj,objType,label,webviewHoleId)

            if isa(label,'mlreportgen.dom.Element')
                linkDomObj=label;
            else
                linkDomObj=mlreportgen.dom.Text(label);
            end


            webviewObjId=h.getWebViewObjectId(obj,webviewHoleId);


            h.addStyleNameToDomObj('slwebview-link',linkDomObj);


            linkAttributeName=['data-slwebview-',objType,'-link'];




            linkPattern=['^',linkAttributeName,'(?!-id)'];
            linkCount=0;
            for attribute=linkDomObj.CustomAttributes
                if~isempty(regexp(attribute.Name,linkPattern,'once'))
                    linkCount=linkCount+1;
                    attributeValue=attribute.Value;

                    if strcmp(attributeValue,webviewObjId)
                        return;
                    end


                    if h.ValidateLinksAndAnchors
                        addedWebviewHoleId=attributeValue(1:strfind(attributeValue,':')-1);
                        if strcmp(addedWebviewHoleId,webviewHoleId)
                            warning(message(...
                            'slreportgen_webview:document:MultipleLinks',...
                            webviewObjId,...
                            attributeValue));
                        end
                    end
                end
            end

            if(linkCount>0)

                linkAttributeName=sprintf('%s-%d',linkAttributeName,linkCount+1);
            end


            linkDomObj.CustomAttributes=[linkDomObj.CustomAttributes...
            ,mlreportgen.dom.CustomAttribute(linkAttributeName,webviewObjId)];


            linkIdAttributeName=['data-slwebview-',objType,'-link-id'];
            for attribute=linkDomObj.CustomAttributes
                if strcmp(attribute.Name,linkIdAttributeName)
                    return;
                end
            end
            h.m_idCount=h.m_idCount+1;
            uniqueId=sprintf('%s:%d',h.CurrentHoleId,h.m_idCount);
            linkDomObj.CustomAttributes=[linkDomObj.CustomAttributes...
            ,mlreportgen.dom.CustomAttribute(linkIdAttributeName,uniqueId)];
        end

        function validateDiagram(h,diagram,webviewHoleId)
            if h.ValidateLinksAndAnchors&&~isExportDiagram(h,diagram,webviewHoleId)
                if(ischar(diagram)||isstring(diagram))
                    label=diagram;
                else
                    obj=slreportgen.webview.SlProxyObject(diagram);
                    label=getFullName(obj.Handle);
                end
                warning(message(...
                'slreportgen_webview:document:InvalidExportDiagram',...
                label));
            end
        end

        function validateElement(h,element,webviewHoleId)
            if h.ValidateLinksAndAnchors&&~isExportElement(h,element,webviewHoleId)
                if(ischar(element)||isstring(element))
                    label=element;
                else
                    obj=slreportgen.webview.SlProxyObject(element);
                    label=getFullName(obj.Handle);
                end
                warning(message(...
                'slreportgen_webview:document:InvalidExportElement',...
                label));
            end
        end
    end

    methods(Static,Access=private)
        function webviewObjId=getWebViewObjectId(obj,webviewHoleId)

            if(ischar(obj)||isstring(obj))
                objId=regexprep(obj,'\s',' ');
            else
                objH=slreportgen.utils.getSlSfHandle(obj);
                objId=Simulink.ID.getSID(objH);
            end
            objId=char(objId);
            webviewObjId=[webviewHoleId,':',objId];
        end

        function addStyleNameToDomObj(styleName,domObj)
            if isempty(domObj.StyleName)
                domObj.StyleName=styleName;
            elseif~contains(domObj.StyleName,styleName)
                domObj.StyleName=[domObj.StyleName,' ',styleName];
            end
        end
    end
end
