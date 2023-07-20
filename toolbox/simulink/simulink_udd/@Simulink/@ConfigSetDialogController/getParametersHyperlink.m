function widget=getParametersHyperlink(hObj,parameterList,text,tooltip,message)















    hSrc=hObj.getSourceObject;
    widget.Name=text;
    widget.ToolTip=tooltip;
    widget.Type='hyperlink';
    widget.Source=hSrc;
    widget.Graphical=true;
    widget.MatlabMethod='configset.highlightParameter';
    widget.MatlabArgs={hSrc.getConfigSet,parameterList,'','List',...
    [configset.internal.getMessage('FilteredResults'),' ',message]};
