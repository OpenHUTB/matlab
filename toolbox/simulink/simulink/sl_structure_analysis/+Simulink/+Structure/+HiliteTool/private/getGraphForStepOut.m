function stepOutGraph=getGraphForStepOut(block)


    currentGraph=get_param(block,'Parent');
    currentGraphHandle=get_param(currentGraph,'handle');
    parentGraph=get_param(currentGraph,'Parent');

    if(~isempty(parentGraph))
        stepOutGraph=get_param(parentGraph,'handle');
    else
        [stepOutGraph,~]=getBdContainingModelRef(currentGraphHandle);
    end

end

