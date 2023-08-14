function comp=makeReference(this,refModel,varargin)





    comp=this;
    if nargin<3
        createNew=false;
        archFile=true;
    else
        if strcmpi(varargin{1},'CreateNew')
            createNew=varargin{2};
            if nargin>4&&strcmpi(varargin{3},'IsArchitecture')
                archFile=varargin{4};
            else
                archFile=true;
            end
        elseif strcmpi(varargin{1},'IsArchitecture')
            archFile=varargin{2};
            if nargin>4&&strcmpi(varargin{3},'CreateNew')
                createNew=varargin{4};
            else
                createNew=false;
            end
        end
    end

    try
        if createNew
            if archFile
                this.saveAsModel(refModel);
            else
                this.createSimulinkBehavior(refModel);
            end
        else
            this.linkToModel(refModel);
        end
    catch ex
        msgObj=message('SystemArchitecture:API:LinkModelError',ex.message);
        exception=MException('SystemArchitecture:API:LinkModelError',msgObj.getString);
        throw(exception);
    end
