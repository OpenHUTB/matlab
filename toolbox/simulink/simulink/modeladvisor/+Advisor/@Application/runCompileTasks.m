




function runCompileTasks(this,modes,subTrees)


    if isempty(this.CompileErrors)&&~isempty(subTrees)


        for n=1:length(subTrees)

            this.createCompileService(...
            subTrees(n).Models,...
            subTrees(n).RootModel,...
            modes);


            this.CompileService.compile();

            if any(modes==Advisor.CompileModes.CGIR)
                Advisor.RegisterCGIRInspectors.getInstance.clearInspectors;
                Advisor.RegisterCGIRInspectorResults.getInstance.clearResults;
            end
        end
    end
end