function WorkDir=getWorkDir(System,varargin)















    if nargin>1
        CustomTARootID=varargin{1};
        if nargin>2
            CheckOnly=varargin{2};
        else
            CheckOnly=true;
        end
    else
        CustomTARootID='_modeladvisor_';
        CheckOnly=true;
    end








    pathArray={};
    systemSID=Simulink.ID.getSID(System);
    subsysIdx=strfind(systemSID,':');
    if isempty(subsysIdx)
        pathArray{1}=strrep(systemSID,':','_');
    else
        subsysIdx=subsysIdx(1);
        pathArray{1}=strrep(systemSID(subsysIdx+1:end),':','_');
        pathArray{2}=strrep(systemSID(1:subsysIdx-1),':','_');
    end


    if~strcmp(CustomTARootID,'_modeladvisor_')&&~isempty(CustomTARootID)
        if strcmp(CustomTARootID,'com.mathworks.FPCA.FixedPointConversionTask')

            pathArray{end+1}='FixPtAdv_';
        elseif strcmp(CustomTARootID,'com.mathworks.HDL.WorkflowAdvisor')
            pathArray{end+1}='HDLAdv_';
        elseif strcmp(CustomTARootID,'com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor')
            pathArray{end+1}='UpgradeAdv_';
        else
            pathArray{end+1}=[escapeAllSpecialCharacters(CustomTARootID),'_'];
        end
    end

    rootBDir=Simulink.fileGenControl('get','CacheFolder');
    needCreateSlprjFolder=true;
    appObj=Advisor.Manager.getActiveApplicationObj();
    variantPath={};
    if isa(appObj,'Advisor.Application')
        appWorkingDir=appObj.WorkingDir;
        if~isempty(appWorkingDir)
            rootBDir=appWorkingDir;
            needCreateSlprjFolder=false;
        end
        variantFolder=appObj.getVariantFolderName;
        if~isempty(variantFolder)
            variantPath={'variants',variantFolder};
        end
    end

    if~CheckOnly
        if needCreateSlprjFolder
            WorkDir=rtwprivate('rtw_create_directory_path',rootBDir,'slprj','modeladvisor',pathArray{end:-1:1},variantPath{:});
        else
            WorkDir=rtwprivate('rtw_create_directory_path',rootBDir,'modeladvisor',pathArray{end:-1:1},variantPath{:});
        end
    else
        if needCreateSlprjFolder
            WorkDir=fullfile(rootBDir,'slprj','modeladvisor',pathArray{end:-1:1},variantPath{:});
        else
            WorkDir=fullfile(rootBDir,'modeladvisor',pathArray{end:-1:1},variantPath{:});
        end
        return
    end
end




function output=escapeAllSpecialCharacters(input)
    output='';
    input=strrep(input,'_','__');
    AtoZand0to9=['_',char(48:57),char(65:90),char(97:122)];
    for i=1:length(input)
        if ismember(input(i),AtoZand0to9)
            output=[output,input(i)];%#ok<AGROW>
        else
            output=[output,'_',sprintf('%x',double(input(i)))];%#ok<AGROW>
        end
    end
end