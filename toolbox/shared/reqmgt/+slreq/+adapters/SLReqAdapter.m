classdef SLReqAdapter<slreq.adapters.BaseAdapter



    properties(Access=private)
        isEmbeddedReq;
    end
    methods
        function this=SLReqAdapter()
            this.domain='linktype_rmi_slreq';
            this.isEmbeddedReq=false;
        end

        function setIsEmbeddedReq(this,isEmbedded)
            this.isEmbeddedReq=isEmbedded;
        end

        function artifactUri=getArtifactUriFromReq(~,dataReq)

            artifactUri=dataReq.getReqSetArtifactUri();
        end

        function[icon,summary,tooltip]=getIconSummaryTooltipFromReq(this,dataReq,artifactUri,artifactId)


            icon=this.getIconFromDataReq(dataReq);
            summary=this.getSummaryFromDataReq(dataReq,artifactUri,artifactId);
            tooltip=this.getTooltipFromDataReq(dataReq,artifactUri,artifactId);
        end

        function artifactId=getArtifactIdFromReq(~,dataReq)

            artifactId=num2str(dataReq.sid);
        end

        function str=getGlobalUniqueId(~,artifact,id)
            if nargin<3||isempty(id)
                str=artifact;
                return;
            end



            if strcmp(id(1),'#')
                id=id(2:end);
            end
            str=sprintf('%s:#%s',artifact,id);
        end

        function icon=getIcon(this,artifact,id)
            dataReq=this.getDataReq(artifact,id);
            icon=this.getIconFromDataReq(dataReq);
        end

        function tf=isResolved(this,artifact,id)%#ok<INUSL>
            [artifactUri,reqId]=slreq.internal.LinkUtil.getReqSetUri(artifact,id);
            dataReqSet=slreq.data.ReqData.getInstance.getReqSet(artifactUri);
            if~isempty(dataReqSet)&&~isempty(dataReqSet.getRequirementById(reqId))
                tf=true;
            else
                tf=false;
            end
        end

        function success=select(this,artifact,id,caller)
            if nargin<4||isempty(caller)
                caller='standalone';
            end
            success=false;
            mgr=slreq.app.MainManager.getInstance();
            dataReq=this.getDataReq(artifact,id);
            if isempty(dataReq)
                if~isempty(id)

                    displayNavigationErrorPopup(getString(message('Slvnv:slreq:UnableToLocateRequirement',id,artifact)));
                else

                    displayNavigationErrorPopup(getString(message('Slvnv:slreq:UnableToLocateReqSet',artifact)));
                end
                return;
            else
                if strcmp(caller,'standalone')&&isempty(mgr.requirementsEditor)
                    mgr.openRequirementsEditor;
                end

                dasReq=dataReq.getDasObject();
                if isempty(dasReq)
                    if isempty(id)
                        dasReqSet=dataReq.getDasObject();
                    else
                        dasReqSet=dataReq.getReqSet().getDasObject();
                    end
                    if~isempty(dasReqSet)

                        dasReqSet.createChildren();
                    end

                    dasReq=dataReq.getDasObject();
                    if isempty(dasReq)

                        displayNavigationErrorPopup(getString(message('Slvnv:slreq:UnableToLocateRequirement',id,artifact)));
                        return;
                    end
                end
            end



            if strcmp(caller,'standalone')

                if slreq.editor()
                    mgr.requirementsEditor.setSelectedObject(dasReq);
                    mgr.requirementsEditor.show();
                    success=true;
                end
            else
                try


                    spObj=mgr.getCurrentSpreadSheetObject(caller);
                    if~isempty(spObj)


                        studio=spObj.mComponent.getStudio;
                        if~strcmp(studio.getComponentLocation(spObj.mComponent),'Invisible')&&spObj.mComponent.isVisible


                            spObj.setHighlightedObject(dasReq,true);
                            success=true;
                            return;
                        end
                    end


                    if slreq.editor()
                        mgr.requirementsEditor.setSelectedObject(dasReq);
                        mgr.requirementsEditor.show();
                        success=true;
                    end
                catch mx
                    displayNavigationErrorPopup(mx.message);
                end
            end
        end

        function success=highlight(this,artifact,id,caller)

            if nargin<4||isempty(caller)
                caller='standalone';
            end
            success=false;

            dateReq=this.getDataReq(artifact,id);
            if isempty(dateReq)

                return;
            end
            reqSet=dateReq.getReqSet();
            reqSetName=reqSet.name;
            mgr=slreq.app.MainManager.getInstance;

            caller=overwriteCallerIfNeeded(caller,dateReq);



            dasReq=dateReq.getDasObject();
            if isempty(dasReq)
                dasReqSet=reqSet.getDasObject();
                if~isempty(dasReqSet)

                    dasReqSet.createChildren();
                else

                    mgr.openRequirementsEditor();
                    dasReqSet=reqSet.getDasObject();
                    dasReqSet.createChildren();
                end

                dasReq=dateReq.getDasObject();
                if isempty(dasReq)

                    displayNavigationErrorPopup(getString(message('Slvnv:slreq:UnableToLocateRequirement',id,reqSetName)));
                    return;
                end
            end


            if strcmp(caller,'standalone')

                if slreq.editor()
                    mgr.requirementsEditor.setSelectedObject(dasReq);
                    mgr.requirementsEditor.show();
                    success=true;
                end
            else
                try
                    modelH=get_param(caller,'Handle');
                    spObj=mgr.getCurrentSpreadSheetObject(modelH);
                    if~isempty(spObj)


                        studio=spObj.mComponent.getStudio;
                        if~strcmp(studio.getComponentLocation(spObj.mComponent),'Invisible')&&spObj.mComponent.isVisible


                            spObj.setHighlightedObject(dasReq,true);
                            success=true;
                            return;
                        end
                    end


                    if slreq.editor()
                        mgr.requirementsEditor.setSelectedObject(dasReq);
                        mgr.requirementsEditor.show();
                        success=true;
                    end
                catch mx
                    displayNavigationErrorPopup(mx.message);
                end
            end
        end

        function str=getSummary(this,artifact,id)


            [artifactUri,rId]=slreq.internal.LinkUtil.getReqSetUri(artifact,id);
            if isSidString(rId)
                dataReq=this.getDataReq(artifactUri,rId);
            else
                dataReq=this.getDataReqByCustomId(artifactUri,rId);
            end
            str=this.getSummaryFromDataReq(dataReq,artifactUri,rId);
        end

        function tooltip=getTooltip(this,artifact,id)
            if slreq.internal.LinkUtil.isEmbededReqId(id)
                tooltip=strtrim(sprintf('%s:%s',artifact,id));
            else
                dataReq=this.getDataReq(artifact,id);
                tooltip=this.getTooltipFromDataReq(dataReq,artifact,id);
            end
        end

        function src=getSourceObject(this,artifact,id)%#ok<INUSL>
            src=[];
            reqSet=slreq.data.ReqData.getInstance.getReqSet(artifact);
            if~isempty(reqSet)
                item=reqSet.getRequirementById(num2str(id));
                if~isempty(item)
                    src=slreq.utils.dataToApiObject(item);
                else
                    rmiut.warnNoBacktrace('Slvnv:slreq:UnableToResolveObject',id)
                end
            end
        end

        function success=onClickHyperlink(this,artifact,id,caller)
            if~exist('caller','var')||isempty(caller)
                caller='standalone';
            end
            this.select(artifact,id,caller);
            success=true;
        end

        function cmdStr=getClickActionCommandString(~,artifact,id,caller)





            cmdStr=sprintf('slreq.adapters.SLReqAdapter.navigate(''%s'',''%s'',''%s'',''highlight'')',...
            artifact,id,caller);
        end

        function navCmd=getExternalNavCmd(~,artifactUri,id)




            shortName=slreq.uri.getShortNameExt(artifactUri);
            navCmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'','''');','linktype_rmi_slreq',shortName,id);
        end

        function url=getURL(this,artifact,id)
            navCmd=this.getExternalNavCmd(artifact,id);
            url=rmiut.cmdToUrl(navCmd,false);
        end

        function fullPath=getFullPathToArtifact(~,artifact,varargin)
            if rmiut.isCompletePath(artifact)
                fullPath=artifact;
            else
                fullPath=rmi.locateFile(artifact,varargin{:});
                if isempty(fullPath)
                    [~,reqSetName]=slreq.uri.getReqSetShortName(artifact);
                    dataReqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetName);
                    if~isempty(dataReqReqSet)
                        fullPath=dataReqSet.filepath;
                    else
                        fullPath=artifact;
                    end
                end
            end
        end

        function linkType=getDefaultLinkType(this,artifactUri,artifactId)
            dataReq=this.getDataReq(artifactUri,artifactId);
            if~isempty(dataReq)&&dataReq.isJustification

                linkType=slreq.custom.LinkType.Implement;
            else
                linkType=slreq.custom.LinkType.Relate;
            end
        end

        function str=getSummaryFromDataReq(this,dataReq,artifact,id)
            if~isempty(dataReq)
                str=this.labelWithoutDuplication(dataReq);
            else
                shortNameExt=slreq.uri.getShortNameExt(artifact);
                str=sprintf('%s:%s',shortNameExt,id);
            end
        end


        function[status,revisionInfo]=getRevisionInfo(~,sourceObj)
            status=slreq.analysis.ChangeStatus.Undecided;
            revisionInfo=slreq.utils.DefaultValues.getRevisionInfo();

            if isa(sourceObj,'slreq.data.Requirement')
                reqObj=sourceObj;
            elseif isa(sourceObj,'slreq.data.SourceItem')
                reqObj=slreq.utils.getReqObjFromSourceItem(sourceObj);
            else
                status=slreq.analysis.ChangeStatus.UnsupportedArtifact;
                return;
            end

            if reqObj.isDirectLink

                status=slreq.analysis.ChangeStatus.UnsupportedArtifact;
                return;
            end

            revisionInfo.uuid=reqObj.getUuid();

            if~reqObj.external||(reqObj.isOSLC&&reqObj.getModifiedPTime()~=0)


                revisionInfo.timestamp=reqObj.getModifiedPTime();
            else
                revisionInfo.timestamp=reqObj.getSynchronizedOnPTime();
            end

            revisionInfo.revision=num2str(max(reqObj.revision,int32(1)));
        end

    end

    methods(Access=protected)

        function label=labelWithoutDuplication(~,dataReq)
            id=dataReq.id;
            summary=dataReq.summary;
            if isempty(summary)


                label=id;
            elseif isempty(id)||id(1)=='#'
                label=summary;
            elseif contains(summary,id)||contains(id,summary)
                label=summary;
            else
                label=sprintf('%s %s',id,summary);
            end
        end

        function dataReq=getDataReq(~,artifact,id)
            [artifactUri,rId]=slreq.internal.LinkUtil.getReqSetUri(artifact,id);
            dataReq=[];
            dataReqSet=slreq.data.ReqData.getInstance.getReqSet(artifactUri);
            if~isempty(dataReqSet)
                if isempty(id)
                    dataReq=dataReqSet;
                else
                    dataReq=dataReqSet.getRequirementById(rId);
                end
            end
        end

        function dataReq=getDataReqByCustomId(~,artifact,id)
            dataReq=[];
            dataReqSet=slreq.data.ReqData.getInstance.getReqSet(artifact);
            if~isempty(dataReqSet)
                if isempty(id)
                    dataReq=dataReqSet;
                else
                    dataReq=dataReqSet.find('customId',id);
                end
            end
        end

        function icon=getIconFromDataReq(~,dataReq)
            if isempty(dataReq)
                icon=slreq.gui.IconRegistry.instance.warning;
            else
                if dataReq.external
                    if dataReq.locked
                        icon=slreq.gui.IconRegistry.instance.externalReq;
                    else
                        icon=slreq.gui.IconRegistry.instance.externalReqUnlocked;
                    end
                elseif dataReq.isJustification
                    icon=slreq.gui.IconRegistry.instance.justification;
                else
                    icon=slreq.gui.IconRegistry.instance.mwReq;
                end
            end
        end

        function str=getTooltipFromDataReq(~,dataReq,artifact,id)
            if~isempty(dataReq)


                str=strtrim(sprintf('%s:%s',dataReq.getReqSetArtifactUri,id));
            else
                str=strtrim(sprintf('%s:%s',artifact,id));
            end
        end
    end

    methods(Static)
        function navigate(artifactOrData,id,caller,actionType)







            if nargin<4
                actionType='select';
            end

            if isa(artifactOrData,'slreq.data.Requirement')
                artifact=artifactOrData.getReqSet.filepath;
                id=num2str(artifactOrData.sid);
            elseif isa(artifactOrData,'slreq.data.RequirementSet')
                artifact=artifactOrData.filepath;
                id='';
            else
                artifact=artifactOrData;
                id=localEnsureSID(id);
            end


            if rmiut.isCompletePath(artifact)
                reqSet=slreq.find('type','ReqSet','Filename',artifact);
            else
                reqSet=slreq.find('type','ReqSet','Name',strtok(artifact,'.'));
            end
            if isempty(reqSet)
                slreq.load(artifact);
            end

            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
            switch actionType
            case 'select'
                adapter.select(artifact,id,caller);
            case 'highlight'
                adapter.highlight(artifact,id,caller);
            end

            function sid=localEnsureSID(sid)



                if ischar(sid)&&~isempty(sid)
                    numericSID=str2num(erase(sid,'#'));%#ok<ST2NM>
                    if isempty(numericSID)
                        dataReqSet=slreq.data.ReqData.getInstance.getReqSet(artifact);
                        if~isempty(dataReqSet)
                            dataReq=dataReqSet.find('customId',sid);
                            if~isempty(dataReq)
                                sid=sprintf('#%d',dataReq.sid);
                            end
                        end
                    end
                end
            end
        end
    end
end

function displayNavigationErrorPopup(popupContent)
    popupTitle=getString(message('Slvnv:rmi:navigate:NavigationError'));
    errordlg(popupContent,popupTitle);
end

function out=overwriteCallerIfNeeded(caller,dataReq)


    out=caller;
    appmgr=slreq.app.MainManager.getInstance();
    if~strcmp(caller,'standalone')
        spObj=appmgr.getCurrentView(caller);
        if~isempty(spObj)&&isa(spObj,'slreq.gui.ReqSpreadSheet')
            if~isempty(dataReq)
                dataReqSet=dataReq.getReqSet;
                if~spObj.isReqOrLinkSetRegistered(dataReqSet)

                    out='standalone';
                end
            end
        end
    end
end

function tf=isSidString(id)
    if isempty(id)
        tf=false;
        return;
    elseif id(1)=='#'
        id(1)=[];
    end
    tf=all(id>=48)&&all(id<=57);
end



