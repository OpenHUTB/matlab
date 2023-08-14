function OnFluidPropertyChange(hThis,hDlg)






    [viscValStr,densValStr,bulkValStr,errStr,propPanelVis]=ComputePropsAsStrings(hThis);
    tags=hThis.ChildTags;




    hDlg.setWidgetValue(tags.error,errStr);
    hDlg.setWidgetValue(tags.density,densValStr);
    hDlg.setWidgetValue(tags.viscosity,viscValStr);
    hDlg.setWidgetValue(tags.modulus,bulkValStr);




    hDlg.setVisible(tags.props,propPanelVis(1));
    hDlg.setVisible(tags.error,propPanelVis(2));




    hDlg.resetSize(false);

end