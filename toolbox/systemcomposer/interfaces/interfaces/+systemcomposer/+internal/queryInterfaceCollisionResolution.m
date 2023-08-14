function collisionResolutionOption=queryInterfaceCollisionResolution(srcPIC,dstPIC)



    srcContext=srcPIC.getStorageContext();
    dstContext=dstPIC.getStorageContext();

    if(srcContext==systemcomposer.architecture.model.interface.Context.MODEL)
        src=[srcPIC.getStorageSource(),'.slx'];
    else
        src=[srcPIC.getStorageSource(),'.sldd'];
    end

    if(dstContext==systemcomposer.architecture.model.interface.Context.MODEL)
        dst=[dstPIC.getStorageSource(),'.slx'];
    else
        dst=[dstPIC.getStorageSource(),'.sldd'];
    end

    srcPINames=srcPIC.getPortInterfaceNamesInClosure();
    dstPINames=dstPIC.getPortInterfaceNamesInClosure();
    collisions=intersect(srcPINames,dstPINames,'stable');

    collisionResolutionOption=interfaceConflictResolutionApp(src,dst,collisions);
end
