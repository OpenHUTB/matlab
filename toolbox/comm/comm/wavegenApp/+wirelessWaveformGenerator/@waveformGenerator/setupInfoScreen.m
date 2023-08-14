function setupInfoScreen(obj)





    if obj.useAppContainer
        infoDocument=obj.AppContainer.getDocument("figureDocumentGroup",'InfoFig');
        if isempty(infoDocument)
            infoDocument=matlab.ui.internal.FigureDocument(...
            'Title','Info',...
            'Tag','InfoFig',...
            'DocumentGroupTag','figureDocumentGroup',...
            'Closable',false);
            addDocument(obj.AppContainer,infoDocument);
            obj.pInfoFig=infoDocument.Figure;
        else
            infoDocument.Visible=true;
        end
    else
        obj.pInfoFig=figure('Name','Info','NumberTitle','off','HandleVisibility','off','Tag','InfoFig');
        obj.ToolGroup.addFigure(obj.pInfoFig);
    end

    uicontrol('Parent',obj.pInfoFig,...
    'Style','text','HorizontalAlignment','Left',...
    'String',getString(message('comm:waveformGenerator:InfoDesc')),...
    'Units','normalized','Position',[0.05,0.75,0.8,0.2],...
    'ForegroundColor',[0.45,0.45,0.45]);