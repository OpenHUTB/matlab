classdef PopupInformer<handle





    properties(SetObservable=true)
blockH
sfObjH
isSF
posX
posY
objectType
dgmObj
badgeHandler
hDialogHandle
isMissing
needReportLink
    end

    methods

        function this=PopupInformer(badgeHandler,diagramObject,posX,posY,missing,needReport)
            this.badgeHandler=badgeHandler;
            this.isMissing=missing;
            this.needReportLink=needReport;
            this.objectType=diagramObject.type;
            this.dgmObj=diagramObject;
            if strcmp(diagramObject.resolutionDomain,'stateflow')
                this.isSF=true;
                this.sfObjH=double(Stateflow.resolver.asId(diagramObject));
            else
                this.isSF=false;
                handle=Simulink.resolver.asHandle(diagramObject);
                this.blockH=handle;
            end
            this.posX=posX;
            this.posY=posY;
        end

        function show(this)

            this.hDialogHandle=DAStudio.Dialog(this);


            width=this.hDialogHandle.position(3);
            height=this.hDialogHandle.position(4);

            switch(this.objectType)
            case 'Block'
                [posx,posy]=getPosition(this.blockH);
                this.hDialogHandle.position=[posx,posy,width,height];
            case{'Graph','Chart'}
                pos=find_current_canvas_lowerleft_global+[20,-50];
                this.hDialogHandle.position=[pos,width,height];
            otherwise
                [posx,posy]=getScreenPosition([this.posX+10,this.posY+5]);
                this.hDialogHandle.position=[posx,posy,width,height];
            end
            this.hDialogHandle.show();

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
            dlgTag='cvi.PopupInformer';

            numOfRows=2;
            if~this.isMissing||~this.needReportLink
                numOfRows=1;
            end

            linksPanel.Type='panel';
            linksPanel.LayoutGrid=[numOfRows,2];
            linksPanel.Items={};
            rows=1;
            if this.needReportLink
                reportIcon.Type='image';
                reportIcon.RowSpan=[rows,rows];
                reportIcon.ColSpan=[1,1];
                reportIcon.Tag=[dlgTag,'_reportIcon'];
                reportIcon.FilePath=fullfile(matlabroot,'toolbox','slcoverage','+cvi','@BadgeHandler','icons','report.png');
                reportHyperlink.Type='hyperlink';
                reportHyperlink.RowSpan=[rows,rows];
                reportHyperlink.ColSpan=[2,2];
                reportHyperlink.Tag=[dlgTag,'_reportHyperlink'];
                reportHyperlink.Name=getString(message('Slvnv:simcoverage:cvmodelview:IconAction'));
                reportHyperlink.ToolTip=getString(message('Slvnv:simcoverage:cvmodelview:IconActionToolTip'));
                reportHyperlink.MatlabMethod='clickAction';
                reportHyperlink.MatlabArgs={this,this.badgeHandler,this.dgmObj,'report'};
                linksPanel.Items={reportIcon,reportHyperlink};
                rows=rows+1;
            end
            if this.isMissing

                justifyIcon.Type='image';
                justifyIcon.RowSpan=[rows,rows];
                justifyIcon.ColSpan=[1,1];
                justifyIcon.Tag=[dlgTag,'_justifyIcon'];
                justifyIcon.FilePath=fullfile(matlabroot,'toolbox','slcoverage','gifs','filter_add.png');

                justifyHyperlink.Type='hyperlink';
                justifyHyperlink.RowSpan=[rows,rows];
                justifyHyperlink.ColSpan=[2,2];
                justifyHyperlink.Tag=[dlgTag,'_justifyHyperlink'];
                justifyHyperlink.Name='Justify';
                justifyHyperlink.ToolTip="Add to coverage filter";
                justifyHyperlink.MatlabMethod='clickAction';
                justifyHyperlink.MatlabArgs={this,this.badgeHandler,this.dgmObj,'justify'};
                linksPanel.Items=[linksPanel.Items,{justifyIcon,justifyHyperlink}];
                rows=rows+1;
            end
            dlgstruct.DialogTag=dlgTag;
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.IsScrollable=false;
            dlgstruct.Transient=true;
            dlgstruct.DialogStyle='frameless';
            dlgstruct.DialogTitle='';
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.MinimalApply=true;
            dlgstruct.Items={linksPanel};
        end

        function clickAction(this,badgeHandler,diagramObject,action)
            badgeHandler.popupInformerLinkCallback(diagramObject,action)
            this.hDialogHandle.hide();
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