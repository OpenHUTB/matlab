classdef CommentHandler




    properties(Access=private)
ModelDiagramPair
Diagram
    end

    methods
        function obj=CommentHandler(forSystem)



            if nargin==1
                if ishandle(forSystem)

                    sysObj=get_param(forSystem,'Object');
                    forSystem=sysObj.getFullName;
                elseif ischar(forSystem)

                    load_system(forSystem);
                end
                obj.ModelDiagramPair=SLM3I.Util.getDiagram(forSystem);
                obj.Diagram=obj.ModelDiagramPair.diagram;
            else

                ex=MException('CommentHandler:WrongParameterCount','Incorrect number of parameters passed to CommentHandler');
                throw(ex);
            end
        end

        function createComment(obj,block,comment)
            blkPos=get_param(block,'Position');
            note=Simulink.Annotation([get_param(block,'Parent'),'/Default Annotation']);
            note.Text=comment;
            annPos=note.Position;
            note.Position=[blkPos(1)+30,(blkPos(2)+blkPos(4)-annPos(4))/2];
            obj.createConnector(note.Handle,getfullname(block));
        end

        function comment=getComment(obj,block)


            import plccore.common.plcThrowError

            ann=obj.connectorsForObject(block);
            if~isempty(ann)

                annTexts=cellfun(@(x)get_param(x.srcHandle,'Text'),ann,'UniformOutput',false);
                for i=1:numel(annTexts)
                    if contains(annTexts{i},'<!DOCTYPE HTML')


                        matches=regexp(annTexts{i},'(?<=<span[^>]*>)(.*?)(?=<\/span>)','match');
                        if~isempty(matches)
                            annTexts{i}=[sprintf('%s\n',matches{1:end-1}),matches{end}];
                        else
                            plcThrowError('plccoder:plccore:UnsupportedComment',getfullname(block));
                        end
                    end
                end

                comment=[sprintf('%s\n',annTexts{1:end-1}),annTexts{end}];
            else

                comment='';
            end














        end

        function connectors=connectorsForObject(obj,blockOrAnnotation)



            obj.failIfGone;

            hdl=get_param(blockOrAnnotation,'Handle');
            elem=SLM3I.SLDomain.handle2DiagramElement(hdl);
            obj.failIfBadEndpoint(elem,'for object');

            numC=elem.edge.size;
            connectors={};
            for idx=1:numC
                aConn=elem.edge.at(idx);
                if obj.isConnector(aConn)
                    connectors{length(connectors)+1}=obj.makeConnectorRef(aConn);%#ok<AGROW>
                end
            end
        end

        function connector=createConnector(obj,fromAnnotationHandle,toBlock)



            obj.failIfGone;
            obj.failIfLocked;

            fromH=get_param(fromAnnotationHandle,'Handle');
            fromElem=SLM3I.SLDomain.handle2DiagramElement(fromH);
            obj.failIfBadEndpoint(fromElem,'for connector source');

            toH=get_param(toBlock,'Handle');
            toElem=SLM3I.SLDomain.handle2DiagramElement(toH);
            obj.failIfBadEndpoint(toElem,'for connector destination');

            existingConnector=obj.findConnector(fromElem,toElem);
            if obj.isConnector(existingConnector)
                ex=MException('CommentHandler:AlreadyExists','A connector already exists for those two elements');
                throw(ex);
            end

            obj.internalCreateConnector(obj,fromElem,toElem);

            connector=obj.findConnector(fromElem,toElem);
        end
    end

    methods(Static,Access=private)


        function internalCreateConnector(obj,fromElem,toElem)
            model=obj.Diagram.model.getRootDeviant;
            model.beginTransaction;
            factory=SLM3I.Factory.createNewFactory(model);
            connectorElem=factory.createConnector;
            connectorElem.srcElement=fromElem.asDeviant(model);
            connectorElem.dstElement=toElem.asDeviant(model);
            connectorElem.category='model';
            connectorElem.isVisible=true;
            connectorElem.container=obj.Diagram.asDeviant(model);
            model.commitTransaction;
        end

    end

    methods(Access=private)


        function connectorRef=makeConnectorRef(obj,forConnector)%#ok<INUSL>
            connectorRef.type='CommentHandlerRef';
            connectorRef.srcHandle=forConnector.srcElement.handle;
            connectorRef.dstHandle=forConnector.dstElement.handle;
        end

        function connectorElement=findConnector(obj,annotationElem,otherElem)
            numC=annotationElem.edge.size;
            connectorElement=0;
            for idx=1:numC
                aConn=annotationElem.edge.at(idx);
                if obj.isConnector(aConn)&&(aConn.dstElement==otherElem)
                    connectorElement=aConn;
                    break;
                end
            end
        end

        function result=isConnector(obj,diagramElement)%#ok<INUSL>

            result=isa(diagramElement,'SLM3I.Connector');
        end

        function failIfBadEndpoint(obj,diagramElement,desc)


            if~(diagramElement.diagram==obj.Diagram)
                ex=MException('CommentHandler:BadElement','Incorrect element specified %s',desc);
                throw(ex);
            end
        end

        function failIfGone(obj)


            if~(isvalid(obj.Diagram))
                ex=MException('CommentHandler:GoneAway','Model vanished from under CommentHandler');
                throw(ex);
            end
        end

        function failIfLocked(obj)

            if obj.Diagram.locked
                ex=MException('CommentHandler:LockedDiagram','Cannot operate on locked model');
                throw(ex);
            end
        end
    end
end


