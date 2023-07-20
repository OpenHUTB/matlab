function hiliteSelectedSignals(portHandle)





    if isequal(portHandle,-1)
        return;
    end


    validHandles=ishandle(portHandle);

    if~any(validHandles)
        return;
    end
    if~all(validHandles)
        portHandle=portHandle(validHandles);
    end



    [~,modelRefBlockIndex]=slsignalselector.utils.SignalSelectorUtilities.hasSelectionModelRef(portHandle);


    if~isempty(modelRefBlockIndex)
        portHandle=portHandle(~modelRefBlockIndex);
    end



    try
        validHandles=cellfun(@(port)isfield(get_param(port,'ObjectParameters'),'Line'),num2cell(portHandle));

        lines=accumulateLineChildren(get_param(portHandle(validHandles),'Line'));
    catch
        lines=[];
    end

    if isempty(lines)
        return;
    end

    model=unique(bdroot(portHandle));

    if~ishandle(model)
        return;
    end
    fullPath=get(portHandle,'Parent');
    containingParent=get_param(fullPath,'Parent');





    hEditor=GLUE2.Util.findAllEditors(get_param(model(1),'Name'));
    if isempty(hEditor)
        hEditor=GLUE2.Util.findAllEditors(containingParent);
    end

    hStudio=hEditor.getStudio();
    if isempty(hStudio)
        return;
    end


    for jndx=1:length(lines)
        hStudio.App.hiliteAndFadeObject(diagram.resolver.resolve(lines(jndx)),1200);
    end

end

function hLine=accumulateLineChildren(hLine)

    if iscell(hLine)
        hLine=cell2mat(hLine);
    end

    hLine(hLine==-1)=[];
    children=get_param(hLine,'LineChildren');

    for indx=1:numel(children)
        hLine=[hLine;accumulateLineChildren(children(indx))];%#ok<AGROW>
    end
end
