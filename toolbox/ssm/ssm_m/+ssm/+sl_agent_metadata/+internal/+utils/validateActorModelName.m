function validateActorModelName(ModelName)






    if isempty(ModelName);return;end

    fullFileName=which(ModelName);
    fileExist=exist(fullFileName,'file');

    [~,fname,~]=fileparts(ModelName);


    if fileExist~=4&&fileExist~=2
        errMsg=message('ssm:actorMetadata:InputModelInvalid');
        error(errMsg);
    end


    if fileExist==2


        try
            isSystemObject=isa(eval(fname),'matlab.System');
        catch ME
            if(strcmp(ME.identifier,'MATLAB:scriptNotAFunction'))
                msg='Model file is not a valid system object';
                causeException=MException('ssm:actorMetadata:InputModelInvalidSystemObject',msg);
                ME=addCause(causeException,ME);
            end
            throw(ME)
        end


        if~isSystemObject
            errMsg=message('ssm:actorMetadata:InputModelInvalidSystemObject');
            error(errMsg);
        end
    end
end


