function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxokaQAQVPCeFmYnaMb+RRSmySuRecOWMsADSFh+n7UpfFSWYiBXiOlSKN'...
        ,'HyEgTMqSf0ndU/goTEIWlIAkfcfb1FhRuvKSm/BKqdpxyH5Pmi9I9BsXmIS2'...
        ,'a5znepRzdp9NtCMvcpXSGF7aWDznluvyqX8Io2Ko5NLo2NLf/iU2Zm4zcVkU'...
        ,'kEj3qkQbyBbBCjyzOclGGiy32Q5K+1smtMLqWxCtxcaTG7x1OViL5xYOASPD'...
        ,'arA4qj99LtNRdtF9x5BFPVKYyVh5ILpjfuX1KDrnPEF0LGQxPEgL83aAfVR+'...
        ,'nESxOYl2CM80Kak='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end