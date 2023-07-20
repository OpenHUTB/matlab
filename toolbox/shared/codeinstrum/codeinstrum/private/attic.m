function varargout=attic(method,varargin)










    mlock();
    persistent USERDATA

    [USERDATA,varargout{1:nargout}]=feval(method,USERDATA,varargin{1:end});

end


function uData=resetBinMode(uData,modeName)
    uData.(modeName)=false;
end


function[uData,ret]=toggleBinMode(uData,modeName)%#ok<DEFNU>
    [uData,ret]=getBinMode(uData,modeName);
    ret=~ret;
    uData=setBinMode(uData,modeName,ret);
end


function uData=setBinMode(uData,modeName,mode)
    if nargin<3
        mode=true;
    end
    uData.(modeName)=mode;
end


function[uData,ret]=getBinMode(uData,modeName)
    if isfield(uData,modeName)
        ret=uData.(modeName);
    else

        uData=resetBinMode(uData,modeName);
        [uData,ret]=getBinMode(uData,modeName);
    end
end


function[uData,ret]=hasBinMode(uData,modeName)%#ok<DEFNU>
    if isfield(uData,modeName)
        ret=true;
    else
        ret=false;
    end
end


function uData=resetData(uData,varargin)%#ok<DEFNU>

    switch nargin
    case 1
        clear('uData');
        uData=[];
    case 2
        fieldName=varargin{1};
        if isfield(uData,fieldName)
            uData.(fieldName)=[];
            uData=rmfield(uData,fieldName);
        end
    otherwise

    end
end


function[uData,ret]=atticData(uData,varargin)%#ok<DEFNU>

    ret=[];
    switch nargin
    case 1
        ret=uData;
    case 2
        fieldName=varargin{1};
        if isfield(uData,fieldName)
            ret=uData.(fieldName);
        end
    case 3
        fieldName=varargin{1};
        ret=false;
        if isvarname(fieldName)
            uData.(fieldName)=varargin{2};
            ret=true;
        end
    otherwise

    end

end

