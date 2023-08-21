function networkToLoad=getSelectedNetwork(...
    block,...
    networkSelect,...
    networkFilePath,...
    networkFunction)
    blockType=get_param(block,'MaskType');
    if strcmp(blockType,'Deep Learning Object Detector')
        keyword='Detector';
    else
        keyword='Network';
    end

    if nargin<4
        networkSelectValue=get_param(block,keyword);
        blockObject=get_param(block,'Object');
        allowedValues=blockObject.getPropAllowedValues(keyword);
        networkSelect=find(strcmpi(networkSelectValue,allowedValues));

        networkFilePath=get_param(block,[keyword,'FilePath']);
        networkFunction=get_param(block,[keyword,'Function']);
    end

    switch networkSelect
    case 1
        networkToLoad=networkFilePath;
    case 2
        networkToLoad=networkFunction;
    otherwise
        networkToLoad=get_param(block,keyword);
    end

    networkToLoad=char(networkToLoad);

end
