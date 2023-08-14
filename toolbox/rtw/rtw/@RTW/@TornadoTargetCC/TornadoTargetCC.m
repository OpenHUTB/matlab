function h=TornadoTargetCC(varargin)






    if nargin>0
        h=[];
        DAStudio.error('RTW:configSet:constructorNotFound',...
        'RTW.TornadoTargetCC');
    end

    h=RTW.TornadoTargetCC;
    set(h,'ModelReferenceCompliant','on');
    set(h,'ParMdlRefBuildCompliant','on');
    set(h,'IsERTTarget','off');
    setPropEnabled(h,'GRTInterface','off');

    registerPropList(h,'NoDuplicate','All',[]);
