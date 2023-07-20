









function label=getWidgetLabel(hDialog,tag)

    imd=DAStudio.imDialog.getIMWidgets(hDialog);
    widget=find(imd,'tag',tag);
    label=widget.label;
