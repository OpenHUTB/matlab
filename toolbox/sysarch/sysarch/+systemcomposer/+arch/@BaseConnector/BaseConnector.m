classdef BaseConnector<systemcomposer.arch.Element&systemcomposer.base.BaseConnector



    properties
Name
    end

    properties(SetAccess=private)
Parent
Ports
    end

    methods(Abstract,Access=protected)
        getPortsImpl(this);
    end

    methods(Static)
        function conn=current()
            conn=systemcomposer.arch.Connector.empty;
            lines=gsl;
            objsMap=containers.Map('KeyType','char','ValueType','any');
            for idx=1:length(lines)
                impl=systemcomposer.utils.getArchitecturePeer(lines(idx));
                if~isempty(impl)
                    for j=1:length(impl)
                        obj=systemcomposer.internal.getWrapperForImpl(impl(j));
                        if~isempty(obj)
                            objsMap(obj.UUID)=obj;
                        end
                    end
                end
            end
            objs=objsMap.values;
            if~isempty(objs)
                conn=cellfun(@(x)x,objs);
            end
        end
    end

    methods(Access=protected)
        function this=BaseConnector(archElemImpl)

            narginchk(1,1);
            if~isa(archElemImpl,'systemcomposer.architecture.model.design.BaseConnector')
                error('systemcomposer:API:ConnectorInvalidInput',message('SystemArchitecture:API:ConnectorInvalidInput').getString);
            end
            this@systemcomposer.arch.Element(archElemImpl);
        end
    end

    methods(Access=protected,Abstract)
        blks=getSLBlocksToDeleteOnConnectorDestroy(this,lineObj);
        skipLineDelete=shouldSkipLineDeleteOnConnectorDestroy(this,lineObj);
    end

    methods
        function name=get.Name(this)
            name=this.ElementImpl.getName;
        end

        function set.Name(this,newName)
            this.ElementImpl.setName(newName);
        end

        function parent=get.Parent(this)
            parent=systemcomposer.internal.getWrapperForImpl(this.ElementImpl.getArchitecture,'systemcomposer.arch.Architecture');
        end

        function ports=get.Ports(this)
            ports=this.getPortsImpl();
        end

        function destroy(this)
            segments=systemcomposer.utils.getSimulinkPeer(this.getImpl);
            blocksToDelete=[];
            segmentIdxToNotDelete=[];
            slLines=get_param(this.Parent.getQualifiedName,'Lines');

            for i=1:numel(segments)
                segmentObj=slLines([slLines.Handle]==segments(i));


                blksToDel=this.getSLBlocksToDeleteOnConnectorDestroy(segmentObj);
                blocksToDelete=[blocksToDelete,blksToDel];%#ok<AGROW> 

                skipSegmentDelete=this.shouldSkipLineDeleteOnConnectorDestroy(segmentObj);
                if skipSegmentDelete
                    segmentIdxToNotDelete=[segmentIdxToNotDelete,i];%#ok<AGROW> 
                end

                conn=systemcomposer.utils.getArchitecturePeer(segments(i));


                if numel(conn)>1&&~ismember(i,segmentIdxToNotDelete)
                    segmentIdxToNotDelete=[segmentIdxToNotDelete,i];%#ok<AGROW> 
                    continue;
                end



                if~isequal(conn,this.getImpl)&&~ismember(i,segmentIdxToNotDelete)
                    segmentIdxToNotDelete=[segmentIdxToNotDelete,i];%#ok<AGROW> 
                    continue;
                end
            end
            segments(segmentIdxToNotDelete)=[];

            bdH=this.SimulinkModelHandle;
            delete_line(segments);
            delete_block(blocksToDelete);
            systemcomposer.internal.arch.internal.processBatchedPluginEvents(bdH);
        end

        applyStereotype(this,stereotype);

    end

    methods(Abstract)
        srcElem=getSourceElement(this);
        dstElem=getDestinationElement(this);
    end


end