function fileID=initializeProfilingFile(isProfilingEnabled,networkName,numLayers)













%#codegen
    coder.inline('always');
    coder.allowpcode('plain');

    coder.internal.prefer_const(isProfilingEnabled,networkName,numLayers);

    if coder.const(isProfilingEnabled)
        fileID=fopen("profileData.txt","a");

        coder.internal.assert(fileID~=-1,"dlcoder_spkg:cnncodegen:DLCoderInternalError");
        fprintf(fileID,"Network : %s\n",networkName);
        fprintf(fileID,"NumLayers : %d\n",int32(numLayers));
        fprintf(fileID,"Function Call : %s\n","predict");


    else

        fileID=-1;
    end

end
