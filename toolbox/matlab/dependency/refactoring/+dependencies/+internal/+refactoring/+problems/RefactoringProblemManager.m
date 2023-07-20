classdef RefactoringProblemManager





    properties(Constant)
        DIRTY_FILE=i_makeProblem("DirtyFile");
        LOADED_TEST_HARNESS=i_makeProblem("LoadedTestHarness");
        SHADOWED_FILE=i_makeProblem("ShadowedFile");
        SIMULATING_MODEL=i_makeProblem("SimulatingModel");
        UNSUPPORTED_FILE_TYPE=i_makeProblem("UnsupportedFileType");
    end

    properties(Constant,Access=private)
        IS_FILE_BASED=i_makeFileBasedNodeFilter();
        NO_PROBLEM=dependencies.internal.refactoring.Problem.empty(1,0);
    end

    properties(GetAccess=private,SetAccess=immutable)
        FilePathToProblemList containers.Map;
    end

    methods
        function this=RefactoringProblemManager(nodes)
            import matlab.internal.project.unsavedchanges.getLoadedFiles;

            this.FilePathToProblemList=containers.Map("KeyType","char","ValueType","any");
            fileBasedNodes=nodes(this.IS_FILE_BASED.apply(nodes));
            [filePathSet,unsupported,shadowingNameToLocation]=i_parseFiles(fileBasedNodes);

            for filePath=unsupported
                this.FilePathToProblemList(filePath)=this.UNSUPPORTED_FILE_TYPE;
            end

            loadedFiles=reshape(getLoadedFiles(),1,[]);

            for loadedFile=loadedFiles
                filePath=loadedFile.Path;
                if filePathSet.isKey(filePath)
                    this.addProblemsFromProperties(filePath,loadedFile.Properties);
                end
                [~,name,ext]=fileparts(filePath);
                if i_canShadow(ext)&&shadowingNameToLocation.isKey(name)
                    shadowedPaths=shadowingNameToLocation(name);
                    for path=shadowedPaths(~strcmp(shadowedPaths,filePath))
                        this.addProblems(path,this.SHADOWED_FILE);
                    end
                end
            end
        end

        function problems=getProblemsForNode(this,node)
            if this.IS_FILE_BASED.apply(node)
                problems=this.getProblemsForFile(node.Location{1});
            else
                problems=this.NO_PROBLEM;
            end
        end

        function problems=getProblemsForFile(this,filePath)
            if this.FilePathToProblemList.isKey(filePath)
                problems=this.FilePathToProblemList(filePath);
            else
                problems=this.NO_PROBLEM;
            end
        end
    end

    methods(Access=private)

        function addProblems(this,path,problems)
            if this.FilePathToProblemList.isKey(path)
                problems=[problems,this.FilePathToProblemList(path)];
            end
            this.FilePathToProblemList(path)=problems;
        end

        function addProblemsFromProperties(this,path,properties)
            problems=this.NO_PROBLEM;

            properties=reshape(properties,1,[]);
            for property=properties
                problems=[problems,this.unsavedPropertyToProblems(property)];%#ok<AGROW>
            end

            if~isempty(problems)
                this.addProblems(path,problems);
            end
        end

        function problems=unsavedPropertyToProblems(this,property)
            import matlab.internal.project.unsavedchanges.Property;
            switch property
            case Property.Unsaved
                problems=this.DIRTY_FILE;
            case Property.InternalTestHarnessOpen
                problems=this.LOADED_TEST_HARNESS;
            case Property.Simulating
                problems=this.SIMULATING_MODEL;
            otherwise
                problems=this.NO_PROBLEM;
            end
        end
    end
end

function canShadow=i_canShadow(ext)
    canShadow=ismember(ext,[".mdl",".slx"]);
end

function unsupported=i_isUnsupported(ext)
    unsupported=ismember(ext,[".mlx",".mlapp"]);
end

function filter=i_makeFileBasedNodeFilter()
    import dependencies.internal.graph.NodeFilter;
    import dependencies.internal.graph.Type;
    filter=NodeFilter.nodeType([Type.FILE,Type.TEST_HARNESS]);
end

function problem=i_makeProblem(id)
    problem=dependencies.internal.refactoring.Problem;
    problem.Id=id;
    problem.Name=string(message("MATLAB:dependency:refactoring:"+id));
end

function[filePathSet,unsupported,shadowingNameToLocation]=i_parseFiles(fileBasedNodes)
    import dependencies.internal.graph.Type;

    filePathSet=containers.Map("KeyType","char","ValueType","logical");
    unsupported=strings(1,0);
    shadowingNameToLocation=containers.Map("KeyType","char","ValueType","any");
    fileBasedNodes=reshape(fileBasedNodes,1,[]);
    for node=fileBasedNodes
        filePath=string(node.Location{1});
        filePathSet(filePath)=true;

        [~,name,ext]=fileparts(filePath);

        if i_canShadow(ext)
            if shadowingNameToLocation.isKey(name)
                shadowingNameToLocation(name)=[shadowingNameToLocation(name),filePath];
            else
                shadowingNameToLocation(name)=filePath;
            end
        end

        if i_isUnsupported(ext)
            unsupported(end+1)=filePath;%#ok<AGROW>
        end
    end
end
