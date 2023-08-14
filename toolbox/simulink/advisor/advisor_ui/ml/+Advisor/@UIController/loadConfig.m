function result=loadConfig(this,varargin)


    if ismac
        h=figure('OuterPosition',[1,1,3,3]);
        drawnow;
        h.delete;
    end

    if nargin>1
        configFilePath=varargin{1};
    else

        [filename,pathname]=uigetfile({'*.json; *.mat','JSON-files (*.json) and MAT-files (*.mat)';},DAStudio.message('Simulink:tools:MAOpen'));

        if~isempty(this.maObj.AdvisorWindow)
            this.maObj.AdvisorWindow.bringToFront()
        end

        if isnumeric(filename)&&filename==0

            result=false;
            return;
        end

        [~,~,ext]=fileparts(filename);
        configFilePath=fullfile(pathname,filename);

        ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.reset();
        ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.registerFileName(configFilePath);

    end



    if strcmp(ext,'.json')
        jsonString=fileread(configFilePath);
        try
            configData=jsondecode(jsonString);
        catch
            error('Advisor:UI:CorruptConfig',DAStudio.message('ModelAdvisor:engine:MACEConfigCorruptMsg'));
        end

        if~(isstruct(configData)&&isfield(configData,'SimulinkVersion')...
            &&isfield(configData,'Options')&&isfield(configData,'Tree'))
            error('Advisor:UI:CorruptConfig',DAStudio.message('ModelAdvisor:engine:MACEConfigCorruptMsg'));
        end
    end


    if strcmp(ext,'.json')
        jsonStruct=jsondecode(jsonString);
        checkList=jsonStruct.Tree;
        if~iscell(checkList)
            checkList=num2cell(checkList);
        end

        for i=1:numel(checkList)
            if~isempty(checkList{i}.InputParameters)
                if~iscell(checkList{i}.InputParameters)
                    checkList{i}.InputParameters=num2cell(checkList{i}.InputParameters);
                end
                for j=1:numel(checkList{i}.InputParameters)
                    checkList{i}.InputParameters{j}.Value=checkList{i}.InputParameters{j}.value;
                end
            end
        end
        maObj=Simulink.ModelAdvisor;

        checkList=maObj.assignMACIndex(checkList);
        checkList=ModelAdvisorWebUI.interface.updateDisplayIcons(checkList);
        ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.registerChecks(checkList);
    end

    configValidityResult=ModelAdvisorWebUI.interface.checkInvalidChecks();
    if configValidityResult.hasInValidChecks
        option=questdlg(DAStudio.message('ModelAdvisor:engine:MAOutdatedChecksWarning'),...
        DAStudio.message('ModelAdvisor:engine:MACEOutdatedChecksWarningTitle'),'Yes','No','Yes');
        result=false;

        switch option
        case 'Yes'

            Simulink.ModelAdvisor.openConfigUIFromMAMenu();
        case 'No'
            return;
        end
    end
    this.setRecentConfigs(configFilePath);
    this.maObj.activateConfiguration(configFilePath,true);
    result=true;
end
