classdef Node<handle

    properties

Id
        ArtifactId char
        Domain char
        ArtifactUri char

NavigateId


        IconClass char
        IsResolved logical

        Summary char
        Tooltip char




        FirstTracedFrom char



        OutgoingNodeIds cell={}
        IncomingNodeIds cell={}



        StreamDepth double=Inf;


        LayerDepth double=Inf;


        TraceDepth double=Inf;

        StreamType slreq.internal.tracediagram.data.StreamType=slreq.internal.tracediagram.data.StreamType.Unset
    end

    methods(Abstract)
        [inLinks,outLinks]=getLinks(this);
    end

    methods
        function this=Node()
        end

        function out=isStreamDepthSet(this)
            out=~isinf(this.StreamDepth);
        end

        function out=isLayerDepthSet(this)
            out=~isinf(this.LayerDepth);
        end

        function out=isTraceDepthSet(this)
            out=~isinf(this.TraceDepth);
        end

        function out=isAlreadyTraced(this)
            out=~isempty(this.FirstTracedFrom);
        end

        function out=isStreamTypeSet(this)
            out=this.StreamType~=slreq.internal.tracediagram.data.StreamType.Unset;
        end

        function setTraceFrom(this,nodeId)
            this.FirstTracedFrom=nodeId;

        end

        function addIncomingNodeIds(this,nodeId)
            this.IncomingNodeIds{end+1}=nodeId;
        end

        function addOutgoingNodeIds(this,nodeId)
            this.OutgoingNodeIds{end+1}=nodeId;
        end

        function out=getIncomingNodeIds(this)
            out=unique(this.IncomingNodeIds,'stable');
        end

        function out=getOutgoingNodeIds(this)
            out=unique(this.OutgoingNodeIds,'stable');
        end

        function setStreamType(this,streamType)
            this.StreamType=slreq.internal.tracediagram.data.StreamType(streamType);
        end

        function setLayerDepth(this,depth)
            this.LayerDepth=depth;
        end

        function setTraceDepth(this,depth)
            this.TraceDepth=depth;
        end

        function setStreamDepth(this,level)
            this.StreamDepth=level;
        end

        function linkTargetClass=getLinkTargetClass(this)
            domain=this.Domain;
            linkTargetClass=strrep(domain,'_','-');
        end

        function out=exportToStruct(this)
            out.Id=this.Id;
            out.ArtifactId=this.ArtifactId;
            out.Domain=this.Domain;
            out.ArtifactUri=this.ArtifactUri;
            out.IsResolved=this.IsResolved;
            out.Summary=this.Summary;
            out.Tooltip=this.Tooltip;
            out.StreamDepth=this.StreamDepth;
            out.InheriteFrom=this.FirstTracedFrom;
            out.IncomingNodes=this.IncomingNodeIds;
            out.OutgoingNodes=this.OutgoingNodeIds;
            out.StreamType=char(this.StreamType);
            out.IconClass=this.IconClass;
        end
    end

    methods(Static)
        function[nodeKey,artifactUri,artifactId]=getNodeKey(itemInfo)




            if isa(itemInfo,'slreq.data.RequirementSet')
                rmiStruct=slreq.utils.getRmiStruct(itemInfo.filepath);
            elseif isstruct(itemInfo)
                rmiStruct.artifact=itemInfo.artifactUri;
                rmiStruct.id=itemInfo.id;
                rmiStruct.domain=itemInfo.domain;
            else
                rmiStruct=slreq.utils.getRmiStruct(itemInfo);
            end

            fileHandler=slreq.uri.FilePathHelper(rmiStruct.artifact);

            artifact=fileHandler.getFullPath;
            if~isempty(artifact)
                rmiStruct.artifact=artifact;
            end

            adapterManager=slreq.adapters.AdapterManager.getInstance;
            adapter=adapterManager.getAdapterByDomain(rmiStruct.domain);
            if strcmpi(rmiStruct.domain,'linktype_rmi_slreq')&&isfield(rmiStruct,'sid')
                artifactUri=rmiStruct.artifact;
                artifactId=num2str(rmiStruct.sid);
            else
                if strcmpi(rmiStruct.domain,'linktype_rmi_matlab')&&~isempty(rmiStruct.id)&&strcmpi(rmiStruct.id(1),'@')


                    rmiStruct.id=rmiStruct.id(2:end);
                end
                artifactUri=rmiStruct.artifact;
                artifactId=rmiStruct.id;
            end

            nodeKey=adapter.getGlobalUniqueId(artifactUri,artifactId);
        end


    end
end
