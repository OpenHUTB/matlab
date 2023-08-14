classdef Navigator<lutdesigner.service.RemotableObject


    properties(Hidden)
        UIGetFileHandler=@()uigetfile(...
        {'*.slx;*.mdl',getString(message('lutdesigner:messages:OpenModelSelectorModelTypeLabel'))},...
        getString(message('lutdesigner:messages:OpenModelDialogTitle')));
    end

    properties(SetAccess=private)
LookupTableFinder
    end

    methods
        function this=Navigator(lookupTableFinder)
            this.LookupTableFinder=lookupTableFinder;
        end

        function accessDesc=loadNewAccessThroughFileExplorer(this)
            import lutdesigner.access.Access
            accessDesc=Access.createDescArray([0,1]);
            [file,path]=this.UIGetFileHandler();
            if~isequal(file,0)
                load_system(fullfile(path,file));
                [~,model,~]=fileparts(file);
                accessDesc=Access.createDesc('model',model);
            end
        end

        function accessDescs=searchAvailableAccessByPath(this,path)
            import lutdesigner.access.Access
            import lutdesigner.access.LookupTableBlock
            import lutdesigner.access.ModelBlock

            accessDescs=Access.createDescArray([0,1]);

            path=string(regexprep(path,'\s',' '));
            delimiterIndices=strfind(path,regexpPattern('[^/]/([^/]|$)'))+1;

            if isempty(delimiterIndices)
                if strlength(path)==0||isvarname(path)
                    models=sort(find_system('SearchDepth','0'));
                    models(cellfun(@(model)isLibrary(get_param(model,'Object'))||~startsWith(model,path),models))=[];
                    accessDescs=cellfun(@(model)Access.createDesc('model',model),models);
                end
                return;
            end

            parent=extractBefore(path,delimiterIndices(end));
            try
                parent=regexprep(getfullname(parent),'\n',' ');
            catch
                return;
            end
            name=regexprep(extractAfter(path,delimiterIndices(end)),'//','/')+".*";

            parentAccess=Access.fromSimulinkComponent(parent);
            accessDescs=lutdesigner.access.internal.getLookupTableControlAccessDescs(parentAccess);
            accessDescs=accessDescs(arrayfun(@(a)endsWith(a.path,regexpPattern("/"+name)),accessDescs));

            findSystemOptions={
            'FollowLinks','on',...
            'SearchDepth','1',...
            'RegExp','on',...
            'Name',"^"+name
            };
            subsystems=setdiff(regexprep(find_system(parent,'LookUnderMasks','all',findSystemOptions{:},'BlockType','SubSystem'),'\n',' '),parent);
            lutctrlsystems=setdiff(this.LookupTableFinder.findLookupTableControlSystems(parent,findSystemOptions{:}),parent);
            lutblocks=setdiff(this.LookupTableFinder.findLookupTableBlocks(parent,findSystemOptions{:}),parent);
            lutctrlsystems=setdiff(lutctrlsystems,lutblocks);
            subsystems=setdiff(subsystems,[lutctrlsystems;lutblocks]);
            mdlblocks=setdiff(regexprep(find_system(parent,findSystemOptions{:},'BlockType','ModelReference'),'\n',' '),parent);

            accessDescs=[
accessDescs
            cellfun(@(p)Access.fromSimulinkComponent(p).toDesc(),subsystems)
            cellfun(@(p)Access.fromSimulinkComponent(p).toDesc(),lutctrlsystems)
            cellfun(@(p)LookupTableBlock(p).toDesc(),lutblocks)
            cellfun(@(p)ModelBlock(p).toDesc(),mdlblocks)
            ];
            accessDescs=accessDescs(:);
        end
    end
end

