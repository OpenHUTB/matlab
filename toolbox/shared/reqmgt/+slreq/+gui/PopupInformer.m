classdef PopupInformer<handle





    properties(SetObservable=true)
        blockH;













        clickedBlockH;

        sfObjH;


        clickedSFObjId;
        clickedSFObjUddHandle;

        isSF;
        links;
        appmgr;
        posX;
        posY;
        objectType;
        dgmObj;
        isDiagram;


        isFakeSubTransition;
        isObjectUnderCUT;
isInSubsystemReference
    end

    methods

        function this=PopupInformer(diagramObject,posX,posY)
            this.objectType=diagramObject.type;
            this.dgmObj=diagramObject;
            [this.isDiagram,this.isFakeSubTransition]=slreq.utils.isDiagram(this.dgmObj);
            src2Name=[];
            if strcmp(diagramObject.resolutionDomain,'stateflow')
                this.isSF=true;
                this.sfObjH=double(Stateflow.resolver.asId(diagramObject));
                this.clickedSFObjId=this.sfObjH;
                uddObj=sf('IdToHandle',this.sfObjH);
                this.clickedSFObjUddHandle=uddObj;
                this.isObjectUnderCUT=rmisl.isObjectUnderCUT(this.sfObjH);
                this.isInSubsystemReference=rmisl.inSubsystemReference(this.sfObjH);
                if this.isInSubsystemReference


                    src2Name=Simulink.ID.getSID(uddObj);
                end
                if this.isObjectUnderCUT



                    ownerID=Simulink.harness.internal.sidmap.getHarnessObjectSID(uddObj);
                    handle=Simulink.ID.getHandle(ownerID);
                    this.sfObjH=handle.Id;
                end
                src=slreq.utils.getRmiStruct(this.sfObjH);


























            else
                this.isSF=false;
                handle=Simulink.resolver.asHandle(diagramObject);
                this.clickedBlockH=handle;
                this.isObjectUnderCUT=rmisl.isObjectUnderCUT(handle);
                if this.isObjectUnderCUT

                    obj=get(handle,'Object');
                    ownerID=Simulink.harness.internal.sidmap.getHarnessObjectSID(obj);
                    handle=Simulink.ID.getHandle(ownerID);
                end
                src=slreq.utils.getRmiStruct(handle);
                this.blockH=handle;

                blockObj=get_param(this.blockH,'Object');
                this.isInSubsystemReference=rmisl.inSubsystemReference(handle);
                if isa(blockObj,'Simulink.SubSystem')




                    if strcmp(blockObj.LinkStatus,'resolved')
                        src2Name=blockObj.ReferenceBlock;
                    elseif strcmp(blockObj.LinkStatus,'inactive')
                        src2Name=blockObj.AncestorBlock;
                    elseif~isempty(blockObj.ReferencedSubsystem)
                        src2Name=blockObj.ReferencedSubsystem;
                        if~isvarname(src2Name)







                            src2Name=[];
                        end
                    end
                end
                if isempty(src2Name)&&this.isInSubsystemReference

                    src2Name=Simulink.ID.getSID(handle);
                end

            end

            this.links=slreq.data.ReqData.getInstance().getOutgoingLinks(src);
            if~isempty(src2Name)
                src2=slreq.utils.getRmiStruct(src2Name);
                additionalLinks=slreq.data.ReqData.getInstance().getOutgoingLinks(src2);
                this.links=[this.links,additionalLinks];
            end

            this.appmgr=slreq.app.MainManager.getInstance;
            this.posX=posX;
            this.posY=posY;
        end

        function show(this)

            fDialogHandle=DAStudio.Dialog(this);


            width=fDialogHandle.position(3);
            height=fDialogHandle.position(4);

            switch(this.objectType)
            case 'Block'
                [posx,posy]=getPosition(this.clickedBlockH);
                fDialogHandle.position=[posx,posy,width,height];
            case{'Graph','Chart'}
                pos=find_current_canvas_lowerleft_global+[20,-50];
                fDialogHandle.position=[pos,width,height];
            otherwise
                [posx,posy]=getScreenPosition([this.posX+10,this.posY+5]);
                fDialogHandle.position=[posx,posy,width,height];
            end

            fDialogHandle.show();

            function[posx,posy]=getPosition(blockH)
                port_geom=get_param(blockH,'position');
                [posx,posy]=getScreenPosition(port_geom([3,2]));
            end


            function[posx,posy]=getScreenPosition(startPt)

                allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                canvas=allStudios(1).App.getActiveEditor.getCanvas;
                canvas_geom=canvas.GlobalPosition;
                anchor_pos=canvas.scenePointToViewPoint(startPt)/GLUE2.Util.getDpiScale;
                posx=canvas_geom(1)+anchor_pos(1)+10;
                posy=canvas_geom(2)+anchor_pos(2)+5;

            end
        end

        function dlgstruct=getDialogSchema(this,~)

            numLinks=numel(this.links);
            linksPanel=struct('Type','panel','Name','');
            linksPanel.Items={};
            if numLinks~=0


                linksPanel.LayoutGrid=[numLinks,4];
                linksPanel.ColStretch=[0,1,0,0];

                for n=1:numLinks
                    thisLink=this.links(n);

                    [dstIconPath,dstStr,dstTooltip]=thisLink.getDestIconSummaryTooltip();

                    dstIcon=struct('Type','image',...
                    'RowSpan',[n,n],'ColSpan',[1,1],...
                    'Tag',sprintf('PopupInfoDstImage%d',n),'FilePath',dstIconPath);

                    dstHyperlink=struct('Type','hyperlink',...
                    'RowSpan',[n,n],'ColSpan',[2,2],...
                    'Tag',sprintf('PopupInfoDstHyperlink%d',n),'Name',dstStr,'ToolTip',dstTooltip);
                    dstHyperlink.MatlabMethod='onHyperlinkClick';
                    dstHyperlink.MatlabArgs={this,thisLink,'%dialog'};

                    spacer=struct('Type','text','Name','  ','RowSpan',[n,n],'ColSpan',[3,3],'MinimumSize',[10,0]);

                    markupAction=getMarkupOperation(this,thisLink,n);


                    thisDest=thisLink.dest;
                    if isempty(thisDest)||thisDest.isDirectLink

                        markupAction.Visible=false;
                    else
                        markupAction.Visible=true;
                    end

                    linksPanel.Items=[linksPanel.Items,{dstIcon,dstHyperlink,spacer,markupAction}];
                end
            else


                linksPanel.LayoutGrid=[1,1];
                hint.Type='text';
                hint.Name=getString(message('Slvnv:slreq:PopupInformerInvalidLink'));
                linksPanel.Items={hint};
            end

            dlgstruct.DialogTag='SLReqBadgePopup';
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.IsScrollable=false;
            dlgstruct.Transient=true;
            dlgstruct.DialogStyle='frameless';
            dlgstruct.DialogTitle='';
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.MinimalApply=true;
            dlgstruct.Items={linksPanel};
            dlgstruct.ExplicitShow=true;
        end

        function showMarkup(this,dataLink,dlg)


            dasLink=this.appmgr.getDasObjFromDataObj(dataLink);
            if~isempty(dasLink)
                dasLink.showConnector(this.isDiagram);
            end
            dlg.hide;
        end

        function hideMarkup(this,dataLink,dlg)


            if~isempty(dataLink)
                dasLink=this.appmgr.getDasObjFromDataObj(dataLink);


                dasLink.destroyConnector(this.isDiagram);
            end
            dlg.hide;
        end

        function onHyperlinkClick(this,dataLink,dlg)%#ok<INUSL>
            [adapter,artifact,id]=dataLink.getDestAdapter();
            modelName=get_param(bdroot,'Handle');
            adapter.onClickHyperlink(artifact,id,modelName);
            dlg.hide;
        end

        function markupAction=getMarkupOperation(this,linkInfo,linkIndex)











            markupAction=struct('Type','hyperlink',...
            'RowSpan',[linkIndex,linkIndex],'ColSpan',[4,4],...
            'Tag',sprintf('PopupInfoDstHyperlink%d',linkIndex));

            dasLink=this.appmgr.getDasObjFromDataObj(linkInfo);

            [disableMarkup,text,tooltip]=this.getMarkupStatusFromLink(dasLink);

            if disableMarkup
                markupAction.Type='text';
                markupAction.Name=text;
                markupAction.ToolTip=tooltip;
            else
                if this.isDiagram
                    alreadyShown=~isempty(dasLink.DiagramConnector);
                else
                    alreadyShown=~isempty(dasLink.Connector);
                end
                if alreadyShown
                    markupAction.MatlabMethod='hideMarkup';
                    markupAction.MatlabArgs={this,linkInfo,'%dialog'};
                    markupAction.Name=getString(message('Slvnv:slreq:Hide'));
                else
                    markupAction.MatlabMethod='showMarkup';
                    markupAction.MatlabArgs={this,linkInfo,'%dialog'};
                    markupAction.Name=getString(message('Slvnv:slreq:Show'));
                end
            end
        end

        function[disableMarkup,text,tooltip]=getMarkupStatusFromLink(this,dasLink)
            disableMarkup=false;
            text='';
            tooltip='';



















            if this.isFakeSubTransition
                disableMarkup=true;
                text=getString(message('Slvnv:slreq:PopupInformerLimited'));
                tooltip=getString(message('Slvnv:slreq:PopupInformerLimitedTooltipForSubTran'));
                return;
            end


            if this.isObjectUnderCUT
                disableMarkup=true;
                text=getString(message('Slvnv:slreq:PopupInformerLimited'));
                tooltip=getString(message('Slvnv:slreq:PopupInformerLimitedTooltipForCUTComponent'));
                return;
            end

            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            rootDiagram=allStudios(1).App.blockDiagramHandle;
            currentDiagram=allStudios(1).App.getActiveEditor.blockDiagramHandle;

            if strcmpi(get_param(rootDiagram,'IsHarness'),'on')
                ownerDiagram=get_param(get_param(rootDiagram,'OwnerBDName'),'Handle');

            else
                ownerDiagram=rootDiagram;
            end

            if strcmpi(get_param(currentDiagram,'IsHarness'),'on')
                currentOwnerDiagram=get_param(get_param(rootDiagram,'OwnerBDName'),'Handle');
            else
                currentOwnerDiagram=currentDiagram;
            end








            if get_param(ownerDiagram,'ReqPerspectiveActive')~=1
                disableMarkup=true;
                text=getString(message('Slvnv:slreq:PopupInformerLimited'));
                tooltip=getString(message('Slvnv:slreq:PopupInformerLimitedTooltipForNotEnabled'));
                return;
            end







            currentModelName=getfullname(currentOwnerDiagram);
            [~,srcArtifactName,~]=fileparts(dasLink.Source.artifactUri);

            if~strcmp(currentModelName,srcArtifactName)
                disableMarkup=true;
                text=getString(message('Slvnv:slreq:PopupInformerLimited'));
                tooltip=getString(message('Slvnv:slreq:PopupInformerLimitedTooltipForNonOwnerObj'));
                return;
            end

            if this.isInSubsystemReference
                disableMarkup=true;
                text=getString(message('Slvnv:slreq:PopupInformerLimited'));
                tooltip=getString(message('Slvnv:slreq:PopupInformerLimitedTooltipForSSRefInstance'));
                return;
            end


            if~this.isSF

                objHandle=this.clickedBlockH;

                objType=get(objHandle,'Type');
                if strcmpi(objType,'port')||...
                    (strcmpi(objType,'block')&&sysarch.isZCPort(objHandle,get(bdroot(objHandle),'Name')))
                    disableMarkup=true;
                    text=getString(message('Slvnv:slreq:PopupInformerLimited'));
                    tooltip=getString(message('Slvnv:slreq:PopupInformerLimitedTooltipForZCPorts'));
                    return;
                end
            end


            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            editor=allStudios(1).App.getActiveEditor;
            if editor.isLocked
                disableMarkup=true;
                text=getString(message('Slvnv:slreq:Locked'));
                tooltip=getString(message('Slvnv:slreq:PopupInformerLimitedTooltipForLocked'));
                return;
            end

        end
    end
    methods(Static)
        function positionDialog(d)
            pos=d.position;



            mouseLoc=get(0,'PointerLocation');
            screenSize=get(0,'ScreenSize');
            screenHeight=screenSize(4);
            pos(1)=mouseLoc(1)+20;
            pos(2)=screenHeight-mouseLoc(2);

            d.position=pos;
            d.show;


            d.resetSize(true);
        end
    end
end

function pos=find_current_canvas_lowerleft_global
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    canvas=allStudios(1).App.getActiveEditor.getCanvas;
    rect=canvas.GlobalPosition;
    pos=[rect(1),rect(2)+rect(4)];
end
