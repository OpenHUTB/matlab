function h=xpcTargetCC(varargin)







    if nargin>0
        h=[];
        error(message('slrealtime:obsolete:xpcTargetCC:xpcTargetCC:invalidArgs'));
    end

    h=xpctarget.xpcTargetCC;
    set(h,'IsERTTarget','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'MatFileLogging','on');
    set(h,'ParMdlRefBuildCompliant',true);
    set(h,'ConcurrentExecutionCompliant','on');



    registerPropList(h,'NoDuplicate','All',[]);
