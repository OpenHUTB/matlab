function setScopeLayout(obj)




    numScopes=obj.pPlotTimeScope+obj.pPlotSpectrum+obj.pPlotConstellation+...
    obj.pPlotEyeDiagram+obj.pPlotCCDF+obj.pParameters.CurrentDialog.numVisibleFigs();

    if~obj.useAppContainer
        md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
    end

    if numScopes==0
        if obj.useAppContainer||isempty(obj.pInfoFig)

            obj.setupInfoScreen();
        end

        if~obj.useAppContainer
            obj.pInfoFig.Visible='on';
            index=1;
            loc=com.mathworks.widgets.desk.DTLocation.create(index);
            javaMethodEDT('setClientLocation',md,obj.pInfoFig.Name,obj.ToolGroup.Name,loc);
            drawnow;
            prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            state=java.lang.Boolean.FALSE;
            md.getClient(obj.pInfoFig.Name,obj.ToolGroup.Name).putClientProperty(prop,state);
        end
    end
    if~obj.useAppContainer
        layoutXML=obj.getLayoutXML();
        layout=com.mathworks.widgets.desk.TilingSerializer.deserialize(layoutXML);
    end

    [tsName,saName,cdName]=deal([]);
    hideInactiveScopes(obj);
    if numScopes==0
        if~obj.useAppContainer
            javaMethodEDT('setDocumentTiling',md,obj.ToolGroup.Name,layout);
        end
        return
    end
    if~isempty(obj.pInfoFig)
        if obj.useAppContainer
            infoDocument=obj.AppContainer.getDocument("figureDocumentGroup",'InfoFig');
            if~isempty(infoDocument)
                infoDocument.Visible=false;
            end
        else
            obj.pInfoFig.Visible='off';
        end
    end

    obj.setStatus(getString(message('comm:waveformGenerator:SettingUpScopes')));
    if obj.pPlotSpectrum
        saName=setupScopeObject(obj,obj.pSpectrum1,'Spectrum Analyzer');
    end
    if obj.pPlotTimeScope
        tsName=setupScopeObject(obj,obj.pTimeScope,'Time Scope');
    end
    if obj.pPlotConstellation
        cdName=setupScopeObject(obj,obj.pConstellation,'Constellation Diagram');
    end
    if obj.pPlotEyeDiagram
        if isempty(obj.pEyeDiagramFig)
            if~obj.useAppContainer
                obj.pEyeDiagramFig=figure('Name','Eye Diagram','Tag','Eye Diagram',...
                'HandleVisibility','off','IntegerHandle','off');
            else
                eyeDocument=obj.AppContainer.getDocument("figureDocumentGroup",'Eye Diagram');
                if isempty(eyeDocument)
                    eyeDocument=matlab.ui.internal.FigureDocument(...
                    'Title','Eye Diagram',...
                    'Tag','Eye Diagram',...
                    'DocumentGroupTag','figureDocumentGroup',...
                    'Closable',false);
                    addDocument(obj.AppContainer,eyeDocument);
                else
                    eyeDocument.Visible=true;
                end
                obj.pEyeDiagramFig=eyeDocument.Figure;
                obj.pEyeDiagramFig.AutoResizeChildren='off';
                obj.pEyeDiagramFig.Tag='Eye Diagram';
            end


            sps=16;
            eyediagram(nan(sps,1)+1i*nan(sps,1),sps,sps,0,'y-',obj.pEyeDiagramFig);


            t=findall(obj.pEyeDiagramFig,'String','Eye Diagram for In-Phase Signal');
            ax=t.Parent;
            xlabel(ax,'')
        end
        if~obj.useAppContainer
            obj.ToolGroup.addFigure(obj.pEyeDiagramFig);
        end
    end
    ccdfFig=obj.pCCDFFig;
    if obj.pPlotCCDF
        ccdfFig=addCCDFFig(obj);
    end
    currDialog=obj.pParameters.CurrentDialog;
    needPlot=false;
    for visual=currDialog.visualNames
        fig=currDialog.getVisualFig(visual{:});
        if currDialog.getVisualState(visual{:})
            if~isempty(fig)&&any(isgraphics(fig))&&~obj.useAppContainer
                set(fig,'Visible','on')
                if~strcmpi(fig.WindowStyle,'Docked')
                    obj.ToolGroup.addFigure(fig);
                end
                figName=fig.Name;
            elseif obj.useAppContainer
                tags=cellfun(@(x)x.Tag,obj.AppContainer.getDocuments);
                newTag=currDialog.getFigureTag(visual{:});
                document=obj.AppContainer.getDocument("figureDocumentGroup",newTag);
                if~isempty(document)

                    document.Visible=true;
                elseif isempty(tags)||~contains(newTag,tags)




                    document=matlab.ui.internal.FigureDocument(...
                    'Title',currDialog.getFigureName(visual{:}),...
                    'Tag',newTag,...
                    'DocumentGroupTag','figureDocumentGroup',...
                    'Closable',false);
                    addDocument(obj.AppContainer,document);
                    document.Figure.Tag=newTag;
                    document.Figure.AutoResizeChildren='off';
                end
                currDialog.setVisualFig(visual{:},document.Figure);
                figName=newTag;
            end


            currDialog.figureAdded(figName);

            needPlot=true;
        end
    end
    if~isempty(obj.pWaveform)&&needPlot
        needReTiling=false;
        currDialog.customVisualizations(needReTiling);
    end
    needDraw=false;

    if obj.useAppContainer

        if~(isfield(obj.AppContainer.DocumentLayout,'tileCount')&&obj.AppContainer.DocumentLayout.tileCount==1&&numScopes==1)
            cols=currDialog.getNumTileColumns(numScopes)-1;
            rows=currDialog.getNumTileRows(numScopes);
            rowW=getRowWeights(currDialog,numScopes);
            colW=getColumnWeights(currDialog,numScopes);



            dL=struct();

            [tileCount,tileCoverage,tileOccupancy]=currDialog.getTileLayout(numScopes);
            dL.tileCount=tileCount;

            dL.gridDimensions.w=cols;
            dL.gridDimensions.h=rows;

            dL.columnWeights=colW(2:end)/sum(colW(2:end));
            dL.rowWeights=rowW';

            dL.tileCoverage=tileCoverage;
            dL.tileOccupancy=tileOccupancy;

            obj.AppContainer.DocumentLayout=dL;
        end

    else
        numPrevScopes=md.getDocumentTileCount(obj.ToolGroup.Name)-1;

        x=com.mathworks.widgets.desk.TilingSerializer.serialize(javaMethodEDT('getDocumentTiling',md,obj.ToolGroup.Name));
        baseWidth=0.22;
        if isunix&&~ismac
            baseWidth=1.3*baseWidth;
        end
        wasSingleColumnConfig=contains(string(x),['Column Weight="',num2str(baseWidth),'"']);
        singleColumn=currDialog.getNumColumns()==1;

        scopesNeed2Move=staleScopePosition(obj,md,tsName,saName,cdName,obj.pEyeDiagramFig,ccdfFig,string(layoutXML));


        if(numScopes~=numPrevScopes)||(singleColumn~=wasSingleColumnConfig)||scopesNeed2Move
            pause(0.05);
            javaMethodEDT('setDocumentTiling',md,obj.ToolGroup.Name,layout);
            needDraw=true;
        end



        if needDraw
            drawnow;
        end

        obj.setStatus('');


        prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
        state=java.lang.Boolean.FALSE;
        clients=md.getGroupMembers(obj.ToolGroup.Name);
        for i=1:length(clients)
            if isa(clients(i),'com.mathworks.hg.peer.FigureClientProxy$FigureDTClientBase')
                clients(i).putClientProperty(prop,state);
            end
        end
    end
end

function figName=setupScopeObject(obj,scope,flag)
    if isempty(scope)
        scope=createScope(obj,flag);
        firstTime=true;
    else
        firstTime=false;
    end

    if obj.useAppContainer
        if~scope.Docked
            scope.ContainerKey=obj.Key;
            scope.Docked=true;
        end
        figName=scope.Name;
    else
        frameWork1=getFramework(scope);
        fig=frameWork1.Parent;
        obj.ToolGroup.addFigure(fig);
        figName=fig.Name;
    end

    if obj.useAppContainer||~scope.isVisible()
        scope.show();
    end

    if strcmp(flag,'Time Scope')
        obj.setupTimeScope();
    end

    if~isempty(obj.pWaveform)&&firstTime
        scope(obj.pWaveform(:,1));
    end
end

function scope=createScope(obj,flag)
    switch flag
    case 'Time Scope'
        if obj.useAppContainer
            obj.pTimeScope=timescope;
            obj.pTimeScope.TimeSpanSource='property';
            obj.pTimeScope.AxesScaling='manual';
        else
            obj.pTimeScope=dsp.internal.TimeScopeBase;
            obj.pTimeScope.AxesScaling='Auto';
        end
        obj.pTimeScope.Name='Time Scope';
        obj.pTimeScope.TimeSpan=100;
        obj.pTimeScope.ChannelNames={'real','imag'};
        scope=obj.pTimeScope;

    case 'Spectrum Analyzer'

        if obj.useAppContainer
            obj.pSpectrum1=dsp.webscopes.SpectrumAnalyzerBaseWebScope(ShowScreenMessages=false);

            scope=obj.pSpectrum1;
        else
            obj.pSpectrum1=dsp.internal.SpectrumAnalyzerBase;
            scope=obj.pSpectrum1;
            saFig=scope.getFramework.Parent;
            saFig.SizeChangedFcn=@(a,b)removeSpectrumDisplayMessage(obj.pSpectrum1);

            noDataText=findall(saFig,'tag','SpectrumNoDataAvailableMsgText');
            noDataText.String={[],[]};
            noDataText.Visible='off';
        end


    case 'Constellation Diagram'
        if obj.useAppContainer
            obj.pConstellation=comm.ConstellationDiagram;
        else
            obj.pConstellation=comm.internal.ConstellationDiagram;
        end
        obj.pConstellation.ShowReferenceConstellation=false;
        obj.pConstellation.ColorFading=true;
        scope=obj.pConstellation;
    end
end

function hideInactiveScopes(obj)
    if~obj.pPlotTimeScope&&~isempty(obj.pTimeScope)
        obj.pTimeScope.hide();
    end
    if~obj.pPlotSpectrum&&~isempty(obj.pSpectrum1)
        obj.pSpectrum1.hide();
    end
    if~obj.pPlotConstellation&&~isempty(obj.pConstellation)
        obj.pConstellation.hide();
    end
    if~obj.pPlotEyeDiagram&&~isempty(obj.pEyeDiagramFig)
        if obj.useAppContainer
            eyeDocument=obj.AppContainer.getDocument("figureDocumentGroup",'Eye Diagram');
            eyeDocument.Visible=false;
            obj.pEyeDiagramFig=[];
        else
            set(obj.pEyeDiagramFig,'Visible','off');
        end
    end
    if~obj.pPlotCCDF&&~isempty(obj.pCCDFFig)
        if obj.useAppContainer
            ccdfDocument=obj.AppContainer.getDocument("figureDocumentGroup",'CCDF');
            ccdfDocument.Visible=false;
            obj.pCCDFFig=[];
        else
            if~obj.pCCDFFig.Visible



                set(obj.pCCDFFig,'Visible','on');
                drawnow;
            end
            set(obj.pCCDFFig,'Visible','off');
        end
    end

    dialogs=obj.pParameters.DialogsMap;
    for dialog=dialogs.values()
        for visual=dialog{:}.visualNames
            fig=dialog{:}.getVisualFig(visual{:});
            if(dialog{:}~=obj.pParameters.CurrentDialog||~dialog{:}.getVisualState(visual{:}))...
                &&~isempty(fig)&&isgraphics(fig)
                if obj.useAppContainer
                    doc=obj.AppContainer.getDocument('figureDocumentGroup',dialog{:}.getFigureTag(visual{:}));
                    doc.Visible=false;
                else
                    set(fig,'Visible','on');
                    set(fig,'Visible','off');
                end
            end
        end
    end
end

function needMove=staleScopePosition(obj,md,tsName,saName,cdName,edFig,ccdfFig,layoutXML)

    needMove=false;

    if obj.pPlotTimeScope
        needMove=needMove|isScopePosStale(obj,md,tsName,'Time Scope',layoutXML);
    end

    if obj.pPlotSpectrum
        needMove=needMove|isScopePosStale(obj,md,saName,'Spectrum Analyzer',layoutXML);
    end

    if obj.pPlotConstellation
        needMove=needMove|isScopePosStale(obj,md,cdName,'Constellation Diagram',layoutXML);
    end

    if obj.pPlotEyeDiagram
        needMove=needMove|isScopePosStale(obj,md,edFig.Name,'Eye Diagram',layoutXML);
    end

    if obj.pPlotCCDF
        needMove=needMove|isScopePosStale(obj,md,ccdfFig.Name,'CCDF',layoutXML);
    end
end
function needMove=isScopePosStale(obj,md,figName,scopeName,layoutXML)
    needMove=false;
    client=javaMethodEDT('getClient',md,figName,obj.ToolGroup.Name);
    curLoc=javaMethodEDT('getClientLocation',md,client);
    if isempty(curLoc)||...
        ~contains(layoutXML,['Name="',scopeName,'" Tile="',num2str(curLoc.getTile()),'"'])
        needMove=true;
    end
end

function removeSpectrumDisplayMessage(sa,~)
    noDataText=findall(sa.getFramework.Parent,'tag','SpectrumNoDataAvailableMsgText');
    if~isempty(noDataText)
        drawnow;
        noDataText.String={[],[]};
        noDataText.Visible='off';
    end
end


function ccdfFig=addCCDFFig(obj)

    if isempty(obj.pCCDFFig)
        if~obj.useAppContainer
            ccdfFig=figure('Name','CCDF','Tag','CCDF',...
            'HandleVisibility','off','IntegerHandle','off');
        else
            ccdfDocument=obj.AppContainer.getDocument("figureDocumentGroup",'CCDF');
            if isempty(ccdfDocument)
                ccdfDocument=matlab.ui.internal.FigureDocument(...
                'Title','CCDF',...
                'Tag','CCDF',...
                'DocumentGroupTag','figureDocumentGroup',...
                'Closable',false);
                ccdfDocument.Figure.AutoResizeChildren='off';
                addDocument(obj.AppContainer,ccdfDocument);
            else
                ccdfDocument.Visible=true;
            end
            ccdfFig=ccdfDocument.Figure;
        end
    else
        ccdfFig=obj.pCCDFFig;
    end


    clf(ccdfFig);


    cb=findobj(ccdfFig,'Style','checkbox');
    if isempty(cb)
        str=getString(message('comm:waveformGenerator:CCDFBurstModeCheckBox'));
        cb=uicontrol(ccdfFig,'Style','checkbox','String',str,...
        'Tag','BurstModeCheckbox','Units','normalized',...
        'BackgroundColor',ccdfFig.Color);
        cb.Position(1:2)=[0.02,0.005];
        cb.Units='characters';
        cb.Position(3:4)=[16,1.3];
        cb.Callback=@wirelessWaveformGenerator.waveformGenerator.CCDFBurstModeCheckBoxCallback;
        cb.Value=obj.pCCDFBurstMode;
    end


    ccdf=wirelessWaveformGenerator.waveformGenerator.getCCDF(obj.pWaveform);
    ccdf.BurstMode=obj.pCCDFBurstMode;
    ccdf.LegendChannelName=obj.pParameters.CurrentDialog.CCDFLegendChannelName;


    ax=axes(ccdfFig);
    wirelessWaveformGenerator.waveformGenerator.plotCCDF(ax,ccdf);




    cb.UserData=ccdf;

    if~obj.useAppContainer

        obj.ToolGroup.addFigure(ccdfFig);
    end

    obj.pCCDFFig=ccdfFig;
end