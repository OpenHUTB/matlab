function h=RaccelTargetCC(varargin)






    if nargin>0
        h=[];
        DAStudio.error('RTW:configSet:constructorNotFound','Simulink.RaccelTargetCC');
    end

    h=Simulink.RaccelTargetCC;
    set(h,'IsERTTarget','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'ParMdlRefBuildCompliant','on');
    set(h,'MatFileLogging','on');
    set(h,'ConcurrentExecutionCompliant','on');

    registerPropList(h,'NoDuplicate','All',[]);

