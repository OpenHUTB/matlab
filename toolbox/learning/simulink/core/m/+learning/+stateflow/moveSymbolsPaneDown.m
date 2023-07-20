function moveSymbolsPaneDown()






    studios=DAS.Studio.getAllStudios();
    studio=[];
    for i=1:length(studios)
        if(isequal(get_param(studios{i}.App.blockDiagramHandle,'Name'),'StateflowOnramp'))
            studio=studios{i};
        end
    end
    if isempty(studio)
        return
    end

    dockedComps=studio.getDockComponents();
    symbolComp=[];
    for i=1:length(dockedComps)
        if isequal(dockedComps{i}.getName(),'SymbolManager')
            symbolComp=dockedComps{i};
        end
    end
    if isempty(symbolComp)
        return
    end

    studio.moveComponentToDockPosition(symbolComp,'Right');
end

