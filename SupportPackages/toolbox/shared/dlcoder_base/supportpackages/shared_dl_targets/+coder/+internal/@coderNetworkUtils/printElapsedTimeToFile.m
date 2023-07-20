function printElapsedTimeToFile(isProfilingEnabled,timer,fileID,layerIndex,layerName)












%#codegen
    coder.inline('always');
    coder.allowpcode('plain');

    coder.internal.prefer_const(isProfilingEnabled,layerIndex,layerName);
    if coder.const(isProfilingEnabled)
        elapsedTime=toc(timer);
        fprintf(fileID,"\tLayer Id : %d\n",int32(layerIndex));
        fprintf(fileID,"\tLayer Name : %s\n",layerName);
        fprintf(fileID,"\tElapsed Time : %f ms\n\n",elapsedTime*1000);
    end
end
