classdef ModelWorkspaceAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        BaseType="ModelWorkspace";
    end

    properties(Access=private,Constant)
        WorkspaceMxArrayPart="/simulink/modelWorkspace.mxarray";
        WorkspaceMatFilePart="/simulink/modelworkspace.mat";
    end

    methods
        function this=ModelWorkspaceAnalyzer()
            this@dependencies.internal.analysis.simulink.ModelAnalyzer(true)
            wsTag=Simulink.loadsave.Query('/Model/WSMdlFileData');
            tag=Simulink.loadsave.Query('/MatData/DataRecord[Tag=* and Data=*]/Tag');
            data=Simulink.loadsave.Query('/MatData/DataRecord[Tag=* and Data=*]/Data');
            this.addQueries(...
            [wsTag;tag;data],...
            {'mdl';'mdl';'mdl'},...
            [0;0;0],...
            [Inf;Inf;Inf]);
        end

        function v=varsOfTypeFcn(~,required_type,var_types,var_names,var_values)
            match=strcmp(var_types,required_type);
            v=cell2struct(var_values(match(:)),var_names(match(:)));
        end

        function deps=analyze(this,handler,fileNode,matches)
            import dependencies.internal.analysis.simulink.readMatData;
            import dependencies.internal.buses.util.analyzeBusElementObjects;
            import dependencies.internal.buses.util.analyzeBusObjects;
            import dependencies.internal.buses.util.analyzeBusStructs;
            import dependencies.internal.buses.util.analyzeMatFile;
            import dependencies.internal.buses.util.analyzeSignalObjects;
            deps=dependencies.internal.graph.Dependency.empty;

            busNode=handler.Analyzers.Bus.BusNode;

            if handler.ModelInfo.IsSLX
                reader=Simulink.loadsave.SLXPackageReader(handler.ModelInfo.ResavedPath);
                if reader.hasPart(this.WorkspaceMxArrayPart)

                    origWarn=warning('off');
                    cleanup=onCleanup(@()warning(origWarn));
                    ws=reader.readPartToVariable(this.WorkspaceMxArrayPart);
                    names=fieldnames(ws);
                    vars=struct2cell(ws);
                    types=cell(size(vars));
                    for i=1:numel(vars)
                        types{i}=class(vars{i});
                    end
                    deps=dependencies.internal.buses.util.analyzeVariables(...
                    @(type)this.varsOfTypeFcn(type,types,names,vars),...
                    busNode,fileNode,this.BaseType);

                elseif reader.hasPart(this.WorkspaceMatFilePart)

                    origWarn=warning('off');
                    cleanup=onCleanup(@()warning(origWarn));

                    deps=readMatData(reader,this.WorkspaceMatFilePart,...
                    @(file)analyzeMatFile(file,busNode,fileNode,this.BaseType));
                end

            elseif~isempty(matches)&&~isempty(matches{1})
                tag=matches{1}.Value;
                tagMatches=matches{2};
                dataMatches=matches{3};
                encodedData=dataMatches(strcmp({tagMatches.Value},tag)).Value;

                data=sls_uudecode(encodedData);
                buses=i_filterValueTypeAndCreateStructs(data,@(x)isa(x,'Simulink.Bus'));
                elements=i_filterValueTypeAndCreateStructs(data,@(x)isa(x,'Simulink.BusElement'));
                signals=i_filterValueTypeAndCreateStructs(data,@(x)isa(x,'Simulink.Signal'));
                structs=i_filterValueTypeAndCreateStructs(data,@isstruct);

                deps=[analyzeBusObjects(busNode,fileNode,buses,this.BaseType)...
                ,analyzeBusElementObjects(busNode,fileNode,elements,this.BaseType)...
                ,analyzeSignalObjects(busNode,fileNode,signals,this.BaseType)...
                ,analyzeBusStructs(busNode,fileNode,structs,this.BaseType)];

            end
        end
    end
end

function structs=i_filterValueTypeAndCreateStructs(nameAndValueStructArr,isTypeFunc)
    isType=arrayfun(@(x)isTypeFunc(x.Value),nameAndValueStructArr);
    nameAndValueStructArr=nameAndValueStructArr(isType);
    structs=struct;
    for n=1:length(nameAndValueStructArr)
        entry=nameAndValueStructArr(n);
        structs.(entry.Name)=entry.Value;
    end
end
