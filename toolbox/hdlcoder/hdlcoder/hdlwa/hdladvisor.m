function hdladvisor(system,varargin)






















    if nargin<1||nargin>2
        error(message('HDLShared:hdldialog:HDLWAUsage'));
    end


    system=convertStringsToChars(system);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    systemSelector=false;
    autoRestore=false;
    cleanup=false;
    if nargin==2
        if strcmpi(varargin{1},'SystemSelector')
            systemSelector=true;
        elseif strcmpi(varargin{1},'AutoRestore')
            autoRestore=true;
        elseif strcmpi(varargin{1},'Cleanup')
            cleanup=true;
        else
            error(message('hdlcoder:workflow:IllegalArgument',DAStudio.message('HDLShared:hdldialog:HDLWAErrorMsg1'),DAStudio.message('HDLShared:hdldialog:HDLWAUsage')));
        end
    end


    if cleanup



        return;
    end



    checkoutLicense=false;
    slhdlcoder.checkLicense(checkoutLicense);






    if strcmpi(system,'help')

    else
        if ishandle(system)



            system=getfullname(system);
        end

        [inputModel,dontcare]=strtok(system,'/');
        openSystems=find_system('flat');

        if~any(strcmp(openSystems,inputModel))
            open_system(inputModel);
        end




        if isempty(dontcare)&&systemSelector
            selectedsystem=modeladvisorprivate('systemselector',system);
            if isempty(selectedsystem)
                return
            else
                if ishandle(system)
                    selectedsystem=get_param(selectedsystem,'handle');
                end
                system=selectedsystem;
            end
        end


        if downstream.tool.isNonASCII(system)
            error(message('hdlcommon:workflow:I18nInDUTName',system));
        end


        if autoRestore
            utilHDLAdvisorStart(system,'CommandLineEntry','AutoRestore');
        else
            utilHDLAdvisorStart(system,'CommandLineEntry');
        end

    end



