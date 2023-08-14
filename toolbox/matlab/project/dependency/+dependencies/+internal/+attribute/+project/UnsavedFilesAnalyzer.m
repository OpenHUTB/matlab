classdef UnsavedFilesAnalyzer<dependencies.internal.attribute.AttributeAnalyzer




    properties(Constant,Access=private)
        Interval=seconds(10);
        NoProblems=dependencies.internal.attribute.Attribute.empty(1,0);
        Unsaved=i_createUnsavedChangesProblem;
    end

    properties(Access=private)
        UnsavedFiles=strings(0);
        UpdateTime=NaT;
    end

    methods(Access=private)
        function update(this)
            currentTime=datetime('now');

            if isnat(this.UpdateTime)||currentTime>this.UpdateTime+this.Interval
                files=matlab.internal.project.unsavedchanges.getLoadedFiles(matlab.internal.project.unsavedchanges.Property.Unsaved);
                this.UnsavedFiles=[files.Path];
                this.UpdateTime=currentTime;
            end
        end
    end

    methods
        function problems=analyze(this,node,~)
            import dependencies.internal.attribute.project.UnsavedFilesAnalyzer;

            this.update();

            if isempty(this.UnsavedFiles)
                problems=UnsavedFilesAnalyzer.NoProblems;
                return;
            end

            nodePath=string(node.Location{1});
            if any(ismember(this.UnsavedFiles,nodePath))
                problems=UnsavedFilesAnalyzer.Unsaved;
            else
                problems=UnsavedFilesAnalyzer.NoProblems;
            end
        end
    end
end




function problem=i_createUnsavedChangesProblem()
    id="UnsavedChanges";
    name=string(message("MATLAB:dependency:viewer:UnsavedChanges"));
    type=dependencies.internal.attribute.Severity.Warning;
    identity=dependencies.internal.attribute.AttributeIdentity(id,name,type);
    problem=dependencies.internal.attribute.Attribute(identity);
end
