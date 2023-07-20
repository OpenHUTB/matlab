function closeProfilingFile(fileID)







%#codegen
    coder.inline('always');
    coder.allowpcode('plain');


    coder.internal.assert(fileID~=-1,'dlcoder_spkg:cnncodegen:DLCoderInternalError');
    fclose(fileID);

end