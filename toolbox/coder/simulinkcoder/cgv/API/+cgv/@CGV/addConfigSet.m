


























function this=addConfigSet(this,varargin)
    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end

    if nargin<2
        DAStudio.error('RTW:cgv:ValidAddConfigSet');
    end
    if~isempty(this.ConfigSetName)
        DAStudio.error('RTW:cgv:ActivateConfigSetCalled');
    end



    arg1=varargin{1};
    if~ischar(arg1)
        if nargin~=2
            validParams=DAStudio.message('RTW:cgv:ValidAddConfigSet');
            DAStudio.error('RTW:cgv:TooManyArgs',validParams);
        end
        configSet=arg1;
        csName=inputname(2);
        if isempty(csName)
            DAStudio.error('RTW:cgv:ValidAddConfigSet');
        end
    elseif~isequal(lower(arg1),'file')

        if nargin~=2
            DAStudio.error('RTW:cgv:ValidAddConfigSet');
        end
        try
            configSet=evalin('caller',arg1);
        catch ME
            validParams=DAStudio.message('RTW:cgv:ValidAddConfigSet');
            DAStudio.error('RTW:cgv:NotInCallersWorkspace',arg1,validParams);
        end
        csName=arg1;
    elseif(nargin==3||nargin==5)

        if~ischar(varargin{2})
            DAStudio.error('RTW:cgv:ValidAddConfigSet');
        end
        configFile=varargin{2};
        try
            configSet=load(configFile);
        catch ME
            validParams=DAStudio.message('RTW:cgv:ValidAddConfigSet');
            validParams=[configFile,'. ',validParams];
            DAStudio.error('RTW:cgv:CannotOpen',validParams);
        end


        if(nargin==3)
            csName=configFile;
            configSet=checkForConfigSet(configSet,configFile);
        else


            arg3=varargin{3};
            arg4=varargin{4};
            if~ischar(arg3)||~ischar(arg4)||~strcmpi(arg3,'var')
                DAStudio.error('RTW:cgv:ValidAddConfigSet');
            end
            csName=varargin{4};
            params=configSet;%#ok - 'params' is in the eval string
            toexec=char(strcat('configSet = params.',csName,';'));
            try
                eval(toexec);
            catch ME
                validParams=DAStudio.message('RTW:cgv:ValidAddConfigSet');
                DAStudio.error('RTW:cgv:ParamDoesNotExist',configFile,csName,validParams);
            end
        end
    else
        DAStudio.error('RTW:cgv:ValidAddConfigSet');
    end

    if~isequal(class(configSet),'Simulink.ConfigSet')
        validParams=DAStudio.message('RTW:cgv:ValidAddConfigSet');
        DAStudio.error('RTW:cgv:ParamIsNotConfigSet',csName,validParams);
    end
    this.UserAddedConfigSet=configSet.copy;


    function configSet=checkForConfigSet(configSet,configFile)
        if~isequal(class(configSet),'Simulink.ConfigSet')


            params=configSet;
            fields=fieldnames(params);
            contains=0;
            for i=1:length(fields)
                toexec=char(strcat('tmp = params.',fields(i),';'));
                eval(toexec);

                if isequal(class(tmp),'Simulink.ConfigSet')
                    contains=contains+1;
                    configSet=tmp;
                end
            end
            if contains>1
                DAStudio.error('RTW:cgv:WrongNumberOfConfigSets',configFile,contains);
            elseif contains==0
                validParams=DAStudio.message('RTW:cgv:ValidAddConfigSet');
                DAStudio.error('RTW:cgv:ParamInFileIsNotConfigSet',configFile,validParams);
            end
        end
