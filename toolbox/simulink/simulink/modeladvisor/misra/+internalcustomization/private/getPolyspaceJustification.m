






function justification=getPolyspaceJustification(object)

    justification=struct(...
    'type',{},...
    'guidelines',{},...
    'status',{},...
    'severity',{},...
    'comment',{});

    handle=[];
    if isa(object,'ModelAdvisor.Text')
        if isprop(object,'Content')
            try
                handle=Simulink.ID.getHandle(object.content);
            catch
                return;
            end
        end
    else
        try
            handle=get_param(object,'Handle');
        catch
            return;
        end
    end

    if~isa(handle,'double')

        return;
    end

    if strcmp(get_param(handle,'BlockType'),'Subsystem')

        return;
    end

    try
        psStartComment=get_param(handle,'PolySpaceStartComment');
        psEndComment=get_param(handle,'PolySpaceEndComment');
    catch
        return;
    end

    patternBegin='polyspace:begin<(.*):(.*):(.*):(.*)>(.*)';
    patternEnd='polyspace:end<(.*):(.*):(.*):(.*)>';

    tokensBegin=regexp(psStartComment,patternBegin,'tokens');
    tokensEnd=regexp(psEndComment,patternEnd,'tokens');

    if~isempty(tokensBegin)&&~isempty(tokensEnd)
        tokensBegin=tokensBegin{1};
        tokensEnd=tokensEnd{1};
        if strcmp(tokensBegin{1},tokensEnd{1})&&...
            strcmp(tokensBegin{2},tokensEnd{2})&&...
            strcmp(tokensBegin{3},tokensEnd{3})&&...
            strcmp(tokensBegin{4},tokensEnd{4})

            justification(1).type=tokensBegin{1};
            justification(1).guidelines=tokensBegin{2};
            justification(1).severity=tokensBegin{3};
            justification(1).status=tokensBegin{4};
            justification(1).comment=tokensBegin{5};
        end
    end

end

