






function[inputPortNames,outputPortNames]=getPortNames(soHandle)
    soMaskObj=Simulink.Mask.get(soHandle);
    display=soMaskObj.Display;
    splitDisplay=splitlines(display);
    displaySize=size(splitDisplay,1)-2;

    inputPortNames=cell(1,displaySize);
    inputPortNames(:)={''};
    outputPortNames=inputPortNames;
    for displayIdx=2:displaySize+1
        rowSplit=split(splitDisplay{displayIdx},'''');
        if strcmp(rowSplit{2},'input')
            inputPortNames{displayIdx-1}=rowSplit{4};
        elseif strcmp(rowSplit{2},'output')
            outputPortNames{displayIdx-1}=rowSplit{4};
        end
    end

    inputPortNames=inputPortNames(~cellfun('isempty',inputPortNames));
    outputPortNames=outputPortNames(~cellfun('isempty',outputPortNames));
end