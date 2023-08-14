function detachhdlcconfig(model)






    narginchk(1,1);
    mdlObj=bdroot(get_param(model,'Handle'));
    if strcmp(get_param(mdlObj,'BlockDiagramType'),'library')
        error(message('HDLShared:directemit:InvalidMDLObj'));
    end






    sobj=get_param(model,'Object');
    configSet=sobj.getActiveConfigSet;
    components=configSet.Components;
    for ii=1:numel(components)
        if ishandle(components(ii))&&isa(components(ii),'hdlcoderui.hdlcc')
            hdlcc=components(ii);
            hdlcc.removeCallbacks;
            configSet.detachComponent(hdlcc.Name);
        end
    end
end
