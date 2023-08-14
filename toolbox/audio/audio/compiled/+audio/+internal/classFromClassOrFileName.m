function[className,errid,cdto]=classFromClassOrFileName(classOrFileString)

















    [className,errid,cdto,msgargs]=helper(classOrFileString);

    if~isempty(errid)&&nargout<2
        me=MException(errid,'%s',getString(message(msgargs{:})));
        throwAsCaller(me);
    end

end

function[className,errid,cdto,msgargs]=helper(classOrFileString)

    className=classOrFileString;
    errid='';
    cdto='';
    msgargs={};

    if exist(classOrFileString,'class')
        return
    end


    if exist(classOrFileString,'file')~=2
        errid='audio:plugin:ClassOrFileNotFound';
        msgargs={errid,classOrFileString};
        return
    end




    [~,name,ext]=fileparts(classOrFileString);
    if~regexp([name,ext],'^[a-z_A-Z]\w+\(\.[mp])?$')
        errid='audio:plugin:NotAClass';
        msgargs={errid};
        return
    end


    whichFromString=which(classOrFileString);
    if isempty(whichFromString)
        cdto=fileparts(classOrFileString);
        errid='audio:plugin:FileNotOnPath';
        msgargs={errid,classOrFileString,cdto};
        return
    end

    className=extractClassNameFromFilePath(whichFromString);


    if~exist(className,'class')
        errid='audio:plugin:NotAClass';
        msgargs={errid};
        return
    end


    whichFromClass=which(className);
    if~strcmp(whichFromString,whichFromClass)
        cdto=fileparts(whichFromString);
        errid='audio:plugin:ClassIsShadowed';
        msgargs={errid,classOrFileString,cdto};
        return
    end

end

function className=extractClassNameFromFilePath(fullFilePath)
    [path,className,~]=fileparts(fullFilePath);

    if ispc

        fs=[filesep,filesep];
    else
        fs=filesep;
    end
    pkgsuffix=regexp(path,['(',fs,'\+(\w+))*'],'match');
    if~isempty(pkgsuffix)
        pkgs=regexp(pkgsuffix{1},'\w+','match');
        className=strjoin([pkgs,className],'.');
    end
end