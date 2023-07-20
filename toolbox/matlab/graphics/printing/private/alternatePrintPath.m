function pj=alternatePrintPath(pj)














    pj.donePrinting=false;

    if~nargin
        return
    end

    if pj.UseOriginalHGPrinting
        return
    end






    if isempty(pj.Renderer)
        pj.Renderer=get(pj.Handles{1},'Renderer');
    end



    pj.temp.outputUsesPainters=strcmpi(pj.Renderer,'Painters');


    pj.temp.isPostscript=any(strcmpi(pj.DriverClass,{'PS','EP'}));



    if pj.isPrintDriver()

        if isempty(pj.PrinterName)

            pj.PrinterName=findprinters(groot);
        end

        if~queryPrintServices('validate',pj.PrinterName)
            if pj.Verbose


                warning(message('MATLAB:print:invalidPrinter',pj.PrinterName));
                pj.PrinterName='';
            else

                error(message('MATLAB:print:invalidPrinter',pj.PrinterName));
            end
        end
    end

    pj.donePrinting=true;



    drawnow;


    for idx=1:length(pj.Handles)
        if idx>1
            warning(message('MATLAB:print:TooManyHandles'))
            pj.Handles(2:end)=[];
            break
        end
        if isa(pj.Handles{idx},'double')
            pj.Handles{idx}=handle(pj.Handles{idx});
        end
    end



    [printDone,pj]=getframeWithDecorationsShortcut(pj);
    if printDone
        return;
    end


    scSize=hgconvertunits(pj.Handles{1},get(groot,'ScreenSize'),get(groot,'Units'),'pixels',groot);
    pj.temp.ScreenSizeInPixels=scSize(3:4);

    [pj,pt,setupComplete]=printSetup(pj);

    if setupComplete

        cleanupHandler=onCleanup(@()printCleanup(pj,pt));
        try
            pj=printingGenerateOutput(pj);
        catch ex
            ex.throwAsCaller();
        end
    end
end

function[pj,pt,setupComplete]=printSetup(pj)
    try


        pj.temp.layoutWarning=warning('off','MATLAB:graphics:axeslayoutmanager:InconsistentState');


        [pj.temp.lastWarnMsg,pj.temp.lastWarnID]=lastwarn();


        pt=[];


        pj.temp.ObjUnitsModified=[];
        pj.temp.PaintDisabled=false;
        pj=LocalSaveOldProps(pj);
        pj=LocalSaveAxesOldProps(pj);

        set(pj.Handles{1},'InPrint','on')

        pj.temp.CurrentFigure=get(groot,'CurrentFigure');
        pj.temp.DeviceDPI=pj.Handles{1}.ScreenPixelsPerInch;

        if pj.DPI<0
            pj.DPI=150;
        elseif pj.DPI==0
            pj.DPI=pj.temp.DeviceDPI;
        else

        end


        pj.getCopyOptionsPreferences();


        pj.setPaintDisabled(true);


        pj=LocalUpdateRenderer(pj);



        if LocalDoTransparentBackground(pj)
            pj.TransparentBackground=1;
        end



        if pj.doTransform&&isequal(pj.temp.oldProps.Visible,'off')

            set(pj.Handles{1},'Visible_I','on')
        end

        [pj,pt]=printjobContentChanges('set',pj);

        if pj.doTransform
            pj=LocalDealWithResizeFcn(pj);
        end

        pj=printjobUpdateForOutput(pj);


        if pj.temp.dpiAdjustment~=1||pj.DPI~=pj.temp.DeviceDPI||~pj.isPaperPositionModeAuto()


            objUnitsModified=modifyUnitsForPrint('modify',pj.temp.allContents,pj.temp.dpiAdjustment);
        else
            objUnitsModified=[];
        end
        pj.temp.ObjUnitsModified=objUnitsModified;


        LocalWarnIfScalingUI(pj);

        if~pj.isPaperPositionModeAuto()||pj.temp.dpiAdjustment~=1
            LocalUpdatePosition(pj);
        end


        pj.temp.SubplotManager.slm=getappdata(pj.Handles{1},'SubplotListenersManager');
        if~isempty(pj.temp.SubplotManager.slm)
            pj.temp.SubplotManager.slm.disable();
        end


        pj=LocalUpdateViewer(pj);

        LocalValidatePrintJob(pj);

        pj=LocalUpdateContainsTex(pj);


        if isappdata(pj.Handles{1},'Print_UI')&&getappdata(pj.Handles{1},'Print_UI')
            pj.PrintUI=true;
        end
        setupComplete=true;

    catch ex
        setupComplete=false;
        printCleanup(pj,pt);




        if pj.wasFigureClosed()
            warning(message('MATLAB:uistring:alternateprintpath:FigureMayHaveBeenClosed'));
        else
            throw(ex)
        end
    end
end

function pj=doCleanup(pj,pt)

    if ishghandle(pj.Handles{1},'figure')






        modifyUnitsForPrint('revert',pj.temp.ObjUnitsModified);


        [pj,~]=printjobContentChanges('restore',pj,pt);




        if isfield(pj.temp,'viewers')
            for idx=1:length(pj.temp.viewers)
                set(pj.temp.viewers(idx).handle,...
                'OpenGL',pj.temp.viewers(idx).OpenGL,...
                'OpenGLMode',pj.temp.viewers(idx).OpenGLMode,...
                'ScreenPixelsPerInch',pj.temp.viewers(idx).ScreenPixelsPerInch,...
                'ScreenPixelsPerInchMode',pj.temp.viewers(idx).ScreenPixelsPerInchMode);
            end
        end


        LocalRestoreOldProps(pj,pj.Handles{1});
        LocalRestoreAxesOldProps(pj);


        pj.temp.SubplotManager.slm=getappdata(pj.Handles{1},'SubplotListenersManager');
        if~isempty(pj.temp.SubplotManager.slm)
            pj.temp.SubplotManager.slm.enable();
        end


        if isfield(pj.temp,'CurrentFigure')&&...
            (isempty(pj.temp.CurrentFigure)||ishghandle(pj.temp.CurrentFigure,'figure'))
            set(groot,'CurrentFigure',pj.temp.CurrentFigure);
        end
    end

end

function printCleanup(pj,pt)


    exception=[];
    if~pj.wasFigureClosed()
        try
            pj=doCleanup(pj,pt);
        catch e
            exception=e;
        end

        pj.setPaintDisabled(false);
    end

    if isfield(pj.temp,'layoutWarning')
        warning(pj.temp.layoutWarning);
    end



    [~,LASTID]=lastwarn;
    if strcmp(LASTID,'MATLAB:graphics:axeslayoutmanager:InconsistentState')
        lastwarn(pj.temp.lastWarnMsg,pj.temp.lastWarnID);
    end

    pj.resetTemp();


    matlab.graphics.internal.printHelper.requestGCIfNeeded();

    if~isempty(exception)
        rethrow(exception)
    end

end


function pj=LocalSaveOldProps(pj)
    pj.temp.oldHandles=pj.Handles;

    pj.temp.oldProps.HandleVisibility=get(pj.Handles{1},'HandleVisibility');
    pj.temp.oldProps.Units=get(pj.Handles{1},'Units');
    pj.temp.oldProps.Visible=get(pj.Handles{1},'Visible');
    pj.temp.oldProps.VisibleMode=get(pj.Handles{1},'VisibleMode');
    pj.temp.oldProps.WindowStyle=get(pj.Handles{1},'WindowStyle');


    if~strcmp(pj.temp.oldProps.WindowStyle,'docked')

        pj.temp.oldProps.WindowState=get(pj.Handles{1},'WindowState');
    end




    pj.temp.oldProps.Position=get(pj.Handles{1},'Position');


    pj.temp.oldProps.Renderer_I=get(pj.Handles{1},'Renderer_I');
    pj.temp.oldProps.ResizeFcn=get(pj.Handles{1},'ResizeFcn');

    pj.temp.oldProps.InPrint=get(pj.Handles{1},'InPrint');


    pj.temp.oldProps.PaperPosition=get(pj.Handles{1},'PaperPosition');
    pj.temp.oldProps.PaperPositionMode=get(pj.Handles{1},'PaperPositionMode');

end

function LocalRestoreOldProps(pj,fig)

    if isstruct(pj.temp.oldProps)
        restoreProperties=fieldnames(pj.temp.oldProps);



        keyProperties={'ResizeFcn','Units','Position'};
        for i=1:length(keyProperties)
            prop=keyProperties{i};
            if isfield(pj.temp.oldProps,prop)
                set(fig,prop,pj.temp.oldProps.(prop));
            end
        end

        remainingProperties=setdiff(restoreProperties,keyProperties);
        for i=1:length(remainingProperties)
            prop=remainingProperties{i};
            set(fig,prop,pj.temp.oldProps.(prop));
        end
    end

end

function pj=LocalSaveAxesOldProps(pj)






    allAxes=findobjinternal(pj.Handles{1},'-isa','matlab.graphics.axis.AbstractAxes',...
    '-and','-not','Units','normalized');
    hLen=length(allAxes);
    pj.temp.oldAxesHandles=cell(1,hLen);


    if isempty(allAxes)
        return;
    end


    pj.temp.oldAxesProp={'OuterPosition','Position','LooseInset','ActivePositionProperty',...
    'OuterPositionMode','LooseInsetMode','ActivePositionPropertyMode'};
    pj.temp.oldAxesValue=cell(1,hLen);



    for idx=1:hLen
        pj.temp.oldAxesHandles{idx}=allAxes(idx);
        pj.temp.oldAxesValue{idx}=get(pj.temp.oldAxesHandles{idx},pj.temp.oldAxesProp);
    end
end

function LocalRestoreAxesOldProps(pj)


    if isempty(pj.temp.oldAxesHandles)
        return;
    end

    propsToRestoreForAxesInLayout=pj.temp.oldAxesProp;


    removePropsForAxesInLayout={'Position','InnerPosition',...
    'OuterPosition','ActivePositionProperty'};


    indexOfPropsToRestoreForAxesInLayout=...
    ~ismember(propsToRestoreForAxesInLayout,removePropsForAxesInLayout);


    propsToRestoreForAxesInLayout(ismember(propsToRestoreForAxesInLayout,...
    removePropsForAxesInLayout))=[];


    activePositionPropIdx=find(strcmp(pj.temp.oldAxesProp,'ActivePositionProperty'));
    activePositionModeIdx=find(strcmp(pj.temp.oldAxesProp,'ActivePositionPropertyMode'));
    for idx=1:length(pj.temp.oldAxesHandles)
        ax=pj.temp.oldAxesHandles{idx};
        if~ax.isInLayout


            actPosProp=pj.temp.oldAxesValue{idx}{activePositionPropIdx};
            theActPosIdx=find(strcmpi(pj.temp.oldAxesProp,actPosProp));
            set(ax,pj.temp.oldAxesProp,pj.temp.oldAxesValue{idx});


            set(ax,actPosProp,pj.temp.oldAxesValue{idx}{theActPosIdx});
        else
            valsToRestoreForAxesInLayout=pj.temp.oldAxesValue{idx}(indexOfPropsToRestoreForAxesInLayout);
            set(ax,propsToRestoreForAxesInLayout,...
            valsToRestoreForAxesInLayout);
        end


        set(ax,'ActivePositionPropertyMode',...
        pj.temp.oldAxesValue{idx}{activePositionModeIdx});
    end
end






function LocalPollUntilReady(isReadyFcn,msg,pj,varargin)
    startT=cputime;


    pj.temp.PollCounter=0;
    pj.temp.Current_Width=0;
    pj.temp.Current_Height=0;

    while~isReadyFcn(pj,varargin{:})
        delay=cputime-startT;



        if delay>500||pj.temp.PollCounter>1000
            error(message('MATLAB:print:polling',floor(delay),...
            message(msg).getString))
        end
    end
end



function updated=LocalIsSizeUpdated(pj,fig,targetSize,debugMode)
    if LocalIsShowDisabled(pj)
        updated=true;
        return
    end

    pos=getpixelposition(fig);

    targetPixPos=hgconvertunits(fig,[1,1,targetSize],get(fig,'Units'),'pixels',groot);





    pixPosDiff=abs(pos-targetPixPos);
    updated=(pixPosDiff(3)<1)&&(pixPosDiff(4)<1);

    if(pos(3)==pj.temp.Current_Width&&pos(4)==pj.temp.Current_Height)


        pj.temp.PollCounter=pj.temp.PollCounter+1;
    else


        pj.temp.PollCounter=0;
    end

    if~updated
        if debugMode
            fprintf(1,getString(message('MATLAB:uistring:alternateprintpath:SizeNotReady',pos(3),pos(4),targetSize(1),targetSize(2))));
        end
        pos=get(fig,'Position');
        set(fig,'Position',[pos(1),pos(2),targetSize])
    end


    pj.temp.Current_Width=pos(3);
    pj.temp.Current_Height=pos(4);
end

function LocalValidatePrintJob(pj)
    if~pj.DebugMode&&~isappdata(groot,'PrintUnitTest')
        return
    end






    poSize=pj.PixelOutputPosition(3:4);
    scSize=pj.temp.ScreenSizeInPixels;

    if any(poSize>scSize*2)
        error(message('MATLAB:print:FigureSizeTooLarge',poSize(1),poSize(2)))
    end
end

function disabled=LocalIsShowDisabled(pj)
    [~,javaFrame]=pj.getJavaContainer();
    disabled=~isempty(javaFrame)&&javaFrame.isShowDisabled;
end

function pj=LocalDealWithResizeFcn(pj)












    h=pj.Handles{1};

    adjustResizeFcn=1;
    rf=get(h,'ResizeFcn');
    if ischar(rf)
        if strcmp(rf,'legend(''ResizeLegend'')')...
            ||strcmp(rf,'doresize(gcbf)')



            badResizeFcn='';%#ok<NASGU>
            adjustResizeFcn=0;
        end
    end

    if adjustResizeFcn


        badResizeFcn=rf;


        if~isempty(badResizeFcn)&&~pj.isPaperPositionModeAuto()
            pointsFactor=pj.ScreenDPI;
            pointsPerInch=72;
            pointsWindowPos=(hgconvertunits(h,get(h,'Position'),...
            get(h,'Units'),'Pixels',groot)...
            /pointsFactor)*pointsPerInch;
            pointsPaperPos=hgconvertunits(h,get(h,'PaperPosition'),...
            get(h,'PaperUnits'),'Points',groot);




            if(pointsWindowPos(3)~=pointsPaperPos(3))||...
                (pointsWindowPos(4)~=pointsPaperPos(4))



                printbehavior=hggetbehavior(h,'Print','-peek');
                if isempty(printbehavior)||...
                    strcmp(printbehavior.WarnOnCustomResizeFcn,'on')

                    warning(message('MATLAB:print:CustomResizeFcnInPrint'));
                end


                screenpos(h,[pointsWindowPos(1:2),pointsPaperPos(3:4)]);



                pj.temp.allContents=findall(pj.Handles{1});
            end
        end




        if~isempty(badResizeFcn)
            set(h,'ResizeFcn','');
        end
    end

end

function yesno=LocalHasSceneViewer(pj)
    if isfield(pj.temp,'HasSceneViewer')
        yesno=pj.temp.HasSceneViewer;
        return
    end

    container=pj.Handles{1};
    yesno=~isempty(pj.Handles{1}.CurrentAxes)||...
    ~isempty(findall(container,'-isa','matlab.graphics.axis.AbstractAxes'))||...
    ~isempty(findobjinternal(container,...
    '-isa','matlab.graphics.primitive.canvas.Canvas','-depth',inf));
    pj.temp.HasSceneViewer=yesno;
end

function sceneViewer=LocalGetSceneViewer(container)



    sceneViewer=findobjinternal(container,...
    '-isa','matlab.graphics.primitive.canvas.Canvas','-depth',1);
end

function pj=LocalUpdateViewer(pj)

    if~LocalHasSceneViewer(pj)
        return
    end

    drawnowNeeded=false;

    dpi=pj.DPI;

    if dpi<0
        error(message('MATLAB:print:DPIValueBelowZero'))
    end



    if isfield(pj.temp,'dpiAdjustment')&&...
        ~isempty(pj.temp.dpiAdjustment)
        dpi=dpi*pj.temp.dpiAdjustment;
    end

    pj.ScaledDPI=dpi;


    f=pj.Handles{1};
    pj.CanvasDPI=get(f.getCanvas,'ScreenPixelsPerInch');

    if dpi~=pj.temp.DeviceDPI


        containers=LocalFindContainers(pj.Handles{1});

        for i=1:length(containers)
            viewer=LocalGetSceneViewer(containers{i});
            if~isempty(viewer)

                if isequal(viewer.OpenGL,'on')



                    set(viewer,'ScreenPixelsPerInch',dpi);
                    drawnowNeeded=true;
                end

            end
        end
    end



    if drawnowNeeded
        drawnow;
    end
end

function containers=LocalFindContainers(candidate)
    if isa(candidate,'matlab.ui.container.internal.UIContainer')||...
        ishghandle(candidate,'figure')
        containers={candidate};
        children=allchild(candidate);
        for i=1:length(children)
            if isa(children(i),'matlab.ui.container.internal.UIContainer')
                containers=[containers,LocalFindContainers(children(i))];%#ok<AGROW>
            end
        end
    else
        containers=[];
    end
end

function pj=LocalUpdateRenderer(pj)
    cleanupHandler=onCleanup(@()ensureRendererSettingConsistency(pj));

    if matlab.graphics.internal.autoSwitchToPaintersForPrint(pj)

        pj.rendererOption=1;
        pj.Renderer='painters';
    end
    if pj.rendererOption
        switch lower(pj.Renderer)

        case 'opengl'
            viewerOpenGLSetting='on';
        case 'painters'
            viewerOpenGLSetting='off';

        otherwise
            error(message('MATLAB:print:UnrecognizedValueForOpenGLProperty',pj.Renderer))
        end
    end

    if~LocalHasSceneViewer(pj)


        if pj.rendererOption
            set(pj.Handles{1},'Renderer_I',lower(pj.Renderer));
        end
        return;
    end

    containers=LocalFindContainers(pj.Handles{1});
    pj.temp.viewers=[];
    for i=1:length(containers)
        viewer=LocalGetSceneViewer(containers{i});
        if~isempty(viewer)

            pj.temp.viewers(end+1).handle=viewer;
            pj.temp.viewers(end).OpenGL=viewer.OpenGL;
            pj.temp.viewers(end).OpenGLMode=viewer.OpenGLMode;
            pj.temp.viewers(end).ScreenPixelsPerInch=viewer.ScreenPixelsPerInch;
            pj.temp.viewers(end).ScreenPixelsPerInchMode=viewer.ScreenPixelsPerInchMode;

            if pj.rendererOption




                viewer.OpenGL=viewerOpenGLSetting;
            end
        end
    end

    if pj.rendererOption

        set(pj.Handles{1},'Renderer_I',lower(pj.Renderer));
    end



    function ensureRendererSettingConsistency(pj)
        if pj.rendererOption&&~strcmpi(pj.Renderer,pj.temp.oldProps.Renderer_I)
            refresh(pj.Handles{1});
            pj.temp.outputUsesPainters=strcmpi(pj.Handles{1}.Renderer,'painters');
        end
    end

end

function LocalUpdatePosition(pj)


    fpos=get(pj.Handles{1},'Position');

    newFigPos=hgconvertunits(pj.Handles{1},...
    [fpos(1:2),pj.PixelOutputPosition(3:4)],'Pixels',...
    get(pj.Handles{1},'Units'),groot);


    if~strcmp(pj.Handles{1}.WindowState,'docked')
        set(pj.Handles{1},'WindowState','normal')
        drawnow;
    end
    set(pj.Handles{1},'Position',newFigPos);


    if(newFigPos(3)>fpos(3))||(newFigPos(4)>fpos(4))
        errmsg='MATLAB:uistring:alternateprintpath:RequestedSizeTooLarge';
    else
        errmsg='MATLAB:uistring:alternateprintpath:RequestedSizeTooSmall';
    end

    LocalPollUntilReady(@LocalIsSizeUpdated,errmsg,pj,...
    pj.Handles{1},newFigPos(3:4),pj.DebugMode);



    drawnow;
end

function pj=LocalUpdateContainsTex(pj)







    if pj.temp.outputUsesPainters&&...
        (strcmp(pj.Driver,'meta')||strcmp(pj.Driver,'svg'))

        fig=pj.Handles{1};

        pj.ContainsTex=matlab.graphics.internal.export.needsTextAsShapes(fig);
    end
end

function transparent=LocalDoTransparentBackground(pj)



    transparent=0;

    if~pj.temp.outputUsesPainters
        return
    end





    figureIsSetupForTransparency=...
    strcmp(get(pj.Handles{1},'Color'),'none')&&strcmpi(get(pj.Handles{1},'Inverthardcopy'),'off');




    outputFormatSupportsTransparency=...
    pj.isPrintDriver()||...
    (length(pj.Driver)>2&&any(strcmpi(pj.Driver(1:3),{'eps','met','pdf','svg'})));



    copyOptionsWantsTransparency=pj.temp.HonorCOPrefs&&~pj.temp.COFigureBackground;





    printjobOverride=pj.TransparentBackground;

    if outputFormatSupportsTransparency&&...
        (printjobOverride||copyOptionsWantsTransparency||figureIsSetupForTransparency)
        transparent=1;
    end
end

function LocalWarnIfScalingUI(pj)
    if(pj.temp.dpiAdjustment~=1)&&...
        ~isempty(findall(pj.temp.allContents,'-depth',0,'visible','on','-and',...
        {'type','uicontrol','-or',...
        'type','hgjavacomponent','-or',...
        'type','uitable','-or',...
        'type','uicontainer','-or',...
        'type','uipanel','-or',...
        'type','uigridcontainer','-or',...
        'type','uiflowcontainer','-or',...
        'type','hgjavacomponent','-or',...
        'type','uitabgroup'}))

        warnMode=warning('backtrace','off');
        warning(message('MATLAB:print:UIControlsScaled'))
        warning(warnMode)
    end
end
