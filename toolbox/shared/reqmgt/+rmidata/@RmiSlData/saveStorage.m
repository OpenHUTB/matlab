function storagePath=saveStorage(this,modelH,varargin)
    if~isempty(varargin)
        if ischar(varargin{1})

            storagePath=varargin{1};
            this.statusMap(modelH)=true;
        elseif varargin{1}

            storagePath=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
            this.statusMap(modelH)=true;
        elseif~this.statusMap(modelH)


            storagePath='';
            return;
        else


            storagePath=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
        end
    else
        storagePath=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
        prevFileName=get_param(modelH,'PreviousFileName');
        if~isempty(prevFileName)&&~strcmp(prevFileName,get_param(modelH,'FileName'))


            this.statusMap(modelH)=true;

            if exist(storagePath,'file')==2
                reply=questdlg({...
                getString(message('Slvnv:rmidata:RmiSlData:FileExists',storagePath)),...
                getString(message('Slvnv:rmidata:RmiSlData:OverwriteWithCurrent',get_param(modelH,'Name'))),...
                getString(message('Slvnv:rmidata:RmiSlData:YouCanCancelAndBackup'))},...
                getString(message('Slvnv:rmidata:RmiSlData:RmiDataFileExists')),...
                getString(message('Slvnv:rmidata:RmiSlData:Overwrite')),...
                getString(message('Slvnv:rmidata:RmiSlData:Cancel')),...
                getString(message('Slvnv:rmidata:RmiSlData:Overwrite')));
                if isempty(reply)||strcmp(reply,getString(message('Slvnv:rmidata:RmiSlData:Cancel')))
                    ME=MException(message('Slvnv:rmidata:RmiSlData:CouldNotOverwrite',storagePath));
                    throw(ME);
                end
            end
        end
    end


    if this.statusMap(modelH)
        this.writeToStorage(modelH,storagePath);
    end
end
