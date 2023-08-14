function[fileName,uuid,ext]=resolve(varargin)




    source=varargin{1};

    if any(source=='|')
        [fileName,remainder]=strtok(source,'|');
        uuid=remainder(2:end);
    elseif rmifa.isFaultInfoObj(source)
        faultInfoObj=rmifa.resolveObjInFaultInfo(source);
        fileName=faultInfoObj.getTopModelName();
        uuid=[rmifa.itemIDPref,faultInfoObj.Uuid];
    else
        fileName=source;
        if nargin>1&&ischar(varargin{2})
            uuid=varargin{2};
        else
            uuid='';
        end
    end

    if nargout==3


        [~,~,ext]=fileparts(fileName);
    else
        ext='';
    end
end


