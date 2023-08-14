function[sys,compilationErrors]=multibodyToSystem(mb,modelName)



















































    compilationErrors=[];

    systemId=sm.mli.internal.MlId(modelName);
    try
        sys=sm.mli.internal.multibodyToSystem_implementation(mb,systemId);
    catch exc
        sys=sm.mli.internal.System;
        compilationErrors=exc;
    end


end


