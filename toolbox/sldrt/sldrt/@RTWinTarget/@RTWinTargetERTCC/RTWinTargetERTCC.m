function h=RTWinTargetERTCC(varargin)





    if nargin>0
        h=[];
        DAStudio.error('RTW:configSet:constructorNotFound',...
        'RTWinTarget.RTWinTargetERTCC');
    end

    h=RTWinTarget.RTWinTargetERTCC;
    set(h,'ExtMode','on');
    set(h,'IsERTTarget','on');
    set(h,'ModelReferenceCompliant','on');
    set(h,'CompOptLevelCompliant','on');
    set(h,'GRTInterface','off');

    registerPropList(h,'NoDuplicate','All',[]);
