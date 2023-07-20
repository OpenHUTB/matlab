function setupListener(obj,cs)





    if isa(cs,'Simulink.ConfigComponent')&&...
        ~isobject(cs)
        cs.setupListener;
        fcn=@obj.callback;
        m=findprop(cs,'ChangedProp');
        obj.fPropListener{end+1}=handle.listener(cs,m,'PropertyPostSet',fcn);


        m=findprop(cs,'DisabledProps');
        obj.fPropListener{end+1}=handle.listener(cs,m,'PropertyPostSet',...
        @(~,~)obj.refresh);
    end

    for i=1:length(cs.Components)
        cc=cs.Components(i);
        obj.setupListener(cc);
    end


