function out=hasSharedDictionaryWithCoderDictionary(model)












    import coder.internal.CoderDataStaticAPI.*;

    out=false;
    dd=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(model,'Handle'));
    if~isempty(dd)
        out=migratedToCoderDictionary(dd);
    end
end
