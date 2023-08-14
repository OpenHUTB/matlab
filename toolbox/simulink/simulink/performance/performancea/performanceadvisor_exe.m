function performanceadvisor_exe(system,varargin)


    if~((length(system)==1&&ishandle(system))||ischar(system))
        DAStudio.error('SimulinkPerformanceAdvisor:advisor:AdvisorAPIIncorrectInput')
    end


    autoRestore=false;
    cleanup=false;

    if nargin==2
        if strcmpi(varargin{1},'AutoRestore')
            autoRestore=true;
        elseif strcmpi(varargin{1},'Cleanup')
            cleanup=true;
        elseif~isempty(varargin{1})
            error(message('SimulinkPerformanceAdvisor:advisor:IllegalArgument'));
        end
    end



    if strcmpi(system,'help')
        return;
    end

    if ishandle(system)



        system=getfullname(system);
    end
    [inputModel,dontcare]=strtok(system,'/');

    if cleanup
        utilPerformanceAdvisorStart(inputModel,'Cleanup');
        return;
    else

        openSystems=find_system('flat');

        if~any(strcmp(openSystems,inputModel))
            open_system(inputModel);
        end


        if autoRestore
            utilPerformanceAdvisorStart(inputModel,'CommandLineEntry','AutoRestore');
        else
            utilPerformanceAdvisorStart(inputModel,'CommandLineEntry');
        end

    end
