


function openCloseReqEditorApp(openClose,modelH,studio)
    c=dig.Configuration.get();

    if nargin<3
        studio=[];
    end


    appName='requirementsEditorApp';

    app=c.getApp(appName);

    if isempty(app)
        return;
    end




    das=DAS.Studio.getAllStudios();









    if isempty(studio)
        studioApp=[];
        for i=1:length(das)
            da=das{i};
            sa=da.App;


            if sa.blockDiagramHandle==modelH
                studioApp=sa;
                break;
            end
        end
        if isempty(studioApp)
            return;
        end
    else
        studioApp=studio.App;
    end

    acm=studioApp.getAppContextManager;

    context=acm.getCustomContext(appName);

    if isempty(context)
        context=slreq.toolstrip.ReqEditorAppContext(app);
    end












    appmgr=slreq.app.MainManager.getInstance();


    spObj=appmgr.getSpreadSheetObject(modelH);

    if openClose

        tsObserver=slreq.toolstrip.ToolStripObserver();
        tsObserver.context=context;


        slreq.toolstrip.switchView(spObj.isReqView,context);




        spObj.registerListener('ViewChanged',@tsObserver.onReqSpreadSheetViewChanged);

        spObj.registerListener('SelectionChanged',@tsObserver.onReqSpreadSheetSelectionChanged);

        spObj.registerListener('BrowserToggled',@tsObserver.onSpreadSheetToggled);



        acm.activateApp(context);



        context.isDoorsEnabled=rmiut.isDoorsEnabled();
        context.isExportWebviewEnabled=...
        dig.isProductInstalled('Simulink Report Generator')&&...
        ~isempty(which('slwebview_req'))&&...
        ~rmisl.isComponentHarness(modelH);
    else

        spObj.unregisterListener('ViewChanged');

        spObj.unregisterListener('SelectionChanged');

        spObj.unregisterListener('BrowserToggled');

        acm.deactivateApp(appName);
    end
end


function modelH=target2ModelHandle(modelH)


    if strcmp(get_param(modelH,'IsHarness'),'on')
        modelH=get_param(Simulink.harness.internal.getHarnessOwnerBD(modelH),'Handle');
    end
end