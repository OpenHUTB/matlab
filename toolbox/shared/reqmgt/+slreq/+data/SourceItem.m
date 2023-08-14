classdef SourceItem<slreq.data.DataModelObj




    properties(Dependent,GetAccess=public,SetAccess=private)
artifactUri
id
domain
    end

    methods(Access={?slreq.data.ReqData,?slreq.data.TextRange})



        function this=SourceItem(modelObject)
            this.modelObject=modelObject;
        end
    end

    methods(Static)
        function id=getLinkableId(src)
            if isfield(src,'sid')&&isfield(src,'domain')&&strcmp(src.domain,'linktype_rmi_slreq')

                uid=num2str(src.sid);
            else
                uid=src.id;
            end
            if isfield(src,'embeddedReq')&&src.embeddedReq

                [~,reqsetName,~]=fileparts(src.reqSet);


                id=[reqsetName,'.slreqx~',uid];
            else
                id=uid;
            end
        end
    end
    methods


        function out=get.id(this)
            longId=this.modelObject.id;


            if this.isEmbeddedReq()
                out=longId;
            else
                out=slreq.utils.getShortIdFromLongId(longId);
            end
        end

        function path=get.artifactUri(this)
            path=this.modelObject.artifact.artifactUri;
        end

        function path=get.domain(this)
            path=this.modelObject.artifact.domain;
        end

        function result=isTextRange(this)
            result=isa(this.modelObject,'slreq.datamodel.TextRange');
        end

        function result=getTextNodeId(this)
            if this.isTextRange()
                result=this.modelObject.textItem.id;
            else
                result='';
            end
        end

        function revision=getRevision(this)
            assert(this.isTextRange(),'Revision ID is only available for SourceItem objects that are TextRange instances')
            revision=this.modelObject.revision;
        end

        function[outLinks,inLinks]=getLinks(this,varargin)

            rdInstance=slreq.data.ReqData.getInstance();
            if nargin==1

                outLinks=rdInstance.getOutgoingLinks(this.modelObject);
            else

                allOutLinks=rdInstance.getOutgoingLinks(this.modelObject);
                outLinks=slreq.data.Link.empty();
                typeChar=varargin{1};
                for n=1:length(allOutLinks)
                    eachOutLink=allOutLinks(n);
                    if strcmp(eachOutLink.type,typeChar)
                        outLinks(end+1)=eachOutLink;%#ok<AGROW>
                    end
                end
            end

            if nargout==2
                inLinks=this.getIncomingLinks(varargin{:});
            end
        end

        function inLinks=getIncomingLinks(this,type)



            refOrReq=slreq.utils.resolveDest(this);
            if isempty(refOrReq)
                inLinks=slreq.data.Link.empty();
            elseif nargin==1
                inLinks=refOrReq.getLinks();
            else

                allInLinks=refOrReq.getLinks();
                inLinks=slreq.data.Link.empty();
                for n=1:length(allInLinks)
                    eachInLink=allInLinks(n);
                    if strcmp(eachInLink.type,type)
                        inLinks(end+1)=eachInLink;%#ok<AGROW>
                    end
                end
            end
        end

        function linkCount=numberOfLinks(this)
            linkCount=this.modelObject.outgoingLinks.Size;
        end

        function linkSet=getLinkSet(this)


            linkSet=slreq.data.ReqData.getWrappedObj(this.modelObject.artifact);
        end

        function range=getRange(this)
            if isa(this.modelObject,'slreq.datamodel.TextRange')
                range=[this.modelObject.start,this.modelObject.end];
            else
                range=[];
            end
        end

        function sid=getSID(this)


            sid='';
            if strcmp(this.modelObject.artifact.domain,'linktype_rmi_simulink')
                [~,modelName]=fileparts(this.modelObject.artifact.artifactUri);
                if isa(this,'slreq.data.TextRange')
                    sid=[modelName,this.getTextNodeId()];
                else
                    sid=[modelName,this.id];
                end
                if rmisl.isHarnessIdString(sid)

                    sid=slreq.utils.getObjSidFromHarnessIdString(sid);
                end
            end
        end

        function tf=isValid(this)


            [adptr,sourceUri,sourceId]=this.getAdapter();
            tf=adptr.isResolved(sourceUri,sourceId);
        end



        function oldId=rename(this,newId)
            oldId=this.modelObject.id;
            this.modelObject.id=newId;

            linkSet=slreq.data.ReqData.getWrappedObj(this.modelObject.artifact);
            linkSet.setDirty(true);
        end

        function[adapter,artifactUri,artifactId]=getAdapter(this)
            isEmbeddedReq=this.isEmbeddedReq();

            if isEmbeddedReq
                adapter=slreq.adapters.AdapterManager.getInstance().getAdapterByDomain('linktype_rmi_slreq');
                adapter.setIsEmbeddedReq(true);
            else
                adapter=slreq.adapters.AdapterManager.getInstance().getAdapterByDomain(this.domain);
            end
            artifactUri=adapter.getArtifactUri(this);
            artifactId=adapter.getArtifactId(this);
        end

        function tf=isEmbeddedReq(this)
            longId=this.modelObject.id;
            [~,prefix]=slreq.utils.getShortIdFromLongId(longId);
            tf=false;
            if~isempty(prefix)
                [~,~,fExt]=fileparts(prefix);
                if strcmp(fExt,'.slreqx')
                    tf=true;
                end
            end
        end
    end

end

