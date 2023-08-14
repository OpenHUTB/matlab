






classdef IconRegistry<handle

    properties
        externalReq;

        externalReqUnlocked;

        importNode;

        importNode_warning;

        justification;

        mwReq;


        folder;

        validLink;

        invalidLink;

        linkSet;

        reqSet;

        unknown;

        warning;

        reqDragIconMoving;

        reqDragIconLinking;

        zcComponent;

        zcPort;

        testMgr;

        slModel;

        reqTable;
        reqTableRow;


        mwReqWithChangeIssue;
        externalReqWithChangeIssue;
    end

    properties(Constant)

        instance=slreq.gui.IconRegistry();
    end

    methods

        function this=IconRegistry()
            mw=matlabroot;
            this.externalReq=fullfile(mw,'toolbox','shared','reqmgt','icons','externalReq.png');
            this.externalReqUnlocked=fullfile(mw,'toolbox','shared','reqmgt','icons','externalReqUL.png');
            this.importNode=fullfile(mw,'toolbox','shared','reqmgt','icons','importNode.png');
            this.importNode_warning=fullfile(mw,'toolbox','shared','reqmgt','icons','importNode_warning.png');

            this.justification=fullfile(mw,'toolbox','shared','reqmgt','icons','justification.png');
            this.mwReq=fullfile(mw,'toolbox','shared','reqmgt','icons','mwReq.png');
            this.folder=fullfile(mw,'toolbox','matlab','icons','foldericon.gif');
            this.validLink=fullfile(mw,'toolbox','shared','reqmgt','icons','link.png');
            this.invalidLink=fullfile(mw,'toolbox','shared','reqmgt','icons','icon_link_warning.png');
            this.linkSet=fullfile(mw,'toolbox','shared','reqmgt','icons','linkset.png');
            this.reqSet=fullfile(mw,'toolbox','shared','reqmgt','icons','reqset.png');
            this.unknown=fullfile(mw,'toolbox','shared','reqmgt','icons','unknown.png');
            this.warning=fullfile(mw,'toolbox','shared','dastudio','resources','warning_16.png');
            if ispc||ismac
                this.reqDragIconMoving=fullfile(mw,'toolbox','shared','reqmgt','icons','mwReqDrag.png');
            else
                this.reqDragIconMoving=fullfile(mw,'toolbox','shared','reqmgt','icons','mwReqDragNonPC.png');
            end

            this.reqDragIconLinking=fullfile(mw,'toolbox','shared','dastudio','resources','FormatPainterNoCursor.png');
            this.zcComponent=fullfile(mw,'toolbox','shared','reqmgt','icons','zcComponent.png');
            this.zcPort=fullfile(mw,'toolbox','shared','reqmgt','icons','zcPort.png');

            this.testMgr=fullfile(matlabroot,'toolbox','shared','reqmgt','icons','testmanager.png');
            this.slModel=fullfile(matlabroot,'toolbox','shared','dastudio','resources','glue','Toolbars','16px','SimulinkModel_16.png');
            this.reqTable=fullfile(mw,'toolbox','shared','reqmgt','icons','reqblkicon_16.png');
            this.reqTableRow=fullfile(matlabroot,'toolbox','shared','dastudio','resources','tableSelectRow.png');
            this.mwReqWithChangeIssue=fullfile(mw,'toolbox','shared','reqmgt','icons','mwReqWithChangeIssue.png');
            this.externalReqWithChangeIssue=fullfile(mw,'toolbox','shared','reqmgt','icons','externalReqWithChangeIssue.png');

        end

    end

end
