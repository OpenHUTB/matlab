function updateLegendPosition(dlg,legendPosition)




    switch legendPosition
    case DAStudio.message('SDI:toolStrip:ShowLegendOnTop')
        legendPosition=0;
    case DAStudio.message('SDI:toolStrip:ShowLegendOnRight')
        legendPosition=1;
    case DAStudio.message('SDI:toolStrip:HideLegend')
        legendPosition=2;
    end
    dlg.setWidgetValue('legendPosition',legendPosition);

    dlg.enableApplyButton(false,false);
end