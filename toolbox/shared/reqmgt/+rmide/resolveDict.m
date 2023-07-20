function fPath=resolveDict(dName,checkOnPathIfNotLoaded)




    if nargin<2
        checkOnPathIfNotLoaded=true;
    end


    if isempty(regexpi(dName,'\.sldd$'))
        dName=[dName,'.sldd'];
    end


    fPaths=Simulink.dd.getOpenDictionaryPaths(dName);

    if isempty(fPaths)
        fPath='';
    elseif length(fPaths)==1
        fPath=fPaths{1};
    else

        currentMeDict=rmide.getCurrent();
        matchedIdx=find(strcmp(fPaths,currentMeDict));
        if isempty(matchedIdx)
            fPath='';
        elseif length(matchedIdx)==1
            fPath=fPaths{matchedIdx};
        else
            warning('rmide.resolveDict(): %s',getString(message('Slvnv:rmide:SameNameDictionaries')));
            fPath='';
        end
    end

    if isempty(fPath)&&checkOnPathIfNotLoaded
        fPath=which(dName);
    end
end
