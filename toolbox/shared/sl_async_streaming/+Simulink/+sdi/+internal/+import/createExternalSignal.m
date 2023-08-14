function[signalID,fileName]=createExternalSignal(runID,varargin)

























    signalID=0;
    fileName='';

    if runID~=0

        p=inputParser;
        p.addParameter('FileName','',@(x)validate_parameter(x));
        p.addParameter('FileExt','',@(x)validate_parameter(x));
        p.addParameter('SignalName','',@(x)validate_parameter(x));
        p.addParameter('MetaData',[],@(x)isstruct(x));
        p.addParameter('ReadOnly',false);
        p.parse(varargin{:});
        params=p.Results;


        fileName=params.FileName;

        if isempty(fileName)

            ext=params.FileExt;
            if isempty(ext)
                ext='tmp';
            end
            fileName=strcat('tempfile.',ext);
            fileName=generateFileNameInTemp(fileName);
        else
            if exist(fileName,'file')==2
                if~params.ReadOnly

                    fileName=generateFileName(fileName);
                end
            else
                if params.ReadOnly
                    fileName='';
                    return;
                end
                [filepath,~,~]=fileparts(fileName);
                if isempty(filepath)
                    fileName=generateFileNameInTemp(fileName);
                else


                end
            end
        end


        sigName=params.SignalName;
        if isempty(sigName)
            sigName=fileName;
        end


        repo=sdi.Repository(1);
        Simulink.HMI.synchronouslyFlushWorkerQueue(repo);
        run=Simulink.sdi.Run(repo,runID);
        sig=run.createSignal('Name',sigName,'BlockPath',sigName);
        signalID=sig.ID;


        metaData=params.MetaData;
        addMetadataToSignal(signalID,fileName,metaData);
    end
end


function ret=validate_parameter(x)
    ret=ischar(x)||(isstring(x)&&isscalar(x));
end

function newFullName=generateFileName(fileName)
    newFullName=fileName;
    [filepath,name,ext]=fileparts(fileName);
    index=1;
    while exist(newFullName,'file')==2
        newName=strcat(name,'_',num2str(index));
        newFullName=fullfile(filepath,strcat(newName,ext));
        index=index+1;
    end
end

function folderName=createTempFolder()
    rep=sdi.Repository(true);
    folderName=strcat(tempdir,num2str(rep.getInstanceID));
    if exist(folderName,'file')~=7
        status=mkdir(folderName);
        if status==0
            return;
        end
    end
end


function newFullName=generateFileNameInTemp(fileName)
    folderName=createTempFolder();
    if~isempty(folderName)
        newFullName=fullfile(folderName,fileName);
        newFullName=generateFileName(newFullName);
    end
end

function addMetadataToSignal(sigID,fileName,metaData)
    rep=sdi.Repository(true);
    rep.setSignalMetaData(sigID,'FileName',fileName);
    if~isempty(metaData)
        fields=fieldnames(metaData);
        for i=1:numel(fields)
            rep.setSignalMetaData(sigID,fields{i},metaData.(fields{i}));
        end
    end
end