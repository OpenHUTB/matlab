function displayRename(oldname,newname)




    import matlab.internal.project.util.useWebFrontEnd;

    setting=settings().matlab.project.refactoring.BusRenameEnabled;
    if~setting.ActiveValue
        return;
    end

    if useWebFrontEnd()||dependencies.internal.buses.refactoring.decaf()
        pr=matlab.project.currentProject();
        if~isempty(pr)
            dependencies.internal.buses.displayRename(pr,oldname,newname);
        end
    else
        builder=com.mathworks.toolbox.slprojectsimulink.refactoring.buses.BusRefactoringBuilder.createForCurrentProject;
        if~isempty(builder)
            builder.displayRename(oldname,newname);
        end
    end

end
