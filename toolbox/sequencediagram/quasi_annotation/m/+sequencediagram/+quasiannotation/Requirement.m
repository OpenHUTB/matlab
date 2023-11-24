classdef Requirement<sequencediagram.quasiannotation.internal.BaseAnnotation

    properties(SetObservable)

        Label(1,1)string{mustBeNonempty}="Sequence Diagram Requirement";

        Comment(1,1)string

        Position(1,2)double{mustBeReal,mustBeFinite,mustBeNonnegative}=[30,10];
        Size(1,2)double{mustBeReal,mustBeFinite,mustBeNonnegative}=[250,0];
    end

    properties(Hidden,Transient,SetObservable)
        UpdateTrigger=false;
    end

    methods
        function obj=Requirement(varargin)
            obj=obj@sequencediagram.quasiannotation.internal.BaseAnnotation(varargin{:});
        end
    end

    methods
        function link=linkToRequirement(obj,requirement)






            app=sequencediagram.quasiannotation.App.getInstance();
            [rawAnnotation,modelManager,~]=app.findAnnotationFromUuid(obj.UUID);
            found=~isempty(rawAnnotation);
            if~found



                error('SequenceDiagram:QuasiAnnotation:AnnotationMustBeInSequenceDiagram',...
                'Annotation must be in a sequence diagram to link to a requirement');
            end






            modelHandle=modelManager.ModelHandle;
            qaFilePath=app.getQuasiAnnotationFilePath(modelHandle);
            if~exist(qaFilePath,'file')



                error('SequenceDiagram:QuasiAnnotation:QuasiAnnotationFileDoesNotExist',...
                'Save model before linking annotation to a requirement');
            end

            annotationData=struct(...
            'domain','linktype_rmi_sequenceDiagramQuasiAnnotation',...
            'artifact',qaFilePath,...
            'id',char(obj.UUID));

            link=slreq.createLink(annotationData,requirement);

            obj.update();
        end

        function update(obj)












            obj.UpdateTrigger=~obj.UpdateTrigger;
        end
    end

    methods(Hidden)
        function html=generateHTML(obj)
            document=matlab.io.xml.dom.Document('div');
            rootDiv=obj.createRootDiv(document);
            obj.createHeaderDiv(document,rootDiv);
            obj.createLinkedRequiementsDiv(document,rootDiv);
            obj.createCommentDiv(document,rootDiv)

            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.XMLDeclaration=false;

            html=writer.writeToString(rootDiv);
        end
    end

    methods(Static,Hidden)
        function navigateToRequirement(qaMatFile,uuid)
            app=sequencediagram.quasiannotation.App.getInstance();
            [annotation,modelName,sequenceDiagramName]=app.getAnnotationFromMemoryOrMatFile(qaMatFile,uuid);
            if~isempty(annotation)
                ei=sequencediagram.quasiannotation.internal.EditorInterface.getInstance();
                ei.openSequenceDiagram(modelName,sequenceDiagramName);
            end
        end

        function tf=isValidId(qaMatFile,uuid)
            app=sequencediagram.quasiannotation.App.getInstance();
            annotation=app.getAnnotationFromMemoryOrMatFile(qaMatFile,uuid);
            tf=~isempty(annotation);
        end
    end

    methods(Access=private)
        function slReqStructs=findAllLinkedSlRequirements(obj)
            links=obj.getLinksForAnnotation();
            slReqStructs=arrayfun(@(l)l.destination,links);
        end

        function matchingLinks=getLinksForAnnotation(obj)
            allLinks=obj.getAllLinksToAnnotations();

            if~isempty(allLinks)
                linkSources=arrayfun(@(l)l.source,allLinks);
                idx=strcmp({linkSources.id},obj.UUID);
                matchingLinks=allLinks(idx);
            else
                matchingLinks=[];
            end
        end

        function slReqLinks=getAllLinksToAnnotations(~)
            linkSets=slreq.find('Type','LinkSet','Domain','linktype_rmi_sequenceDiagramQuasiAnnotation');

            if~isempty(linkSets)
                slReqLinks=slreq.Link.empty();
                for linkSet=linkSets
                    locLinks=linkSet.getLinks();
                    if~isempty(locLinks)
                        slReqLinks=[slReqLinks,locLinks];%#ok<AGROW> I tried to be good and use arrayfun but this has issues when we don't have any links
                    end
                end
            else
                slReqLinks=[];
            end
        end

        function rootDiv=createRootDiv(obj,document)
            rootDiv=document.getDocumentElement();

            id=obj.getHtmlId();
            rootDiv.setAttribute('id',id);

            styleString=...
            "position:absolute;"+...
            "width:"+obj.Size(1)+"px;"+...
            "min-height:"+obj.Size(2)+"px;"+...
            "max-height: min-content;"+...
            "left:"+obj.Position(1)+"px;"+...
            "top:"+obj.Position(2)+"px;"+...
            "border: 1px solid #000000;";

            rootDiv.setAttribute('style',styleString);
        end

        function createHeaderDiv(obj,document,rootDiv)
            headerDiv=document.createElement('div');

            styleString=...
            "position:relative;"+...
            "width: 100%;"+...
            "border-bottom: 1px solid #000000;"+...
            "background: #D1C8BF;"+...
            "font-weight: bold;"+...
            "color: #000000;";

            headerDiv.setAttribute('style',styleString);

            headerDiv.TextContent=obj.Label;

            rootDiv.appendChild(headerDiv);
        end

        function createLinkedRequiementsDiv(obj,document,rootDiv)
            linkedReqDiv=document.createElement('div');

            styleString=...
            "position:relative;"+...
            "width: 100%;";

            linkedReqDiv.setAttribute('style',styleString);

            obj.createAllRequirementLinkAnchors(document,linkedReqDiv);

            rootDiv.appendChild(linkedReqDiv);
        end

        function createAllRequirementLinkAnchors(obj,document,parent)
            reqStructs=obj.findAllLinkedSlRequirements();

            if~isempty(reqStructs)
                [~,idx]=sort({reqStructs.id});
                reqStructs=reqStructs(idx);

                for reqStruct=reqStructs
                    obj.createRequirementLinkAnchor(document,parent,reqStruct);
                    obj.addLineBreak(document,parent);
                end
            else
                parent.TextContent="No Linked Requirements";
            end
        end

        function createRequirementLinkAnchor(~,document,parent,reqStruct)
            linkText=[reqStruct.id,': ',reqStruct.summary];

            reqLink=document.createElement('a');
            reqLink.TextContent=linkText;

            clickFcn=sequencediagram.quasiannotation.internal.EditorInterface.getRunMatlabFunctionFromJavascriptString(...
            'rmi.navigate',...
            {reqStruct.domain,reqStruct.artifact,reqStruct.sid,''});

            reqLink.setAttribute('href',"#");
            reqLink.setAttribute('onclick',clickFcn);

            parent.appendChild(reqLink);
        end

        function addLineBreak(~,document,parent)
            brNode=document.createElement('br');
            parent.appendChild(brNode);
        end

        function createCommentDiv(obj,document,rootDiv)

            if obj.Comment==""
                return;
            end

            commentDiv=document.createElement('div');

            styleString=...
            "position:relative;"+...
            "width: 100%;"+...
            "border-top: 1px solid #000000;";

            commentDiv.setAttribute('style',styleString);

            commentDiv.TextContent=obj.Comment;

            rootDiv.appendChild(commentDiv);
        end
    end
end


