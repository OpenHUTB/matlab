function copyExample(configname,compname,examplefolder,varargin)





    force=false;
    if nargin==4
        force=varargin{1};
    end

    if exist(examplefolder,"dir")==7
        model=dig.config.Model.getOrCreate(configname);
        component=model.getComponent(compname);
        if~isempty(component)
            compfolder=component.Path;
            compfile=fullfile(compfolder,'resources',[configname,'.json']);
            if exist(compfile,"file")==2
                jsonfolder=fullfile(compfolder,'resources','json');
                if exist(jsonfolder,"dir")~=7
                    mkdir(jsonfolder);
                end
                [~,permissions]=fileattrib(jsonfolder);
                if permissions.UserWrite


                    files=findFilesToCopy(examplefolder,jsonfolder,force);





                    for ii=1:length(files)
                        if force
                            copyfile(files(ii).source,files(ii).dest,'f');
                        else
                            copyfile(files(ii).source,files(ii).dest);
                        end
                    end
                else
                    throw(MException(message('dig:config:resources:FileNotWritable',jsonfolder)));
                end
            else
                throw(MException(message('dig:config:resources:ComponentMissingAt',compfolder)));
            end
        else
            throw(MException(message('dig:config:resources:NoSuchComponent',compname)));
        end
    else
        throw(MException(message('dig:config:resources:InvalidExamplePath',examplefolder)));
    end
end

function files=findFilesToCopy(sourcefolder,destfolder,force)
    files=[];
    d=dir(fullfile(sourcefolder,'*.json'));
    numfiles=length(d);
    if numfiles>0
        sources=cell(1,numfiles);
        destinations=cell(1,numfiles);
        for ii=1:numfiles
            file=d(ii);
            srcfile=fullfile(file.folder,file.name);
            destfile=fullfile(destfolder,file.name);
            if exist(destfile,'file')==2
                if force
                    fileattrib(destfile,'+w','');
                    [~,attrib]=fileattrib(destfile);
                    if attrib.UserWrite
                        sources{ii}=srcfile;
                        destinations{ii}=destfile;
                    else
                        throw(MException(message('dig:config:resources:FileNotWritable',destfile)));
                    end
                else
                    throw(MException(message('dig:config:resources:FileNameExists',destfile)));
                end
            else
                sources{ii}=srcfile;
                destinations{ii}=destfile;
            end
        end

        files=struct('source',sources,'dest',destinations);
    end
end