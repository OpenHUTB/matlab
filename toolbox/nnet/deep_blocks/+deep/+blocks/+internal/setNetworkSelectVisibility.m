function setNetworkSelectVisibility(block)

    mask=Simulink.Mask.get(block);
    blockType=mask.Type;

    if strcmp(blockType,'Deep Learning Object Detector')
        keyword='Detector';
    else
        keyword='Network';
    end

    functionEdit=mask.getParameter([keyword,'Function']);
    fileEdit=mask.getParameter([keyword,'FilePath']);
    browseButton=mask.getDialogControl('BrowseButton');

    blockObj=get_param(block,'Object');
    allowedValues=blockObj.getPropAllowedValues(keyword);
    currentValue=get_param(block,keyword);
    valueIdx=find(strcmpi(currentValue,allowedValues));

    fileOptionIdx=1;
    functionOptionIdx=2;

    switch valueIdx
    case fileOptionIdx
        functionEdit.Visible='off';
        fileEdit.Visible='on';
        browseButton.Visible='on';
    case functionOptionIdx
        functionEdit.Visible='on';
        fileEdit.Visible='off';
        browseButton.Visible='off';
    otherwise
        functionEdit.Visible='off';
        fileEdit.Visible='off';
        browseButton.Visible='off';
    end

end
