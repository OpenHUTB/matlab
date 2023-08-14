function varargout=launchNTX(histogramMatFileName,histogramIdxVec)





    if~fifeature('NTXHistogramUI')
        ntx=launchNTXDialog(histogramMatFileName,histogramIdxVec);

        if nargout>0
            varargout{1}=ntx;
        end
    else
        data=ntxui.Utils.getHistogramData(histogramMatFileName,histogramIdxVec);

        if isempty(data)
            msg=getString(message('fixed:NumericTypeScope:ntxLaunchException'));
            ntxException=MException('NumericTypeScope:ntxLaunchError',msg);
            throwAsCaller(ntxException);
        end


        result=ntxui.HistogramLoggingResult(data);

        ntxui.NumericTypeScope.launch(result);
    end

end


function ntx=launchNTXDialog(histogramMatFileName,histogramIdxVec)
    load(histogramMatFileName,'histogramStruct');

    [idxNonZeroHistValuesPos,nonZeroHistValuesPos]=extractNonZeroHistogramData(histogramStruct(histogramIdxVec(1)).HistogramOfPositiveValues(histogramIdxVec(2),:));
    [idxNonZeroHistValuesNeg,nonZeroHistValuesNeg]=extractNonZeroHistogramData(histogramStruct(histogramIdxVec(1)).HistogramOfNegativeValues(histogramIdxVec(2),:));
    numberOfHistogramBins=numel(histogramStruct(histogramIdxVec(1)).HistogramOfPositiveValues(histogramIdxVec(2),:));
    numberOfZeros=histogramStruct(histogramIdxVec(1)).NumberOfZeros(histogramIdxVec(2));
    numberOfPositiveValues=histogramStruct(histogramIdxVec(1)).NumberOfPositiveValues(histogramIdxVec(2));
    numberOfNegativeValues=histogramStruct(histogramIdxVec(1)).NumberOfNegativeValues(histogramIdxVec(2));
    totalNumberOfValues=histogramStruct(histogramIdxVec(1)).TotalNumberOfValues(histogramIdxVec(2));
    simMin=histogramStruct(histogramIdxVec(1)).SimMin(histogramIdxVec(2));
    simMax=histogramStruct(histogramIdxVec(1)).SimMax(histogramIdxVec(2));
    simSum=histogramStruct(histogramIdxVec(1)).SimSum(histogramIdxVec(2));
    defaultDTWL=histogramStruct(1).DefaultDTWL;
    defaultDTFL=histogramStruct(1).DefaultDTFL;
    wl=histogramStruct(histogramIdxVec(1)).WL{histogramIdxVec(2)};
    fl=histogramStruct(histogramIdxVec(1)).FL{histogramIdxVec(2)};
    proposedSignednessStr=histogramStruct(histogramIdxVec(1)).ProposedSignednessStr{histogramIdxVec(2)};
    proposedWL=histogramStruct(histogramIdxVec(1)).ProposedWL{histogramIdxVec(2)};
    proposedFL=histogramStruct(histogramIdxVec(1)).ProposedFL{histogramIdxVec(2)};
    fcnName=histogramStruct(histogramIdxVec(1)).FunctionName;
    varName=histogramStruct(histogramIdxVec(1)).VariableName{histogramIdxVec(2)};
    tag=histogramStruct(1).Tag;

    tag=['locationLogging_histogramFigure',tag];
    figName=['NumericTypeScope - ',fcnName,': ',varName];

    hFig=figure('menubar','none','handlevisibility','off',...
    'tag',tag,'NumberTitle','off',...
    'IntegerHandle','off','Name',figName);






    createFileMenu(hFig);





    pos=get(hFig,'Position');
    pos=uiservices.fixFigurePosition(pos);
    set(hFig,'WindowStyle','normal','Position',pos);
    embedded.ntxui.HistogramVisual.setPosition(hFig);




    hMainFlow=uiflowcontainer('v0',...
    'Parent',hFig,...
    'Tag','ApplicationLayoutContainer',...
    'Flowdirection','topdown',...
    'HitTest','off',...
    'Margin',0.1);

    hVisParent=uicontainer('Parent',hMainFlow,...
    'Tag','VisualizationAreaContainer',...
    'HitTest','off');



    grayLine=uicontrol('Parent',hMainFlow,...
    'Style','frame',...
    'ForegroundColor',get(0,'FactoryUipanelShadowColor'),...
    'Tag','GraySeparatorLine',...
    'Position',[0,0,1,1]);
    set(grayLine,'HeightLimits',[0,0]);

    whiteLine=uicontrol('Parent',hMainFlow,...
    'Style','frame',...
    'ForegroundColor',get(0,'FactoryUipanelHighlightColor'),...
    'Tag','WhiteSeparatorLine',...
    'Position',[0,0,1,1]);
    set(whiteLine,'HeightLimits',[0,0]);


    hPanel=uipanel('Parent',hVisParent,...
    'Visible','off',...
    'Tag','VisualizationPanel',...
    'BorderType','none');

    ntx=embedded.ntxui.NTX(hPanel);
    set(getVisibleHandles(ntx),'Visible','On');

    createMenus(hFig,ntx);

    ntxStruct=struct(...
    'NumberOfHistogramBins',numberOfHistogramBins,...
    'IdxNonZeroHistValuesPos',idxNonZeroHistValuesPos,...
    'NonZeroHistValuesPos',nonZeroHistValuesPos,...
    'IdxNonZeroHistValuesNeg',idxNonZeroHistValuesNeg,...
    'NonZeroHistValuesNeg',nonZeroHistValuesNeg,...
    'NumberOfZeros',numberOfZeros,...
    'NumberOfPositiveValues',numberOfPositiveValues,...
    'NumberOfNegativeValues',numberOfNegativeValues,...
    'TotalNumberOfValues',totalNumberOfValues,...
    'SimMin',simMin,...
    'SimMax',simMax,...
    'SimSum',simSum,...
    'DefaultDTWL',defaultDTWL,...
    'DefaultDTFL',defaultDTFL,...
    'WL',wl,...
    'FL',fl,...
    'ProposedSignednessStr',proposedSignednessStr,...
    'ProposedWL',proposedWL,...
    'ProposedFL',proposedFL);


    updateVisualFromHistogramLoggingData(ntx,ntxStruct);
    set(hPanel,'Visible','on');
    drawnow expose;
end


function createFileMenu(hFig)


    hFile=uimenu(hFig,'Label',getString(message('Spcuilib:scopes:MenuFile')));


    hClose=uimenu(hFile,'Label',getString(message('Spcuilib:scopes:MenuFileClose')),...
    'Callback',@(~,~)close(hFig),...
    'Accelerator','w');%#ok<NASGU>


    uimenu(hFile,'Label',getString(message('Spcuilib:scopes:MenuFileCloseAll','NumericTypeScope')),...
    'Callback',@(~,~)coder.internal.closeAllLocationLoggingNumericTypeScopes());

end


function createMenus(hFig,ntx)


    uimenu(hFig,'Label',getString(message('Spcuilib:scopes:MenuView')),...
    'Callback',@(hco,~)localCreateDynamicMenu(hco,ntx));


    hHelp=uimenu(hFig,'Label',getString(message('Spcuilib:scopes:MenuHelp')));

    mapFileLocation=fullfile(docroot,'toolbox','fixedpoint','fixedpoint.map');


    hNTXHelp=uimenu(hHelp,'Label',getString(message('fixed:NumericTypeScope:NTXHelp')),...
    'Callback',@(~,~)helpview(mapFileLocation,'nts_histogram'));%#ok<NASGU>


    hFPDHelp=uimenu(hHelp,'Label',getString(message('fixed:NumericTypeScope:FPToolboxHelp')),...
    'Callback',@(~,~)helpview(mapFileLocation,'fixedpoint_roadmap'));%#ok<NASGU>


    hFPDDemo=uimenu(hHelp,'Label',getString(message('fixed:NumericTypeScope:FPToolboxDemos')),...
    'Separator','on',...
    'Callback',@(~,~)demo('matlab','Fixed-Point Designer'));%#ok<NASGU>


    hAboutFPD=uimenu(hHelp,'Label',getString(message('fixed:NumericTypeScope:FPToolboxAbout')),...
    'Separator','on',...
    'Callback',@(~,~)aboutfixedpttlbx);%#ok<NASGU>

end


function[idxNonZeroHistValues,nonZeroHistogramValues]=extractNonZeroHistogramData(histogramValues)
    idxNonZeroHistValues=find(histogramValues);
    nonZeroHistogramValues=full(histogramValues(idxNonZeroHistValues));
end


function localCreateDynamicMenu(hView,ntx)










    delete(get(hView,'Children'));


    hDialogPanel=uimenu(hView,'Label',getString(message('Spcuilib:scopes:MenuDialogPanel')));
    dp=ntx.dp;
    buildContextDialogSelection(dp,hDialogPanel);
    buildPanelMenuOptions(dp,hDialogPanel);


    hVerticalUnits=uimenu(hView,'Label',getString(message('fixed:NumericTypeScope:VerticalUnitsMenuItem')),...
    'Separator','on');
    buildVerticalUnitsMenu(ntx,hVerticalUnits);


    hBringAll=uimenu(hView,'Label',getString(message('Spcuilib:scopes:MenuViewBringFwd','NumericTypeScope')),...
    'Callback',@(~,~)fixed.internal.showAllLocationLoggingNTScopes(),...
    'Separator','on','Accelerator','f');%#ok<NASGU>

end




