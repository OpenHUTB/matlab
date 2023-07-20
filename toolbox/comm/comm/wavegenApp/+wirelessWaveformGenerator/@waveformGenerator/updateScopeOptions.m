function popup=updateScopeOptions(obj,~)




    popup=matlab.ui.internal.toolstrip.PopupList();

    sub_item1=matlab.ui.internal.toolstrip.ListItemWithCheckBox('Time Scope');
    sub_item1.ShowDescription=false;
    sub_item1.Value=obj.pPlotTimeScope;
    sub_item1.Tag='timeScope';
    sub_item1.ValueChangedFcn=@(a,b)visualChanged(obj,sub_item1);
    popup.add(sub_item1);

    sub_item2=matlab.ui.internal.toolstrip.ListItemWithCheckBox('Spectrum Analyzer');
    sub_item2.ShowDescription=false;
    sub_item2.Value=obj.pPlotSpectrum;
    sub_item2.Tag='spectrumAnalyzer';
    sub_item2.ValueChangedFcn=@(a,b)visualChanged(obj,sub_item2);
    popup.add(sub_item2);

    currDlg=obj.pParameters.CurrentDialog;

    if currDlg.offersConstellation
        sub_item3=matlab.ui.internal.toolstrip.ListItemWithCheckBox('Constellation Diagram');
        sub_item3.ShowDescription=false;
        sub_item3.Value=obj.pPlotConstellation;
        sub_item3.Tag='constellation';
        sub_item3.ValueChangedFcn=@(a,b)visualChanged(obj,sub_item3);
        popup.add(sub_item3);
    end

    if currDlg.offersEyeDiagram
        sub_item4=matlab.ui.internal.toolstrip.ListItemWithCheckBox('Eye Diagram');
        sub_item4.ShowDescription=false;
        sub_item4.Value=obj.pPlotEyeDiagram;
        sub_item4.Tag='eyediagram';
        sub_item4.ValueChangedFcn=@(a,b)visualChanged(obj,sub_item4);
        popup.add(sub_item4);
    end

    if currDlg.offersCCDF
        sub_item5=matlab.ui.internal.toolstrip.ListItemWithCheckBox('CCDF');
        sub_item5.ShowDescription=false;
        sub_item5.Value=obj.pPlotCCDF;
        sub_item5.Tag='CCDF';
        sub_item5.ValueChangedFcn=@(a,b)visualChanged(obj,sub_item5);
        popup.add(sub_item5);
    end


    propSet=currDlg.getPropertySet();
    if~isempty(propSet.findProperty('Visualizations'))
        visuals=propSet.getPropValue('Visualizations');
        for idx=1:length(visuals)
            thisVis=visuals{idx};
            sub_itemN=matlab.ui.internal.toolstrip.ListItemWithCheckBox(thisVis);
            sub_itemN.ShowDescription=false;
            sub_itemN.Tag=currDlg.getFigureTag(thisVis);
            sub_itemN.Value=currDlg.getVisualState(thisVis);
            sub_itemN.ValueChangedFcn=@(a,b)visualChanged(obj,sub_itemN);
            popup.add(sub_itemN);
        end
    end
