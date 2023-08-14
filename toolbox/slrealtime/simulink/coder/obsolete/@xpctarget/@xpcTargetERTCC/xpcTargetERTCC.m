function h=xpcTargetERTCC(varargin)







    if nargin>0
        h=[];
        error(message('slrealtime:obsolete:xpcTargetERTCC:xpcTargetERTCC:invalidArgs'));
    end

    h=xpctarget.xpcTargetERTCC;
    set(h,'IsERTTarget','on');

    set(h,'CombineOutputUpdateFcns','off');
    set(h,'ERTCustomFileBanners','off');
    set(h,'GenerateSampleERTMain','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'ParMdlRefBuildCompliant',true);
    set(h,'ConcurrentExecutionCompliant','on');



    registerPropList(h,'NoDuplicate','All',[]);
