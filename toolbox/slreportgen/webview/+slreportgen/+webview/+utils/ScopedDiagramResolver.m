classdef ScopedDiagramResolver<handle
















    properties(SetAccess=private)
        UnresolvedNames={};
    end

    properties(Access=private)
        m_closeModel;
        m_restorePWD;
        m_index=0;
        m_size=0;
    end

    methods
        function h=ScopedDiagramResolver(names,varargin)
            p=inputParser();
            p.addParameter('RecurseFolder',false,@islogical);
            parse(p,varargin{:});
            results=p.Results;
            expandNames(h,names,results.RecurseFolder);
        end

        function delete(h)
            cleanup(h);
        end

        function dhid=next(h)
            dhid=[];
            if hasNext(h)
                cleanup(h);
                h.m_index=h.m_index+1;
                name=h.UnresolvedNames{h.m_index};
                dhid=resolve(h,name);
            end
        end

        function tf=hasNext(h)
            tf=((h.m_index>=0)&&(h.m_index<h.m_size));
        end
    end

    methods(Access=private)
        function dhid=resolve(h,name)
            diagramName=name;

            r=slroot();
            if isfile(name)

                listing=dir(name);
                [modelFolder,modelName,modelExt]=fileparts(fullfile(listing.folder,listing.name));
                diagramName=modelName;

                if isValidSlObject(r,modelName)

                    modelFullFile=fullfile(modelFolder,[modelName,modelExt]);
                    loadedFullFile=get_param(modelName,'FileName');
                    if~strcmpi(modelFullFile,loadedFullFile)
                        error(message('slreportgen_webview:webview:ModelFileShadowedByAnotherModelFile',...
                        modelFullFile,loadedFullFile));
                    end
                else

                    h.m_restorePWD=pwd();
                    cd(modelFolder);


                    h.m_closeModel=modelName;
                    load_system(modelName);
                end
            end

            hs=slreportgen.utils.HierarchyService;
            dhid=hs.getDiagramHID(diagramName);
        end

        function cleanup(h)
            if~isempty(h.m_restorePWD)
                cd(h.m_restorePWD);
                h.m_restorePWD=[];
            end

            if~isempty(h.m_closeModel)
                close_system(h.m_closeModel,0);
                h.m_closeModel=[];
            end
        end

        function expandNames(h,names,recurseFolder)
            if ischar(names)
                names=string(names);
            end

            nNames=numel(names);
            for i=1:nNames
                if iscell(names)
                    name=names{i};
                else
                    name=names(i);
                end

                if(~(exist(name,'file')==4)&&isfolder(name))

                    findArgs={name,'RecurseFolder',recurseFolder};
                    modelFiles=slreportgen.utils.findModelFiles(findArgs{:});
                    for modelFile=modelFiles
                        h.UnresolvedNames{end+1}=modelFile;
                    end

                elseif ischar(name)
                    h.UnresolvedNames{end+1}=string(name);

                else
                    h.UnresolvedNames{end+1}=name;
                end
            end

            h.m_size=numel(h.UnresolvedNames);
        end
    end
end
