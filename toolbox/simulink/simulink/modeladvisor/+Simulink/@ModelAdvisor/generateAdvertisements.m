function generateAdvertisements(this)
    AdList=[];


    if~isempty(this.ConfigFilePath)
        return;
    end

    if~isempty(this.CustomObject)
        if this.CustomObject.ShowAccordion

        else
            this.advertisements=[];
            return;
        end
    else
        if~(strcmp(this.TaskAdvisorRoot.id,'com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor')||...
            strcmp(this.TaskAdvisorRoot.id,'com.mathworks.cgo.group')||...
            strcmp(this.TaskAdvisorRoot.id,'SysRoot'))
            this.advertisements=[];
            return;
        end
    end

    idx=[];
    AccordionInfoList={};


    Ad.id='modeladvisor';
    Ad.DisplayName=DAStudio.message('ModelAdvisor:engine:AccordionMAName');
    Ad.icon=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','ma_16.png');
    Ad.Description=DAStudio.message('ModelAdvisor:engine:AccordionMADescription');
    Ad.visible=false;
    Ad.OnGUI=false;
    if~strcmp(this.CustomTARootID,'_modeladvisor_')
        Ad.visible=true;
    end
    AdList=[AdList,Ad];

    am=Advisor.Manager.getInstance;
    treeRoots=am.getAllTreeRoot;
    for i=1:numel(treeRoots)
        if isempty(treeRoots{i}.CustomObject)
            AccordionInfoList{end+1}={};%#ok<AGROW>
        else
            AccordionInfoList{end+1}=treeRoots{i}.CustomObject.AccordionInfo;%#ok<AGROW>
        end
    end
    for i=1:numel(treeRoots)
        if~strcmp(this.customTARootID,treeRoots{i}.id)
            Ad=[];
            Ad.icon='';
            Ad.OnGUI=false;
            Ad.visible=false;
            Ad.id=treeRoots{i}.id;
            Ad.DisplayName=treeRoots{i}.DisplayName;
            Ad.Description=treeRoots{i}.Description;
            if~isempty(AccordionInfoList{i})
                Ad.icon=AccordionInfoList{i}.icon;
                Ad.Description=AccordionInfoList{i}.Description;
            end
            cs=getActiveConfigSet(bdroot(this.system));
            if strcmp(treeRoots{i}.id,'com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor')
                Ad.icon=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','UpgradeAdvisor.png');
                Ad.Description=DAStudio.message('ModelAdvisor:engine:UpgradeAdvisorAccordionDescription');
            elseif strcmp(treeRoots{i}.id,'com.mathworks.cgo.group')...
                &&(isa(cs,'Simulink.ConfigSet')||isa(cs,'Simulink.ConfigSetRef'))
                Ad.icon=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','CodeGenAdvisor.png');
                Ad.Description=DAStudio.message('ModelAdvisor:engine:CodeGenAdvisorAccordionDescription');
            end

            if exist(Ad.icon,'file')
                Ad.visible=true;
            end
            AdList=[AdList,Ad];%#ok<AGROW>
        end
    end

    this.advertisements=AdList;
