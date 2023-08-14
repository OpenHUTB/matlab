function smwritevideo_implementation(model,videoFileName,varargin)









    narginchk(2,12);

    baseException=pm_exception('sm:gui:smwritevideo:FailToWriteVideo');

    if isempty(model)
        baseException=baseException.addCause(...
        pm_exception('sm:gui:smwritevideo:EmptyModel'));
        throw(baseException);
    end

    rootModelName='';%#ok<NASGU>
    if ischar(model)

        if~bdIsLoaded(model)
            baseException=baseException.addCause(...
            pm_exception('sm:gui:smwritevideo:ModelNotLoaded'));
            throw(baseException);
        end
        rootModelName=bdroot(model);

    else

        if~simmechanics.sli.internal.is_model_handle(model)
            baseException=baseException.addCause(...
            pm_exception('sm:gui:smwritevideo:ModelHandleNotExist'));
            throw(baseException);
        end
        rootModelName=bdroot(get_param(model,'name'));

    end

    status=get_param(model,'SimulationStatus');
    if~strcmpi(status,'stopped')
        baseException=baseException.addCause(...
        pm_exception('sm:gui:smwritevideo:SimulationNotFinished'));
        throw(baseException);
    end

    inputs=parseInputs(varargin);

    frameRate=inputs.FrameRate;
    playbackSpeedRatio=inputs.PlaybackSpeedRatio;
    videoFormat=inputs.VideoFormat;
    frameSize=inputs.FrameSize;
    tile=inputs.Tile;

    rawErrors=javaMethodEDT('writeVideoML','com.mathworks.physmod.sm.gui.app.editor.SmWriteVideo',...
    rootModelName,videoFileName,frameRate,playbackSpeedRatio,videoFormat,frameSize,tile);

    if~isempty(rawErrors)

        entrySetIterator=rawErrors.entrySet.iterator;
        while(entrySetIterator.hasNext()==true)
            entry=entrySetIterator.next();
            causeID=entry.getKey;
            causeText=entry.getValue;
            causeException=MException(causeID,causeText);
            baseException=baseException.addCause(causeException);
        end

        throw(baseException);
    end

end

function inputs=parseInputs(nameValuePairs)

    persistent p;

    [acceptedVideoFormat,~]=simmechanics.gui.internal.getVideoFormats;
    acceptedVideoFormat=lower(acceptedVideoFormat);

    if isempty(p)
        p=inputParser;

        addParameter(p,'VideoFormat','',@(x)any(validatestring(x,acceptedVideoFormat)));

        addParameter(p,'FrameSize','');

        addParameter(p,'PlaybackSpeedRatio','');

        addParameter(p,'FrameRate','');

        addParameter(p,'Tile','');

    end


    parse(p,nameValuePairs{:});

    if~ismember('VideoFormat',p.UsingDefaults)

        inputs.VideoFormat=validatestring(p.Results.VideoFormat,acceptedVideoFormat);
    else
        inputs.VideoFormat='';
    end



    if~ismember('FrameSize',p.UsingDefaults)
        if~isnumeric(p.Results.FrameSize)
            if ischar(p.Results.FrameSize)&&strcmpi('auto',strtrim(p.Results.FrameSize))
                inputs.FrameSize='auto';
            else
                inputs.FrameSize='Invalid';
            end
        else



            roundedSize=round(p.Results.FrameSize);
            if isequal(p.Results.FrameSize-roundedSize,[0,0])
                inputs.FrameSize=mat2str(roundedSize);
            else
                inputs.FrameSize=mat2str(p.Results.FrameSize);
            end
        end
    else
        inputs.FrameSize='';
    end



    if~ismember('PlaybackSpeedRatio',p.UsingDefaults)
        if~isnumeric(p.Results.PlaybackSpeedRatio)
            inputs.PlaybackSpeedRatio='Invalid';
        else
            inputs.PlaybackSpeedRatio=mat2str(p.Results.PlaybackSpeedRatio);
        end
    else
        inputs.PlaybackSpeedRatio='';
    end



    if~ismember('FrameRate',p.UsingDefaults)
        if~isnumeric(p.Results.FrameRate)
            inputs.FrameRate='Invalid';
        else
            inputs.FrameRate=mat2str(p.Results.FrameRate);
        end
    else
        inputs.FrameRate='';
    end



    if~ismember('Tile',p.UsingDefaults)
        if~isnumeric(p.Results.Tile)
            inputs.Tile='Invalid';
        else








            inputs.Tile=mat2str(cast(p.Results.Tile,'double')-1);
        end
    else
        inputs.Tile='';
    end

end
