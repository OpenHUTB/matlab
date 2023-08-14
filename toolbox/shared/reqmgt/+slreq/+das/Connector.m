classdef Connector<handle







    properties
        markupMgr;
        linkUuid='';
        reqUuid='';
        connectorItem;
        isDiagram;
        dataConnector;

        Link;
        ownerHandle;
    end

    properties(Dependent)

        Markup;
        ViewOwnerID;
        isVisible;
    end

    methods
        function this=Connector(markupMgr,dasLink,dasMarkup,reqUuid,cInfo,mfMarkupConnector)

            this.markupMgr=markupMgr;
            this.Link=dasLink;
            this.isDiagram=cInfo.isDiagram;

            dataLink=dasLink.dataModelObj;
            this.linkUuid=dataLink.getUuid;
            this.reqUuid=reqUuid;

            this.dataConnector=dataLink.getConnector(cInfo.isDiagram);
            this.dataConnector.isVisible=true;
            this.ownerHandle=cInfo.OwnerHandle;


            this.markupMgr.setIgnoreNotificationFlag(true);
            cleanup=onCleanup(@()this.markupMgr.setIgnoreNotificationFlag(false));

            if isempty(mfMarkupConnector)
                diagramObj=[];
                if cInfo.isSF
                    [transInfo,viewerInfo]=slreq.utils.getTransitionViewerList(cInfo.SourceID);
                    if~isempty(transInfo)



                        if cInfo.isDiagram
                            diagramObj=diagram.resolver.resolve(viewerInfo.viewerToSubtranID(viewerInfo.topViewerID));
                        else
                            diagramObj=diagram.resolver.resolve(viewerInfo.viewerToSubtranID(viewerInfo.sourceViewerID));
                        end
                    end
                end
                if isempty(diagramObj)
                    if cInfo.isDiagram
                        diagramObj=diagram.resolver.resolve(cInfo.OwnerHandle,'diagram');
                    else
                        diagramObj=diagram.resolver.resolve(cInfo.SourceID,'element');
                        if diagramObj.isNull
                            mdlParts=strsplit(cInfo.SystemPath,'/');
                            mdlName=mdlParts{1};
                            diagramObj=sysarch.getDiagramObjectInComposition(mdlName,cInfo.SourceID);
                        end
                    end
                end

                connector=dasMarkup.markupItem.addConnector(diagramObj);

                if(connector.isValid)



                    this.connectorItem=connector;
                    this.connectorItem.clientItemId=dataLink.getUuid;
                    this.setConnectorLabel();
                else

                end
            else
                this.connectorItem=mfMarkupConnector;

                this.setConnectorLabel();
            end
        end

        function delete(this)
            try
                this.markupMgr.setIgnoreNotificationFlag(true);
                cleanup=onCleanup(@()this.markupMgr.setIgnoreNotificationFlag(false));
            catch ex %#ok<NASGU>
            end

            try
                if~isempty(this.connectorItem)...
                    &&isvalid(this.connectorItem)...
                    &&this.connectorItem.isValid
                    this.connectorItem.remove;
                end
            catch ex %#ok<NASGU>
            end



            try
                markup=this.Markup;
                if isa(markup,'slreq.das.Markup')
                    if isvalid(markup)
                        markup.removeConnector(this);
                        if isempty(markup.Connectors)
                            markup.delete;
                        end
                    end
                end
            catch ex %#ok<NASGU>
            end
        end

        function update(this)
            this.setConnectorLabel();
        end

        function setConnectorLabel(this)
            this.connectorItem.label=upper(this.Link.Type);
        end

        function mkup=get.Markup(this)


            mkup=this.markupMgr.getReqMarkup(this.reqUuid,this.ownerHandle);
        end

        function id=get.ViewOwnerID(this)

            id=this.dataConnector.markup.viewOwnerId;
        end

        function tf=isInSystem(this,ownerH)
            tf=ownerH==this.ownerHandle;
        end

        function set.isVisible(this,tf)
            this.dataConnector.isVisible=tf;
        end

        function tf=get.isVisible(this)
            tf=this.dataConnector.isVisible;
        end
    end
end
