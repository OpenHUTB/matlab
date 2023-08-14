function createElement(configname,compname,elementType,elementId,varargin)





    p=parseInput(elementType,elementId,varargin{:});

    if isempty(p)

        return;
    end

    model=dig.config.Model.getOrCreate(configname);
    editor=model.openEditor();

    comp=editor.getComponent(compname);
    if~isempty(comp)

        existingWidget=comp.getWidget(elementId);
        if isempty(existingWidget)
            try
                filename=p.Results.File;
                [~,~,ext]=fileparts(filename);
                if isempty(ext)||~strcmpi(ext,'.json')
                    filename=[filename,'.json'];
                end

                file=fullfile(comp.Path,'resources','json',filename);
                fid=fopen(file,'w');
                if fid~=-1
                    oc=onCleanup(@()fclose(fid));

                    text=getTabJson(elementId,p.Results.Title);

                    fprintf(fid,text);
                    clear oc;
                    model.closeEditor();
                    c=dig.Configuration.get(configname);
                    if~isempty(c)
                        c.reload();
                    end

                    edit(file);
                else

                    throw(MException(message('dig:config:resources:FileOpenError',file,'write')));
                end
            catch ME
                model.closeEditor();
                rethrow(ME);
            end
        else
            model.closeEditor();
            throw(MException(message('dig:config:resources:WidgetAlreadyExists',elementId,compname,existingWidget.File.Path)));
        end
    else
        model.closeEditor();
        throw(MException(message('dig:config:resources:NoSuchComponent',compname)));
    end
end

function p=parseInput(type,id,varargin)
    p=[];

    if strcmp(type,'Tab')
        p=inputParser();
        p.addParameter('Title','');
        p.addParameter('File',strcat(id,'.json'));
        p.parse(varargin{:});
    end
end

function json=getTabJson(id,title)
    file=struct;
    file.version='1.0';
    file.entries={
    struct('type','Tab','id',id,'title',title);
    };
    json=jsonencode(file,'PrettyPrint',true);
end