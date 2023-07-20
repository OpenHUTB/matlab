







































































































classdef TextRange<handle

    properties(Transient=true,Access=protected)
dataObject
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
Artifact
Id
Domain
Parent
    end

    methods

        function artifact=get.Artifact(this)
            artifact=this.dataObject.artifactUri;
        end

        function id=get.Id(this)
            id=this.dataObject.id;
        end

        function domain=get.Domain(this)
            domain=this.dataObject.domain;
        end

        function parentId=get.Parent(this)
            if strcmp(this.dataObject.domain,'linktype_rmi_simulink')
                sid=this.dataObject.getSID();
                [~,parentId]=strtok(sid,':');
            else
                parentId='';
            end
        end

        function lines=getLineRange(this)
            lines=[this.dataObject.startLine,this.dataObject.endLine];
        end

        function text=getText(this)
            editorId=this.dataObject.getParentId();
            text=rmiml.getText(editorId,this.dataObject.id);
        end

        function links=getLinks(this)
            links=slreq.Link.empty();
            dataLinks=this.getOutgoingLinks();
            for i=1:numel(dataLinks)
                links(end+1)=slreq.utils.dataToApiObject(dataLinks(i));%#ok<AGROW> 
            end
        end

        function count=deleteLinks(this)



            dataLinks=this.getOutgoingLinks();
            count=numel(dataLinks);
            if count>0
                dataLinkSet=slreq.utils.getLinkSet(this.Artifact,this.Domain,false);
                for i=1:numel(dataLinks)
                    dataLinkSet.removeLink(dataLinks(i));
                end
                rmiml.notifyEditor(this.getEditorId,this.Id);
            end
        end

        function remove(this)



            dataLinks=this.getOutgoingLinks();
            if isempty(dataLinks)
                textItem=this.getTextItem();
                textItem.removeTextRange(this.Id);
                delete(this);
            else
                error(message('Slvnv:slreq_objtypes:UnableToRemoveLinksExist',this.Id));
            end
        end

        function setLineRange(this,lines)
            rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
            editorId=this.getEditorId();
            charRange(1)=rangeHelper.lineNumberToCharPosition(editorId,lines(1),1);
            charRange(2)=rangeHelper.lineNumberToCharPosition(editorId,lines(end),-1);
            textItem=this.getTextItem();
            [existingRange,count]=textItem.getRange(charRange);
            if isempty(existingRange)||(count==1&&strcmp(existingRange.id,this.Id))
                this.dataObject.setRange(charRange);
                rmiml.notifyEditor(editorId,this.Id,[lines(1),lines(end)]);
            else
                rangeString=sprintf('%d-%d',lines(1),lines(end));
                error(message('Slvnv:slreq_objtypes:TextRangeExists',rangeString,editorId));
            end
        end

        function show(this)
            rmicodenavigate(this.getEditorId(),this.Id);
        end
    end

    methods(Hidden)



        function textRange=TextRange(dataTextRange)
            textRange.dataObject=dataTextRange;
        end

        function editorId=getEditorId(this)
            textItem=this.getTextItem();
            editorId=textItem.getEditorId();
        end

        function charRange=getCharRange(this)
            lineRange=this.getLineRange();
            rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
            editorId=this.getEditorId();
            charRange(1)=rangeHelper.lineNumberToCharPosition(editorId,lineRange(1),1);
            charRange(2)=rangeHelper.lineNumberToCharPosition(editorId,lineRange(2),-1);
        end

    end

    methods(Access=private)

        function dataLinks=getOutgoingLinks(this)



            src=struct('domain',this.Domain,'artifact',this.Artifact);
            if isempty(this.Parent)
                src.id=this.Id;
            else
                src.id=slreq.utils.getLongIdFromShortId(this.Parent,this.Id);
            end
            dataLinks=slreq.data.ReqData.getInstance.getOutgoingLinks(src);
        end

        function dataLinkSet=getLinkSet(this)
            dataLinkSet=slreq.utils.getLinkSet(this.Artifact,this.Domain);
        end

        function dataTextItem=getTextItem(this)
            dataLinkSet=slreq.utils.getLinkSet(this.Artifact,this.Domain);
            dataTextItem=dataLinkSet.getTextItem(this.Parent);
        end

    end

    methods(Static,Hidden)

        function[artifact,text_id]=resolveTextUnitId(textUnitId)
            artifact='';
            text_id='';

            if exist(textUnitId,'file')
                if rmiut.isCompletePath(textUnitId)
                    artifact=textUnitId;
                else
                    artifact=which(textUnitId);
                end

            elseif rmisl.isSidString(textUnitId)
                [mdlName,text_id]=strtok(textUnitId,':');
                if exist(mdlName,'file')==4&&is_simulink_loaded()
                    try
                        artifact=get_param(mdlName,'Filename');
                    catch
                        rmiut.warnNoBacktrace('Slvnv:slreq:ArtifactNotLoaded',mdlName);
                    end
                end

            elseif any(textUnitId=='/')
                mdlName=strtok(textUnitId,'/');
                if exist(mdlName,'file')==4&&is_simulink_loaded()
                    try
                        artifact=get_param(mdlName,'Filename');
                        sid=Simulink.ID.getSID(textUnitId);
                        [~,text_id]=strtok(sid,':');
                    catch
                        rmiut.warnNoBacktrace('Slvnv:slreq:ArtifactNotLoaded',mdlName);
                    end
                end
            else
                rmiut.warnNoBacktrace('Slvnv:slreq:ArtifactNotLoaded',textUnitId);
            end
        end

        function textRange=getRangeById(varargin)
            textRange=[];
            [artifact,text_id]=slreq.TextRange.resolveTextUnitId(varargin{1:end-1});
            dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
            if~isempty(dataLinkSet)
                if~isempty(text_id)
                    rangeId=slreq.utils.getLongIdFromShortId(text_id,varargin{end});
                else
                    rangeId=varargin{end};
                end
                dataTextRange=dataLinkSet.getTextRangeById(rangeId);
                textRange=slreq.TextRange(dataTextRange);
            end
        end
    end

end
