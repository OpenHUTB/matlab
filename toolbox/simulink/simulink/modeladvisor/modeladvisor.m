function modeladvisor(system,varargin)

























    if nargin>0
        system=convertStringsToChars(system);
    end

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(ischar(system)||isstring(system))&&strcmpi(system,'help')
        helpview([docroot,'/mapfiles/simulink.map'],'model_advisor');
        return;
    end

    if checkIfMACEisOpen
        return
    end

    if~((length(system)==1&&ishandle(system))||ischar(system))
        DAStudio.error('ModelAdvisor:engine:AdvisorAPIIncorrectInput')
    end

    system=loadSystemforMA(system);
    parseargs=varargin;


    if nargin>1&&strcmpi(varargin{1},'SystemSelector')
        if slfeature('AdvisorWebUI')


            rtw_checkdir;
            Advisor.loadAdvisor(system,parseargs{:});
            return;
        end

        dialogTitle=[DAStudio.message('Simulink:tools:MASystemSelector'),' - ',DAStudio.message('Simulink:tools:MAModelAdvisor')];
        selectedsystem=modeladvisorprivate('systemselector',system,dialogTitle);
        if isempty(selectedsystem)
            return
        else
            if ishandle(system)
                selectedsystem=get_param(selectedsystem,'handle');
            end
            system=selectedsystem;
        end
        parseargs=varargin(2:end);
    end

    if iscell(parseargs)&&length(parseargs)==2

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system,'new','_modeladvisor_',parseargs{:});
    else


        mdlObj=get_param(bdroot(system),'Object');
        mdladvObj=mdlObj.getModelAdvisorObj;



        if~isempty(mdladvObj)&&...
            ~isempty(strfind(mdladvObj.ConfigFilePath,'toolbox\slcheck\slmetrics\private\MAConfig.mat'))
            app=Advisor.Manager.getActiveApplicationObj();
            app.delete;
        end

        viewMode='';
        if~isempty(mdladvObj)&&...
            isa(mdladvObj.MAExplorer,'DAStudio.Explorer')
            viewMode=mdladvObj.viewMode;
        end
        if nargin>1&&(strcmp(varargin{end},'MAStandardUI')||...
            strcmp(varargin{end},'MADashboard'))
            viewMode=varargin{end};
        end
        if isempty(viewMode)
            viewMode=modeladvisorprivate('modeladvisorutil2','DefaultMAUI');
        end



        ModelAdvisorLite.GUIModelAdvisorLite.closeGUI(system);
        if strcmp(viewMode,'MAStandardUI')

            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system,'new','_modeladvisor_');
        else
            if~isempty(mdladvObj)&&...
                isa(mdladvObj.MAExplorer,'DAStudio.Explorer')&&...
                mdladvObj.MAExplorer.isVisible&&...
                strcmp(getfullname(system),mdladvObj.SystemName)&&...
                strcmp(mdladvObj.CustomTARootID,'_modeladvisor_')
                mdladvObj.MAExplorer.hide;
            end
            dlg=ModelAdvisorLite.GUIModelAdvisorLite(system);
            dlg.show;
            return;
        end
    end


    if isempty(mdladvObj)||mdladvObj.ContinueViewExistRpt
        return
    end
    mdladvObj.displayExplorer;





    function system=loadSystemforMA(system)
        if ishandle(system)


            load_system(getfullname(system));
        else
            [~,sysname,ext]=fileparts(system);
            if strcmp(ext,'.mdl')||strcmp(ext,'.slx')
                system=sysname;
            elseif strcmp(ext,'.sfx')

                DAStudio.error('ModelAdvisor:engine:MAUnSupportedFileType')
            elseif isempty(ext)
                load_system(system);
                if~isempty(Simulink.loadsave.resolveFile(bdroot(system),'.sfx'))
                    DAStudio.error('ModelAdvisor:engine:MAUnSupportedFileType')
                end
                return;
            end

            load_system(system);
        end


        function maceIsOpen=checkIfMACEisOpen()
            maceIsOpen=false;


            activemdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if isa(activemdladvObj,'Simulink.ModelAdvisor')&&isa(activemdladvObj.ConfigUIWindow,'DAStudio.Explorer')
                warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MAUnableStartMAWhenMACEOpen'));
                set(warndlgHandle,'Tag','MAUnableStartMAWhenMACEOpen');
                maceIsOpen=true;
            end




