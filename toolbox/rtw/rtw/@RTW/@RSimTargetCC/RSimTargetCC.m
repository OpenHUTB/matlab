function h=RSimTargetCC(varargin)






    if nargin>0
        h=[];
        DAStudio.error('RTW:configSet:constructorNotFound','RSim.RSimTargetCC');
    end

    h=RTW.RSimTargetCC;
    set(h,'IsERTTarget','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'CompOptLevelCompliant','on');
    set(h,'ParMdlRefBuildCompliant','on');
    set(h,'MatFileLogging','on');
    set(h,'ConcurrentExecutionCompliant','on');

    registerPropList(h,'NoDuplicate','All',[]);

