function destroyLibForMdlRefCopy(obj)




    if~isempty(obj.LibForModelRefCopy)
        mdlfileName=get_param(obj.LibForModelRefCopy,'filename');
        Sldv.close_system(mdlfileName,0);
        delete(mdlfileName);
        obj.LibForModelRefCopy='';
    end
end
