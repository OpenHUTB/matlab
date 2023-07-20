function destroyLibForStubCopy(obj)




    if~isempty(obj.LibForStubBlocks)
        mdlfileName=get_param(obj.LibForStubBlocks,'filename');
        Sldv.close_system(mdlfileName,0);



        delete(mdlfileName);
        obj.LibForStubBlocks='';
    end
end
