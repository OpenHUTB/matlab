classdef SimulinkModelInspector<matlab.depfun.internal.MwFileInspector




    methods

        function obj=SimulinkModelInspector(objs,fcns,flags)
            if~matlab.depfun.internal.requirementsConstants.isSimulinkCompilerAccessible
                error('Simulink Compiler is not accessible.');
            end


            obj@matlab.depfun.internal.MwFileInspector(objs,fcns,flags);
        end

        function[identified_symbol,unknown_symbol]=determineType(obj,name)%#ok
            unknown_symbol=[];

            fullpath='';
            if isfullpath(name)
                if matlab.depfun.internal.cacheExist(name,'file')==2
                    fullpath=name;
                end
            else
                if matlab.depfun.internal.cacheExist(fullfile(pwd,name),'file')==2
                    fullpath=fullfile(pwd,name);
                else
                    fullpath=matlab.depfun.internal.cacheWhich(name);
                end
            end

            if isempty(fullpath)
                error(message('MATLAB:depfun:req:NameNotFound',name));
            end

            [~,filename,ext]=fileparts(fullpath);
            identified_symbol=matlab.depfun.internal.MatlabSymbol(...
            [filename,ext],matlab.depfun.internal.MatlabType.SimulinkModel,fullpath);
        end

    end

    methods(Access=protected)

        function S=getSymbols(obj,file)

            import matlab.depfun.internal.requirementsConstants

            if obj.Target==matlab.depfun.internal.Target.MCR...
                ||obj.Target==matlab.depfun.internal.Target.Deploytool

                matlab.depfun.internal.mccsetpath(true);
            end

            [files,undeployablesBasecodes]=i_analyze(file);

            checkUndeployableProducts(undeployablesBasecodes);

            S=cell(numel(files),1);
            for k=1:numel(files)
                [~,~,ext]=fileparts(files{k});
                if ismember(ext,requirementsConstants.executableMatlabFileExt)
                    S{k}=qualifiedName(files{k});
                else



                    if ismember(ext,requirementsConstants.simulinkModelExt)...
                        &&obj.PathUtility.underDirectory(files{k},fullfile(matlabroot,'toolbox'))


                        continue;
                    end
                    S{k}=files{k};
                end
            end

            S=S(cellfun(@(X)~isempty(X),S));
        end




        function delete(obj)%#ok
        end

    end
end


function[files,undeployablesBasecodes]=i_analyze(file)



    import dependencies.internal.graph.NodeFilter.*



    import dependencies.internal.analysis.simulink.*
    import dependencies.internal.analysis.toolbox.*
    import matlab.depfun.internal.requirementsConstants

    node=dependencies.internal.graph.Node.createFileNode(file);

    ma=[
DataDictionaryAnalyzer
FromFileBlockAnalyzer
ModelWorkspaceAnalyzer
ModelReferenceAnalyzer
MaskedBlockAnalyzer
EnumeratedConstantAnalyzer
StateflowEnumeratedConstantAnalyzer
SFunctionAnalyzer
CoreBlockToolboxAnalyzer
LibraryLinksAnalyzer
    ];

    na=SimulinkNodeAnalyzer(ma);
    ga=dependencies.internal.engine.BasicAnalyzer(na);
    ga.Filters=[
    dependencies.internal.engine.filters.DelegateFilter(isMember(node))
    dependencies.internal.engine.filters.DelegateFilter(acceptNode(true))|ToolboxAnalyzer.analyzeToolboxes(true)
    ];

    graph=ga.analyze(node);

    undeployablesBasecodes=findUndeployableProducts(graph.Nodes);

    filesIdx=apply(isResolved&nodeType(["File","BuiltIn"]),graph.Nodes);
    locations=arrayfun(@(n)n.Location{1},graph.Nodes,'UniformOutput',false);

    files=locations(filesIdx);





    forbiddenExtensions={'.hpp','.cpp','.h','.c','.tlc','.dll','.so','.dyld'};
    removeIdx=endsWith(files,forbiddenExtensions);
    files(removeIdx)=[];





    removeIdx=false(size(files));
    for k=1:numel(files)

        cname=requirementsConstants.pcm_nv.componentOwningFile(files{k});

        if~isempty(cname)
            cinfo=requirementsConstants.pcm_nv.componentInfo(cname);
            if~cinfo.IsDeployable||strcmp(cinfo.Type,'software')
                removeIdx(k)=true;
            end
        end
    end
    files(removeIdx)=[];
end


function foundUndeployableBasecodes=findUndeployableProducts(nodes)




    import dependencies.internal.graph.NodeFilter.*;

    undeployablesBasecodes=getSKBlacklist();

    foundUndeployableBasecodes=cell(1,0);
    nodeFilter=nodeType(dependencies.internal.graph.Type.PRODUCT);
    productNodes=nodes(nodeFilter.apply(nodes));

    for node=productNodes
        baseCodes=node.Location;
        if~isempty(baseCodes)&&all(ismember(baseCodes,undeployablesBasecodes))
            foundUndeployableBasecodes(end+1)=baseCodes(1);%#ok<AGROW>
        end
    end

    foundUndeployableBasecodes=unique(foundUndeployableBasecodes);
end

function checkUndeployableProducts(undeployablesBasecodes)


    if(~isempty(undeployablesBasecodes))

        pcm_nv=matlab.depfun.internal.requirementsConstants.pcm_nv;
        pcm_nv.doSql('SELECT Base_Code, External_Name From Product;');
        productData=pcm_nv.fetchRows();
        productData=vertcat(productData{:});
        mapBaseCodeToExternalName=containers.Map(productData(:,1),productData(:,2));


        undeployables='';
        for bIdx=1:length(undeployablesBasecodes)
            if isKey(mapBaseCodeToExternalName,undeployablesBasecodes{bIdx})
                externalName=mapBaseCodeToExternalName(undeployablesBasecodes{bIdx});
                undeployables=[undeployables,newline,externalName];%#ok<AGROW>
            else
                error(message('simulinkcompiler:build:UnknownProduct',undeployablesBasecodes{bIdx}));
            end
        end


        error(message('simulinkcompiler:build:UnsupportedProduct',undeployables));
    end
end

function SKBlacklist=getSKBlacklist()








    SKBlacklist={...


    'AM',...
    'MB',...
    'RL',...
    'RB',...
    'RC',...
    'RR',...
    'SX',...
    'SE',...
    'HW',...
'LH'...
    };
end



