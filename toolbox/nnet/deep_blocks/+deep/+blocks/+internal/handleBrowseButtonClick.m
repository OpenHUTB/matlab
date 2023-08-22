function handleBrowseButtonClick(block)
    [file,path,~]=uigetfile('*.mat');
    blockType=get_param(block,'MaskType');
    if strcmp(blockType,'Deep Learning Object Detector')
        keyword='Detector';
    else
        keyword='Network';
    end

    if~isequal(file,0)
        set_param(block,[keyword,'FilePath'],fullfile(path,file));
    end

end
