function result=open()

    try

        configFileIsLoaded=false;
        needValidateStructs=true;
        if ismac
            h=figure('OuterPosition',[1,1,3,3]);
            drawnow;
            h.delete;
        end
        [filename,pathname]=uigetfile({'*.json; *.mat','JSON-files (*.json) and MAT-files (*.mat)';},DAStudio.message('Simulink:tools:MAOpen'));


        configFileName=fullfile(pathname,filename);
        ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.reset();
        ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.registerFileName(configFileName);

        if~isequal(filename,0)&&~isequal(pathname,0)
            configFilePath=fullfile(pathname,filename);
            [~,~,ext]=fileparts(configFilePath);
            if strcmp(ext,'.mat')
                configVar=load(configFilePath);
                if isfield(configVar,'jsonString')

                    jsonString=configVar.jsonString;
                    configuration=configVar.configuration;
                    cuiCellArray=[{configuration.ConfigUIRoot},configuration.ConfigUICellArray];
                    ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.registerChecks(cuiCellArray);
                    configFileIsLoaded=true;
                else
                    maObj=Simulink.ModelAdvisor;
                    maObj.loadConfiguration(configFilePath);
                    jsonString=Advisor.Utils.exportJSON(maObj,'MACE');
                    needValidateStructs=false;
                    configFileIsLoaded=true;
                end
            elseif strcmp(ext,'.json')
                jsonString=fileread(configFilePath);
                if slfeature('MACEConfigurationValidation')
                    jsonStruct=jsondecode(jsonString);
                    checkList=jsonStruct.Tree;
                    if~iscell(checkList)
                        checkList=num2cell(checkList);
                    end
                    maObj=Simulink.ModelAdvisor;

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

                    checkList=maObj.assignMACIndex(checkList);
                    checkList=ModelAdvisorWebUI.interface.updateDisplayIcons(checkList);
                    ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.registerChecks(checkList);
                    jsonStruct.Tree=checkList;
                    jsonString=jsonencode(jsonStruct);
                end
                configFileIsLoaded=true;
            end
        else

            result=struct('success',true,'message',jsonencode(struct('title','cancel','content','cancel')),'warning',false,'filepath','','value',jsonencode('cancel'));
            result=jsonencode(result);

            t=ModelAdvisorWebUI.interface.MACEUI.getInstance;
            t.bringToFront;
            return
        end

        if configFileIsLoaded
            if validateJSON(jsonString,needValidateStructs)
                success=true;
                title=DAStudio.message('ModelAdvisor:engine:MACESuccess');
                msg=DAStudio.message('ModelAdvisor:engine:MACEConfigLoadMsg');
            else
                success=false;
                title=DAStudio.message('ModelAdvisor:engine:CmdAPIFail');
                msg=DAStudio.message('ModelAdvisor:engine:MACEConfigCorruptMsg');
            end

        else
            success=false;
            title=DAStudio.message('ModelAdvisor:engine:CmdAPIFail');
            msg=DAStudio.message('ModelAdvisor:engine:MACEConfigNotLoadedMsg');
        end
    catch E
        success=false;
        title=DAStudio.message('ModelAdvisor:engine:MACEError');
        msg=[DAStudio.message('ModelAdvisor:engine:MACEConfigCorruptMsg'),E.message];
        configFilePath='';
        jsonString='';
    end
    if slfeature('MACEConfigurationValidation')
        enableConfigurationValidation=true;
    else
        enableConfigurationValidation=false;
    end
    resultStruct=struct('success',success,'message',jsonencode(struct('title',title,'content',msg)),'warning',false,'filepath',configFilePath,'value',jsonString,'enableConfigurationValidation',enableConfigurationValidation);
    result=jsonencode(resultStruct);
    t=ModelAdvisorWebUI.interface.MACEUI.getInstance;
    t.bringToFront;




end

function value=validateJSON(jsonString,needValidateStructs)
    try
        configData=jsondecode(jsonString);
        value=true;
        if needValidateStructs
            if isstruct(configData)&&isfield(configData,'SimulinkVersion')...
                &&isfield(configData,'Options')&&isfield(configData,'Tree')
                value=true;
            else
                value=false;
            end
        end
    catch
        value=false;
    end
end
