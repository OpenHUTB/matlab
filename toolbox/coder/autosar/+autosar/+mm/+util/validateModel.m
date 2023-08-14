function validateModel(modelName,varargin)



    if nargin>0
        modelName=convertStringsToChars(modelName);
    end

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if nargin==2
        phase=varargin{1};
    else
        phase='interactive';
    end

    modelHandle=get_param(modelName,'Handle');







    msgStream=autosar.api.Utils.initMessageStreamHandler();
    if~autosar.utils.Debug.showStackTrace()
        disableQueuingObj=msgStream.enableQueuing();%#ok<*NASGU>
        flushMsgsObj=onCleanup(@()msgStream.clear());
    end


    v=autosar.validation.Validator();

    try
        if any(strcmp(phase,{'interactive'}))
            v.verify(modelHandle);
        else
            switch phase
            case 'init'
                v.verify(modelHandle,'ValidationPhase','Initial');
            case 'postprop'
                v.verify(modelHandle,'ValidationPhase','PostProp');
            case 'finalValidation'
                v.verify(modelHandle,'ValidationPhase','Final');
            otherwise
                assert(false,'Did not recognize validation phase %s',phase);
            end
        end
    catch ME
        autosar.validation.Validator.logError(ME.identifier,ME);
    end
    try
        if~autosar.utils.Debug.showStackTrace()
            msgStream.flush('autosarstandard:validation:ValidationError');
            disableQueuingObj.delete();
        end
    catch ME
        if~autosar.utils.Debug.showStackTrace()

            throwAsCaller(ME);
        else
            rethrow(ME);
        end
    end



