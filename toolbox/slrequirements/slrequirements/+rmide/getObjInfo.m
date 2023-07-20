function[navcmd,dispStr,dictFileName,guidstr]=getObjInfo(obj,pathReferenceOption)




    if nargin<2
        pathReferenceOption=rmipref('ModelPathReference');
    end

    dispStr=rmide.getLabel(obj);

    [guidstr,fPath]=rmide.getGuid(obj);
    if strcmp(pathReferenceOption,'absolute')
        dictFileName=fPath;
    else
        [~,dName,dExt]=fileparts(fPath);
        dictFileName=[dName,dExt];
    end

    navcmd=['rmiobjnavigate(''',dictFileName,''',''',guidstr,''');'];
end
