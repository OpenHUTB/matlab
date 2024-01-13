function modelName=getRootModelName(systemH,checkLib)

    if nargin<2
        checkLib=false;
    end

    modelH=[];
    if nargin<1||isempty(systemH)
        modelH=bdroot;
    else
        try
            modelH=bdroot(systemH);
        catch Me %#ok<NASGU>
        end
    end

    if isempty(modelH)
        error(message('polyspace:gui:pslink:noModelOpen'))
    end

    modelName=get_param(modelH,'Name');

    if checkLib&&strcmpi(get_param(modelH,'BlockDiagramType'),'library')
        error(message('polyspace:gui:pslink:modelIsLib',modelName))
    end


