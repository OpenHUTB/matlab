function hMdl=getModelHandle(cbinfo)






    hMdl=[];
    mdl=cbinfo.model();
    if isscalar(mdl)&&isa(mdl,'Simulink.BlockDiagram')&&~isempty(mdl.Handle)
        hMdl=bdroot(mdl.Handle);
    end

end