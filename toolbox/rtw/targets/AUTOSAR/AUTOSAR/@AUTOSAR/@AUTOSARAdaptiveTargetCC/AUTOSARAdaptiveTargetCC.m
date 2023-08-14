function h=AUTOSARAdaptiveTargetCC(varargin)





    if nargin>0
        DAStudio.error('RTW:configSet:constructorNotFound',...
        'AUTOSAR.AUTOSARAdaptiveTargetCC');
    end
    h=AUTOSAR.AUTOSARAdaptiveTargetCC;
    set(h,'IsERTTarget','on');

    registerPropList(h,'NoDuplicate','All',[]);


    props=find(h.classhandle.properties,'accessflags.publicset',...
    'on','accessflags.publicget','on','visible','on');
    l=handle.listener(h,props,'PropertyPostSet',@propertyChanged);
    l.CallbackTarget=h;
    h.propListener=l;
end


