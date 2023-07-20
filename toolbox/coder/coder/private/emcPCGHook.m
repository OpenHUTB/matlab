function emcPCGHook(project,buildInfo,pcgCommand,verbose)








    function restorepwd()
        if~strcmp(cur_pwd,pwd)
            cd(cur_pwd);
        end
    end


    modelName=project.Name;

    if~isempty(pcgCommand)
        if verbose
            disp('### Evaluating PostCodeGenCommand specified in the project');
        end
        try


            cur_pwd=pwd;

            pcgHook(pcgCommand,modelName,modelName,buildInfo);
        catch me
            restorepwd();
            x=coderprivate.msgSafeException('Coder:FE:PostCodegenCommandError');
            x=x.addCause(coderprivate.makeCause(me));
            x=MException(x.identifier,'%s',x.getReport());
            x.throwAsCaller();
        end

        restorepwd();
    end
end



function pcgHook(pcgCommand,modelName,projectName,buildInfo)%#ok
    eval(pcgCommand);
end
