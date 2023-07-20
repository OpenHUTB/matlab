

classdef NotesPrinter<simulink.notes.internal.RTCRequestHandler

    properties(Access=private)
        mModel;
        mPending;
        mHtml;
        mSysDoc;
        mContentMap;
        mContentWidget;
        mIsTimedOut;
        mWebWindow;
        mDASDialog;
        mRTCLoaded;
        mCurrentSID;
    end

    properties(Constant)
        NOTES_PRINTER_STUDIO_TAG='NotesPrinter';
        NOTES_PRINTER_TIMEOUT=30;
        NOTES_PRINTER_PAUSE_INTERVAL=0.01;
        NOTES_PRINTER_REPING_DELAY=5;
    end

    methods
        function obj=NotesPrinter()











            app=simulink.SystemDocumentationApplication.getInstance();
            obj=obj@simulink.notes.internal.RTCRequestHandler(...
            simulink.notes.internal.NotesPrinter.NOTES_PRINTER_STUDIO_TAG,...
            app.getRTCRequestFrontController().getDispatcher());
            obj.mModel=[];
            obj.mRTCLoaded=false;
            obj.mPending=containers.Map;

        end
        function f=print(this,sys)





            this.mHtml='';
            if~this.shouldPrint(sys)
                f='';
                return;
            end

            try
                SID=Simulink.ID.getSID(sys);
            catch ex
                if strcmp(ex.identifier,'Simulink:Commands:InvSimulinkObjectName')


                    root=Stateflow.Root;
                    splitsys=split(sys,"/");
                    sfObj=root.find('Name',char(splitsys(length(splitsys))));
                    SID=Simulink.ID.getStateflowSID(sfObj);
                else
                    rethrow(ex);
                end
            end
            sysDocID=simulink.sysdoc.internal.SysDocID.getSysDocIDFromSID(SID);
            app=simulink.SystemDocumentationApplication.getInstance();

            this.mPending(sysDocID.SID)=true;




            if isempty(this.mContentWidget)
                router=this.getRouter(SID);
                this.mContentWidget=router.createContentWidget(this.NOTES_PRINTER_STUDIO_TAG,false);
            end
            connector.ensureServiceOn;

            if isempty(this.mWebWindow)
                url=this.mContentWidget.getRTCLink(this.NOTES_PRINTER_STUDIO_TAG,false,false);
                this.mWebWindow=matlab.internal.webwindow(url);
            end
            router=this.getRouter(SID);
            [~,~,c]=router.getURLAndContent(sysDocID,false);
            simulink.sysdoc.internal.JSClientRTCProxy.sendJSONContentToRTC(this.NOTES_PRINTER_STUDIO_TAG,c);
            this.setDonePingPong(false);


            this.mIsTimedOut=false;
            t=timer('StartDelay',...
            simulink.notes.internal.NotesPrinter.NOTES_PRINTER_TIMEOUT);
            t.TimerFcn=@(~,~)this.notesPrinterTimeout();
            ct=onCleanup(@()delete(t));
            start(t);
            simulink.sysdoc.internal.JSClientRTCProxy.sendPing(this.NOTES_PRINTER_STUDIO_TAG);
            pause(this.NOTES_PRINTER_PAUSE_INTERVAL)
            resentPing=false;
            tic;
            while~this.mIsTimedOut&&(~app.getRTCRequestFrontController().getDonePingPong(this.NOTES_PRINTER_STUDIO_TAG)||~this.mRTCLoaded)




                if toc>this.NOTES_PRINTER_REPING_DELAY&&~resentPing



                    simulink.sysdoc.internal.JSClientRTCProxy.sendPing(this.NOTES_PRINTER_STUDIO_TAG);
                    resentPing=true;
                end
                pause(this.NOTES_PRINTER_PAUSE_INTERVAL)
            end
            stop(t);
            this.mHtml='';
            pause(this.NOTES_PRINTER_PAUSE_INTERVAL);
            try
                simulink.sysdoc.internal.JSClientRTCProxy.onPrintPage(this.NOTES_PRINTER_STUDIO_TAG,...
                SID,bdroot(SID));
            catch
                sfObj=Simulink.ID.getHandle(SID);
                simulink.sysdoc.internal.JSClientRTCProxy.onPrintPage(this.NOTES_PRINTER_STUDIO_TAG,...
                SID,sfObj.Machine.Name);
            end




            this.mIsTimedOut=false;
            start(t);



            while(isempty(this.mHtml)||~strcmp(this.mCurrentSID,SID))&&~this.mIsTimedOut
                pause(this.NOTES_PRINTER_PAUSE_INTERVAL);
            end

            stop(t);
            if this.mIsTimedOut
                warning(message('simulink_ui:sysdoc:resources:PrintTimeOut'));
            end
            f=this.mHtml;
            this.mPending.remove(SID);
        end
        function notes=getNotesHTMLFromHID(this,HID)




            SID=simulink.sysdoc.internal.SysDocID.getSIDFromEditorHID(HID);
            modelName=Simulink.ID.getModel(SID);
            fileName=get_param(modelName,'Notes');
            if isempty(fileName)

                notes='';
                return;
            end
            fullName=Simulink.ID.getFullName(SID);
            if simulink.notes.internal.NotesPrinter.isOpenedAsModelReuse(HID)||...
                simulink.notes.internal.NotesPrinter.isInLibrary(Simulink.ID.getFullName(SID))


                notes='';
                return;
            end
            this.clearSysDocForModel(modelName);
            this.setNotesPrinterParams(modelName);
            [type,url]=this.getNotesTypeAndUrl(fullName);

            if this.shouldPrint(fullName)

                app=simulink.SystemDocumentationApplication.getInstance();
                app.addToPrinterMap(fullName);
                notes=this.print(fullName);
                app.removeFromPrinterMap(fullName);
            elseif type~=simulink.sysdoc.internal.MixedMapRouter.BINDING_TYPE_HTTP


                error(message('simulink_ui:sysdoc:resources:UnsupportedNotesForPrinter'));
            else
                notes=url;
            end
        end

        function type=getNotesType(this,HID)








            SID=simulink.sysdoc.internal.SysDocID.getSIDFromEditorHID(HID);
            modelName=Simulink.ID.getModel(SID);
            fileName=get_param(modelName,'Notes');
            if isempty(fileName)

                type=simulink.sysdoc.internal.MixedMapRouter.BINDING_TYPE_INVALID;
                return;
            elseif simulink.notes.internal.NotesPrinter.isOpenedAsModelReuse(HID)


                type=simulink.sysdoc.internal.MixedMapRouter.BINDING_TYPE_MODELREUSE;
                return;
            end
            this.clearSysDocForModel(modelName);
            this.setNotesPrinterParams(modelName);
            fullName=Simulink.ID.getFullName(SID);
            type=this.getNotesTypeAndUrl(fullName);
            if simulink.notes.internal.NotesPrinter.isInLibrary(fullName)
                type=simulink.sysdoc.internal.MixedMapRouter.BINDING_TYPE_MODELREUSE;
            end
        end


        function rtcContent=onRTCEditorLoaded(this)
            this.mRTCLoaded=true;
            rtcContent=simulink.notes.internal.NotesPrinter.getModelRTCContent();
        end

        function delete(this)
            if~isempty(this.mWebWindow)
                this.mWebWindow.delete();
            end
        end
    end

    methods(Static,Access=private)
        function content=getModelRTCContent()
            app=simulink.SystemDocumentationApplication.getInstance();
            modelName=app.getModelNameFromStudioTag(simulink.notes.internal.NotesPrinter.NOTES_PRINTER_STUDIO_TAG);
            sysdoc=app.getSystemDocumentation(bdroot(modelName));
            SID=Simulink.ID.getSID(modelName);
            sysDocID=simulink.sysdoc.internal.SysDocID.getSysDocIDFromSID(SID);
            [~,~,content]=sysdoc.getRouter.getURLAndContent(sysDocID,false);
        end

        function isInLibrary=isInLibrary(currentSys)
            isInLibrary=false;
            try
                libData=libinfo(currentSys);
                for i=1:length(libData)
                    if(isequal(libData(i).Block,currentSys))
                        isInLibrary=true;
                    end
                end
            catch
            end
        end

        function isOpenedAsModelReuse=isOpenedAsModelReuse(HID)


            isOpenedAsModelReuse=false;
            assert(slreportgen.utils.HierarchyService.isValid(HID));
            paths=GLUE2.HierarchyService.getPaths(HID);
            if numel(paths)>1
                isOpenedAsModelReuse=true;
            end
        end
    end

    methods(Access=private)
        function tf=shouldPrint(this,sys)
            type=this.getNotesTypeAndUrl(sys);
            if type==simulink.sysdoc.internal.MixedMapRouter.BINDING_TYPE_RTC||type==simulink.sysdoc.internal.MixedMapRouter.BINDING_TYPE_INHERIT
                tf=true;
            else
                tf=false;
            end
        end

        function[type,url]=getNotesTypeAndUrl(this,sys)

            try
                SID=Simulink.ID.getSID(sys);
            catch ex
                if strcmp(ex.identifier,'Simulink:Commands:InvSimulinkObjectName')


                    root=Stateflow.Root;
                    splitsys=split(sys,"/");
                    sfObj=root.find('Name',char(splitsys(length(splitsys))));
                    SID=Simulink.ID.getStateflowSID(sfObj);
                else
                    rethrow(ex);
                end
            end
            router=this.getRouter(SID);
            sysDocID=simulink.sysdoc.internal.SysDocID.getSysDocIDFromSID(SID);
            [type,url]=router.getURL(sysDocID,false);
        end

        function writeHtml(this,html,model,sid)%#ok<INUSL>
            this.mHtml=html;
            this.mCurrentSID=sid;
        end

        function tf=isPending(this)
            tf=~this.mPending.isempty;
        end

        function router=getRouter(~,SID)
            app=simulink.SystemDocumentationApplication.getInstance();
            try
                sysdoc=app.getSystemDocumentation(bdroot(SID));
            catch
                sfObj=Simulink.ID.getHandle(SID);
                sysdoc=app.getSystemDocumentation(sfObj.Machine.Name);
            end
            router=sysdoc.getRouter();
        end

        function notesPrinterTimeout(this)
            this.mIsTimedOut=true;
        end

        function clearSysDocForModel(this,modelName)
            assert(bdIsLoaded(modelName))
            if~isempty(this.mModel)&&~isequal(this.mModel,modelName)
                app=simulink.SystemDocumentationApplication.getInstance();
                app.removeSystemDocumentationForModel(modelName);
            end
        end

        function setNotesPrinterParams(this,modelName)
            if isempty(this.mModel)||~isequal(this.mModel,modelName)||isempty(this.mSysDoc)
                app=simulink.SystemDocumentationApplication.getInstance();
                if isempty(this.mModel)

                    this.mModel=modelName;
                    sysdoc=app.getSystemDocumentation(modelName);
                    if isempty(sysdoc)
                        sysdoc=app.createSystemDocumentation(modelName);
                    end
                    this.mSysDoc=sysdoc;
                    this.mSysDoc.setPrintCallback(@(html,model,sid)(this.writeHtml(html,model,sid)));
                else
                    this.mModel=modelName;
                    sysdoc=app.createSystemDocumentation(modelName);
                    this.mSysDoc=sysdoc;
                    this.mSysDoc.setPrintCallback(@(html,model,sid)(this.writeHtml(html,model,sid)));
                end
            end
        end
    end
end
