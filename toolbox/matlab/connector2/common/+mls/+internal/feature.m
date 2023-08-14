function varargout=feature(name,newValue)



    if(nargin==0)
        error('Please specify a feature');
    end

    if(nargin==1)
        newValue='status';
    end

    persistent FEATURE_STRUCT


    try
        value=mls.internal.feature.(name)(newValue);
    catch ex
        error('An error was encountered while trying to set the feature:\n%s',ex.getReport);
    end

    if isempty(FEATURE_STRUCT)
        FEATURE_STRUCT=struct(name,value);

        mlock;
    else
        FEATURE_STRUCT.(name)=value;
    end

    if isfield(FEATURE_STRUCT,name)
        currentValue=FEATURE_STRUCT.(name);
    else
        error('An unknown feature was specified: %s',name);
    end

    if nargout==1
        varargout{1}=currentValue;
    end

end
