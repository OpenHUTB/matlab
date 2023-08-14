function[success,maobj]=activateConfiguration(this,configFilePath,varargin)



    persistent dduxValue;






    if(isempty(configFilePath))
        if(isempty(dduxValue)||dduxValue==true)
            dduxValue=false;
            Simulink.DDUX.logData('MACE_CONFIG','defaultconfiguration',dduxValue);
        end



    else
        if(isempty(dduxValue)||dduxValue==false)
            dduxValue=true;
            Simulink.DDUX.logData('MACE_CONFIG','defaultconfiguration',dduxValue);
        end
    end


    if nargin>2
        displayExplorer=varargin{1};
    else
        displayExplorer=true;
    end



    if isa(this.ConfigUIWindow,'DAStudio.Explorer')
        success=false;
        maobj=this;

        warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MAUnableStartMAWhenMACEOpen'));

        set(warndlgHandle,'Tag','MAUnableStartMAWhenMACEOpen');
        return
    end

    WorkDir=this.getWorkDir('CheckOnly');
    if isa(this.MAExplorer,'DAStudio.Explorer')
        this.MAExplorer.delete;
    end


    if exist(WorkDir,'dir')

        if isa(this.Database,'ModelAdvisor.Repository')
            disconnect(this.Database);
        end
        rmdir(WorkDir,'s');


    end





    app=Advisor.Manager.getApplication('Id',this.ApplicationID,'token','MWAdvi3orAPICa11');

    if~isempty(app)


        success=app.loadConfiguration(configFilePath);

        maobj=app.getRootMAObj();




        if success&&~isempty(maobj)&&...
            ((isempty(maobj.ConfigFilePath)&&isempty(configFilePath))||...
            ~isempty(strfind(maobj.ConfigFilePath,configFilePath)))

            success=true;

        else
            success=false;
        end


        if~isempty(maobj)&&displayExplorer
            maobj.displayExplorer();
        end
    else
        success=false;
    end