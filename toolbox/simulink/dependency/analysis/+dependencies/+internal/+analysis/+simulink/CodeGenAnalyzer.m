classdef CodeGenAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant,Access=private)
        RTWTargetParameters={
'CustomInclude'
'CustomSource'
'CustomLibrary'
'CustomSourceCode'
'CustomHeaderCode'
        }
        SFSimTargetParameters={
'SimUserIncludeDirs'
'SimUserSources'
'SimUserLibraries'
'SimCustomSourceCode'
'SimCustomHeaderCode'
        }
        StateflowTargetParameters={
'userIncludeDirs'
'userSources'
'userLibraries'
'customCode'
        }
        RTWExtraFileParameters={
'Array//CustomCommentsFcn'
'Array//ERTSrcFileBannerTemplate'
'Array//ERTHdrFileBannerTemplate'
'Array//ERTDataSrcFileTemplate'
'Array//ERTDataHdrFileTemplate'
'Array//ERTCustomFileTemplate'
'Array//DefineNamingFcn'
'Array//ParamNamingFcn'
'Array//SignalNamingFcn'
'PostCodeGenCommand'
'SystemTargetFile'
'MakeCommand'
'Array//TargetFunctionLibrary'
'Array//CodeReplacementLibrary'
        }
        RTWEmbeddedCoderDictionaryParameters={
'EmbeddedCoderDictionary'
        }

        DefaultSystemTargetFile="grt.tlc";
        DefaultMakeCommand="make_rtw";
    end

    properties(Constant,Hidden)

        TLCFileMap=dependencies.internal.util.Reference;
    end

    methods

        function this=CodeGenAnalyzer()
            this.addConfigQueries('Simulink.RTWCC',this.RTWTargetParameters);
            this.addConfigQueries('Simulink.SFSimCC',this.SFSimTargetParameters);
            this.addConfigQueries('Simulink.RTWCC',this.RTWExtraFileParameters);
            this.addConfigQueries('Simulink.RTWCC',this.RTWEmbeddedCoderDictionaryParameters);
            this.addStateflowQueries(this.StateflowTargetParameters);
        end

        function deps=analyzeMatches(this,handler,node,matches)


            emptyCustomHeaderMatches=struct('Value',{{}},'Configset',{{}});


            ERTMatches=[
            matches.ERTSrcFileBannerTemplate,...
            matches.ERTHdrFileBannerTemplate,...
            matches.ERTDataSrcFileTemplate,...
            matches.ERTDataHdrFileTemplate,...
            matches.ERTCustomFileTemplate];

            deps=[
            i_analyzeTargets(...
            handler,node,...
            matches.CustomInclude,...
            matches.CustomSource,...
            matches.CustomLibrary,...
            matches.CustomSourceCode,...
            matches.CustomHeaderCode,...
            'SimulinkCoder'),...
            i_analyzeTargets(...
            handler,node,...
            matches.SimUserIncludeDirs,...
            matches.SimUserSources,...
            matches.SimUserLibraries,...
            matches.SimCustomSourceCode,...
            matches.SimCustomHeaderCode,...
            'SimulationTarget'),...
            i_analyzeTargets(...
            handler,node,...
            matches.userIncludeDirs,...
            matches.userSources,...
            matches.userLibraries,...
            matches.customCode,...
            emptyCustomHeaderMatches,...
            'StateflowTarget'),...
            i_analyzeExtraFiles(handler,node,matches.CustomCommentsFcn,'Comments',[".m",".tlc"]),...
            i_analyzeExtraFiles(handler,node,ERTMatches,'Templates',string.empty)...
            ,i_analyzeExtraFiles(handler,node,matches.DefineNamingFcn,'DefineNamingFcn',[".p",".m"])...
            ,i_analyzeExtraFiles(handler,node,matches.ParamNamingFcn,'ParamNamingFcn',[".p",".m"])...
            ,i_analyzeExtraFiles(handler,node,matches.SignalNamingFcn,'SignalNamingFcn',[".p",".m"])...
            ,i_analyzeExtraFiles(handler,node,matches.EmbeddedCoderDictionary,'EmbeddedCoderDictionary',[".sldd"])...
            ,i_analyzeCallbacks(handler,node,matches.PostCodeGenCommand,'PostCodeGenCommand')...
            ];


            for n=1:length(matches.SystemTargetFile.Value)
                if matches.SystemTargetFile.Value{n}==this.DefaultSystemTargetFile
                    continue;
                end

                configset=matches.SystemTargetFile.Configset{n};
                target=this.getSystemTargetFile(matches.SystemTargetFile.Value{n});
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,'',target,'',['SimulinkCoder,',configset,',SystemTargetFile']);%#ok<AGROW>

                [~,filename]=fileparts(target.Location{1});
                candidate=[filename,'_make_rtw_hook'];
                makeHook=dependencies.internal.analysis.findSymbol(candidate);
                if makeHook.Resolved
                    deps(end+1)=dependencies.internal.graph.Dependency(...
                    node,'',makeHook,'',['SimulinkCoder,',configset,',RTWHookFile']);%#ok<AGROW>
                end
            end


            for n=1:length(matches.MakeCommand.Value)
                if matches.MakeCommand.Value{n}==this.DefaultMakeCommand
                    continue;
                end

                configset=matches.MakeCommand.Configset{n};
                makefile=strsplit(matches.MakeCommand.Value{n});
                if~isempty(makefile{1})
                    target=dependencies.internal.analysis.findSymbol(makefile{1});
                    deps(end+1)=dependencies.internal.graph.Dependency(...
                    node,'',target,'',['SimulinkCoder,',configset,',MakeCommand']);%#ok<AGROW>
                end
            end


            tfl=[matches.TargetFunctionLibrary.Value,matches.CodeReplacementLibrary.Value];
            for n=1:length(tfl)
                deps=[deps,i_analyzeTFL(handler,node,tfl{n})];%#ok<AGROW>
            end
        end

        function clearCache(this)
            this.TLCFileMap.Value=[];
        end

    end

    methods(Access=private)

        function addConfigQueries(this,group,parameters)
            import dependencies.internal.analysis.simulink.queries.ConfigSetQuery
            for n=1:length(parameters)
                queries.(erase(parameters{n},'Array//'))=ConfigSetQuery(group,parameters{n});
            end
            this.addQueries(queries);
        end

        function addStateflowQueries(this,parameters)
            import dependencies.internal.analysis.simulink.queries.StateflowTargetQuery
            for n=1:length(parameters)
                queries.(parameters{n})=StateflowTargetQuery(parameters{n});
            end
            this.addQueries(queries);
        end

        function node=getSystemTargetFile(this,name)

            node=dependencies.internal.graph.Node.createFileNode(name);
            if node.Resolved
                return;
            end


            node=dependencies.internal.graph.Node.createFileNode(fullfile(pwd,name));
            if node.Resolved
                return;
            end


            if isempty(this.TLCFileMap.Value)
                this.TLCFileMap.Value=findTLC;
            end


            if this.TLCFileMap.Value.isKey(name)
                tlc=this.TLCFileMap.Value(name);
                node=dependencies.internal.graph.Node.createFileNode(tlc);
                return;
            end


            node=dependencies.internal.graph.Node.createFileNode(name);
        end

    end

end


function deps=i_analyzeTargets(handler,node,includeMatches,sourceMatches,libraryMatches,sourceCodeMatches,headerMatches,deptype)
    deps=dependencies.internal.graph.Dependency.empty;

    if isempty([includeMatches.Value{:},sourceMatches.Value{:},libraryMatches.Value{:},sourceCodeMatches.Value{:},headerMatches.Value{:}])
        return;
    end

    includePaths=i_createConfigSetMap(includeMatches.Value,includeMatches.Configset);
    srcFiles=i_createConfigSetMap(sourceMatches.Value,sourceMatches.Configset);
    libFiles=i_createConfigSetMap(libraryMatches.Value,libraryMatches.Configset);
    customSrc=i_createConfigSetMap(sourceCodeMatches.Value,sourceCodeMatches.Configset);
    customHdr=i_createConfigSetMap(headerMatches.Value,headerMatches.Configset);

    configMatches=vertcat(includeMatches.Configset',...
    sourceMatches.Configset',...
    libraryMatches.Configset',...
    sourceCodeMatches.Configset',...
    headerMatches.Configset');

    configsets=unique(configMatches);

    for n=1:length(configsets)
        try
            configset=configsets{n};

            resolved=i_resolveCustomCode(...
            i_getParam(includePaths,configset),...
            i_getParam(srcFiles,configset),...
            i_getParam(libFiles,configset),...
            i_getParam(customSrc,configset),...
            i_getParam(customHdr,configset),...
            node.Location{1});

            for m=1:numel(resolved.files)
                target=handler.Resolver.findFile(node,resolved.files{m},{});
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,'',target,'',[deptype,',',configset,',',resolved.subdeptypes{m}]);%#ok<AGROW>
            end

        catch exception
            warning=dependencies.internal.graph.Warning(...
            exception.identifier,exception.message,'',deptype);
            handler.warning(warning);
        end
    end

end


function map=i_createConfigSetMap(param,config)
    map=containers.Map;
    for n=1:length(param)
        map(config{n})=param{n};
    end
end


function param=i_getParam(map,config)
    if map.isKey(config)
        param=map(config);
    else
        param='';
    end
end


function resolved=i_resolveCustomCode(includePaths,srcFiles,libFiles,customSrc,customHdr,model)





    resolved.files=[];
    resolved.subdeptypes=[];
    resolved.isresolved=[];
    resolved.includepaths=[];

    customSrc=sprintf('%s\n%s',customSrc,customHdr);

    [resolved.files,resolved.isresolved,resolved.includepaths]=...
    dependencies.internal.analysis.simulink.resolveCustomCode(...
    model,includePaths,srcFiles,libFiles,customSrc);

    resolved.subdeptypes=repmat({'CustomCode'},1,numel(resolved.files));

end


function deps=i_analyzeExtraFiles(handler,node,matches,type,extensions)

    files=[matches.Value];
    configsets=[matches.Configset];

    deps=dependencies.internal.graph.Dependency.empty;
    for n=1:length(files)
        file=files{n};
        if~isempty(file)
            depType=['SimulinkCoder,',configsets{n},',CodeCustomization,',type];
            target=handler.Resolver.findFile(node,file,extensions);
            deps(end+1)=dependencies.internal.graph.Dependency(...
            node,'',target,'',depType);%#ok<AGROW>
        end
    end
end


function deps=i_analyzeCallbacks(handler,node,matches,type)
    import dependencies.internal.analysis.matlab.Variable;
    import dependencies.internal.graph.Component;

    callbacks=[matches.Value];
    configsets=[matches.Configset];

    deps=dependencies.internal.graph.Dependency.empty;
    for n=1:length(callbacks)
        callback=callbacks{n};
        if~isempty(callback)
            depType=['SimulinkCoder,',configsets{n},',CodeCustomization,',type];
            factory=dependencies.internal.analysis.DependencyFactory(handler,Component.createRoot(node),depType);

            knownVars=[Variable("modelName"),Variable("buildInfo"),Variable("h")];
            workspace=dependencies.internal.analysis.matlab.Workspace.createAnalysisWorkspace(...
            handler.Analyzers.MATLAB.BaseWorkspace,...
            knownVars);

            deps=[deps,handler.Analyzers.MATLAB.analyze(callback,factory,workspace)];%#ok<AGROW>
        end
    end
end


function deps=i_analyzeTFL(handler,node,library)
    deps=dependencies.internal.graph.Dependency.empty;

    tr=dependencies.internal.analysis.simulink.getRTWTargetRegistry();
    try
        tflTblList=[];
        crls=coder.internal.getCRLs(tr,library);
        if~isempty(crls)
            n=length(crls);
            for i=1:n
                if~isempty(crls(i))
                    tflTblList=[tflTblList;crls(i).TableList];%#ok<AGROW>
                end
            end
        end

        if~isempty(tflTblList)
            files=unique(tflTblList);
            for n=1:numel(files)
                [~,~,ext]=fileparts(files{n});
                target=handler.Resolver.findFile(node,files{n},[".m",ext]);
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,'',target,'','CodeReplacementLibrary');%#ok<AGROW>
            end
        end

    catch
        key='SimulinkDependencyAnalysis:Engine:MissingTargetFunctionLib';
        warning=dependencies.internal.graph.Warning(...
        key,message(key,library).getString,'','CodeReplacementLibrary');
        handler.warning(warning);
    end

end


function map=findTLC

    map=containers.Map;

    folders=string(strsplit(path,pathsep));
    idx=startsWith(folders,matlabroot);

    for sfolder=folders(idx)
        folder=char(sfolder);
        [~,name]=fileparts(folder);
        if startsWith(name,'rtw')
            addTLC(map,fullfile(folder,'*.tlc'));
        end
    end

    for sfolder=folders(~idx)
        folder=char(sfolder);
        addTLC(map,fullfile(folder,'*.tlc'));
    end

    addTLC(map,fullfile(matlabroot,'rtw','c','*','*.tlc'));
    addTLC(map,fullfile(matlabroot,'rtw','ada','*','*.tlc'));
    addTLC(map,fullfile(matlabroot,'toolbox','rtw','targets','*','*','*.tlc'));

end


function addTLC(map,folder)
    files=dir(folder);
    for file=files'
        map(file.name)=fullfile(file.folder,file.name);
    end
end
