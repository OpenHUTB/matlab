function options=getNodeOptions(explorerHandle)







    explorerTabGroup=explorerHandle.getTabGroup('ResultsExplorerTabGroup');
    explorerHomeTab=explorerTabGroup.getChildByTag('ResultsExplorerHomeTab');


    explorerPlotSection=explorerHomeTab.getChildByTag('ResultsExplorerPlotOptsSection');

    markerColumn=explorerPlotSection.getChildByTag('ResultsExplorerMarkerColumn');
    markerButton=markerColumn.getChildByTag('ResultsExplorerMarkerButton');

    totalMarkers=numel(markerButton.Popup.getChildByIndex);
    for i=1:totalMarkers
        if(markerButton.Popup.getChildByIndex(i).Value)
            options.marker=markerButton.Popup.getChildByIndex(i).Text;
            break;
        end
    end

    layoutColumn=explorerPlotSection.getChildByTag('ResultsExplorerLayoutColumn');
    layoutButton=layoutColumn.getChildByTag('ResultsExplorerLayoutButton');

    totalLayoutOptions=numel(layoutButton.Popup.getChildByIndex);
    for i=1:totalLayoutOptions
        if(layoutButton.Popup.getChildByIndex(i).Value)
            options.layout=layoutButton.Popup.getChildByIndex(i).Text;
            break;
        end
    end


    plotOptsColumn=explorerPlotSection.getChildByTag('ResultsExplorerPlotOptsColumn');
    unitsButton=plotOptsColumn.getChildByTag('ResultsExplorerUnitsButton');
    plotTypeButton=plotOptsColumn.getChildByTag('ResultsExplorerPlotTypeButton');
    showLegendButton=plotOptsColumn.getChildByTag('ResultsExplorerShowLegendButton');


    totalUnits=numel(unitsButton.Popup.getChildByIndex);
    for i=1:totalUnits
        if(unitsButton.Popup.getChildByIndex(i).Value)
            options.unit=unitsButton.Popup.getChildByIndex(i).Text;
            break;
        end
    end


    totalPlotTypes=numel(plotTypeButton.Popup.getChildByIndex);
    for i=1:totalPlotTypes
        if(plotTypeButton.Popup.getChildByIndex(i).Value)
            options.plotType=plotTypeButton.Popup.getChildByIndex(i).Text;
            break;
        end
    end


    totalShowLegendOpts=numel(plotTypeButton.Popup.getChildByIndex);
    for i=1:totalShowLegendOpts
        if(showLegendButton.Popup.getChildByIndex(i).Value)
            options.legend=showLegendButton.Popup.getChildByIndex(i).Text;
            break;
        end
    end


    explorerAxesCtrlSection=explorerHomeTab.getChildByTag('ResultsExplorerAxesCtrlSection');
    axesCtrlColumn=explorerAxesCtrlSection.getChildByTag('ResultsExplorerAxesCtrlColumn');

    linkTimeAxesButton=axesCtrlColumn.getChildByTag('ResultsExplorerLinkTimeAxesButton');
    limitTimeAxesButton=axesCtrlColumn.getChildByTag('ResultsExplorerLimitTimeAxesButton');


    options.link=linkTimeAxesButton.Value;
    options.time.start=str2double(limitTimeAxesButton.Popup.getChildByIndex(1).Value);
    options.time.stop=str2double(limitTimeAxesButton.Popup.getChildByIndex(2).Value);
    options.unitsPerNode=containers.Map();
    options.isExtracted=false;
end