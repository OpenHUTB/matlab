function this=document(fullDocumentName,varargin)





    this=Simulink.document;

    [filepath,search]=...
    Simulink.document.parseFileURL(fullDocumentName);
    if~isempty(filepath)
        fullDocumentName=filepath;
    end

    if exist(fullDocumentName,'file')
        this.documentName=fullDocumentName;
        if nargin>1
            this.displayLabel=varargin{1};
        end
        dirInfo=loc_dir(this.documentName);
        if~isempty(dirInfo)
            this.Modified=dirInfo.date;
            this.Size=dirInfo.bytes;
        end
        if nargin>2
            this.generateBacklink=varargin{2};
        end
        this.SearchString=search;
    else
        DAStudio.error('Simulink:tools:CodeBrowserInvalidFileName',fullDocumentName);
    end

    function dirInfo=loc_dir(fname)
        dirInfo=dir(fname);
        if isempty(dirInfo)
            [p,f,e]=fileparts(fname);
            pInfo=dir(p);
            if~isempty(pInfo)
                [tf,loc]=ismember([f,e],{pInfo.name});
                if tf
                    dirInfo=pInfo(loc);
                end
            end
        end