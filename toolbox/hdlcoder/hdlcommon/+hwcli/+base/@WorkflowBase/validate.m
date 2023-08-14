function validate(obj,varargin)





    p=inputParser;


    p.addParameter('Warn',true);

    p.parse(varargin{:});
    inputArgs=p.Results;





    isISE=strcmp(obj.SynthesisTool,'Xilinx ISE');
    isIPCore=strcmp(obj.TargetWorkflow,'IP Core Generation');




    if(isISE&&~isIPCore)
        if(obj.Objective~=hdlcoder.Objective.None)
            error(message('hdlcoder:workflow:NoISEObjectiveSupport',obj.TargetWorkflow))
        end
    end




    if(isempty(obj.ProjectFolder))
        error(message('hdlcoder:workflow:ProjectFolderEmpty'));
    end




    if(inputArgs.Warn&&exist(obj.ProjectFolder,'dir'))


        ignoreTasks={'RunTaskProgramTargetDevice','RunTaskAnnotateModelWithSynthesisResult'};

        checkTasks=setdiff(obj.Tasks,ignoreTasks);

        for i=1:length(checkTasks)
            task=checkTasks{i};
            if(obj.(task)==true)
                warning(message('hdlcoder:workflow:ProjectFolderExists',obj.ProjectFolder));
                break;
            end
        end
    end










    noTaskFlag=1;
    for i=1:length(obj.Tasks)
        task=obj.Tasks{i};
        if(obj.(task)==true)
            noTaskFlag=0;
        end
    end

    if noTaskFlag
        error(message('hdlcoder:workflow:NoTaskEnabled'));
    end








    if(obj.AllowUnsupportedToolVersion~=1&&obj.AllowUnsupportedToolVersion~=0)
        error(message('HDLShared:hdldialog:HDLWAImportWorkflowUnsupportedToolVersionError',...
        obj.AllowUnsupportedToolVersion));
    end

