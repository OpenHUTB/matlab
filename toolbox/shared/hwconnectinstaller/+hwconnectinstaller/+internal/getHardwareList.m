function[hardwareList,hardwareIndexList,spNum]=getHardwareList(packageInfo,filter)






    hardwareList=[];
    hardwareIndexList=[];
    spNum=[];

    if isfield(packageInfo,'DisplayName')...
        &&isfield(packageInfo,'InstalledVersion')...
        &&isfield(packageInfo,'Action')...
        &&isfield(packageInfo,'PackageIsSelectable')


        allSpNum=0;
        installableSpNum=0;
        installedSpNum=0;
        updatableSpNum=0;

        for i=1:numel(packageInfo)
            if packageInfo(i).PackageIsSelectable
                installableSpNum=installableSpNum+1;
            end
            if~isempty(packageInfo(i).InstalledVersion)
                installedSpNum=installedSpNum+1;
            end
            if isequal(packageInfo(i).Action,DAStudio.message('hwconnectinstaller:setup:SelectPackage_Update'))
                updatableSpNum=updatableSpNum+1;
            end
            allSpNum=allSpNum+1;
        end
        spNum=[allSpNum,installableSpNum,installedSpNum,updatableSpNum];







        switch filter
        case 0,
            hardwareList=unique({packageInfo.DisplayName},'stable');

            dName={packageInfo.DisplayName};
            for i=1:numel(hardwareList)
                hardwareIndexList{end+1}=find(ismember(dName,hardwareList{i})==1);
            end
        case 1,
            for i=1:numel(packageInfo)
                if packageInfo(i).PackageIsSelectable
                    if ismember(packageInfo(i).DisplayName,hardwareList)
                        [~,idx]=ismember(packageInfo(i).DisplayName,hardwareList);
                        hardwareIndexList{idx}=[hardwareIndexList{idx},i];
                    else
                        hardwareList{end+1}=packageInfo(i).DisplayName;
                        hardwareIndexList{end+1}=i;
                    end
                end
            end
        case 2,
            for i=1:numel(packageInfo)
                if~isempty(packageInfo(i).InstalledVersion)
                    if ismember(packageInfo(i).DisplayName,hardwareList)
                        [~,idx]=ismember(packageInfo(i).DisplayName,hardwareList);
                        hardwareIndexList{idx}=[hardwareIndexList{idx},i];
                    else
                        hardwareList{end+1}=packageInfo(i).DisplayName;
                        hardwareIndexList{end+1}=i;
                    end
                end
            end
        case 3,
            for i=1:numel(packageInfo)
                if isequal(packageInfo(i).Action,DAStudio.message('hwconnectinstaller:setup:SelectPackage_Update'))
                    if ismember(packageInfo(i).DisplayName,hardwareList)
                        [~,idx]=ismember(packageInfo(i).DisplayName,hardwareList);
                        hardwareIndexList{idx}=[hardwareIndexList{idx},i];
                    else
                        hardwareList{end+1}=packageInfo(i).DisplayName;
                        hardwareIndexList{end+1}=i;
                    end
                end
            end
        otherwise,
            error(message('hwconnectinstaller:setup:SelectPackage_Filter_WrongOption'))
        end
    end
