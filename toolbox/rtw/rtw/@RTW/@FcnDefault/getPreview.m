function signature=getPreview(hSrc)



    signature='';%#ok
    functionName=[get_param(hSrc.ModelHandle,'Name'),'_step'];

    signature=[functionName,' ( )'];

