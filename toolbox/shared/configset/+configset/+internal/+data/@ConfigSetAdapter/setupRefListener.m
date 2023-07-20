function setupRefListener(obj)


    ref=obj.Source;
    while isa(ref,'Simulink.ConfigSetRef')
        m=findprop(ref,'SourceName');
        obj.fPropListener{end+1}=handle.listener(ref,m,'PropertyPostSet',...
        @(varargin)obj.resetAdapter());

        ref=ref.getRefObject(true);
    end


