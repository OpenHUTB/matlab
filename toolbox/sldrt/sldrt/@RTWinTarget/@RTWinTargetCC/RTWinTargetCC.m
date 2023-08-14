function h=RTWinTargetCC(varargin)





    if nargin>0
        h=[];
        DAStudio.error('RTW:configSet:constructorNotFound',...
        'RTWinTarget.RTWinTargetCC');
    end

    h=RTWinTarget.RTWinTargetCC;
    set(h,'IsERTTarget','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'CompOptLevelCompliant','on');

    registerPropList(h,'NoDuplicate','All',[]);
