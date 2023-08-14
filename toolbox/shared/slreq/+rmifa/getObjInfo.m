function[navcmd,dispStr,modelFileName,guidstr]=getObjInfo(obj,pathReferenceOption)




    if nargin<2
        pathReferenceOption=rmipref('ModelPathReference');
    end

    [fPath,guidstr]=rmifa.resolve(obj);
    dispStr=rmifa.itemID(fPath,guidstr,false);

    if strcmp(pathReferenceOption,'absolute')
        modelFileName=fPath;
    else
        [~,dName,dExt]=fileparts(fPath);
        modelFileName=[dName,dExt];
    end

    navcmd=['rmiobjnavigate(''',modelFileName,''',''',guidstr,''');'];
end
