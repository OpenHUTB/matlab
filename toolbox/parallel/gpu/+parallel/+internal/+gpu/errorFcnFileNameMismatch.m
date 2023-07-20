function errorFcnFileNameMismatch(filename,ftree,errorMechanism)




    fname=strings(Fname(ftree));
    fname=fname{1};
    setCurrentContextForErrorMechanism(errorMechanism,filename);
    setNodeForErrorMechanism(errorMechanism,root(ftree));
    encounteredError(errorMechanism,message('parallel:gpu:compiler:LanguageNameMismatch',fname,filename));
