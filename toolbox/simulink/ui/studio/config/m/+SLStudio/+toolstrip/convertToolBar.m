function convertToolBar(model)

    userPath=userpath();
    toolstripFolder='sl_toolstrip_plugins';
    pluginName='slCustomization';
    matFileName='fhandle.mat';

    SLStudio.toolstrip.createPlugin(pluginName);

    resourceFolder=fullfile(userPath,toolstripFolder,pluginName,pluginName,'resources');
    jsonFileName=fullfile(resourceFolder,'json','customization.json');
    iconFolderName=fullfile(resourceFolder,'icons');
    matFileName=fullfile(resourceFolder,matFileName);


    jsonStr=getJsonString(model,matFileName);


    fid=fopen(jsonFileName,'w');
    fprintf(fid,jsonStr);
    fprintf(fid,'\n');
    fclose(fid);


    icon16pxFile=fullfile(matlabroot,'toolbox','dig','src',...
    'config','custom_16.png');

    icon24pxFile=fullfile(matlabroot,'toolbox','dig','src',...
    'config','custom_24.png');

    copyfile(icon16pxFile,iconFolderName);
    copyfile(icon24pxFile,iconFolderName);


    customizationCallback=fullfile(matlabroot,'toolbox','dig','src',...
    'config','customizationCallback.m');

    copyfile(customizationCallback,fullfile(userPath,toolstripFolder,pluginName,pluginName));

    SLStudio.toolstrip.reload;
end

function jsonStr=getJsonString(model,matFileName)
    jsonStruct=[];
    st=hgetUEStudio(model);
    ts=st.getToolStrip;
    menubarItems=ts.getMenuBar;

    sectionArray=[];
    for i=1:length(menubarItems)
        menubarItem=menubarItems{i};
        if ischar(menubarItem)
            continue;
        end

        sectionStruct.type='Section';
        sectionStruct.name=['convertSection',num2str(i)];
        sectionStruct.label=strrep(menubarItem.label,'&','');

        columnArray=[];
        if isa(menubarItem,'DAStudio.ActionChoiceSchema')
            subItems=ts.getSchemaChildren(menubarItem);

            for j=1:length(subItems)
                subItem=subItems{j};

                if ischar(subItem)
                    continue;
                end

                if strcmp(class(subItem),'DAStudio.ContainerSchema')==1 %#ok
                    columnStruct.type='Column';
                    columnStruct.name=[sectionStruct.name,':column',num2str(j)];

                    dropdownButton.type='DropDownButton';
                    dropdownButton.name=[columnStruct.name,':dropdownbutton',num2str(j)];
                    dropdownButton.enabled=true;
                    dropdownButton.path16px='custom_16.png';
                    dropdownButton.path24px='custom_24.png';
                    dropdownButton.text=subItem.label;

                    columnStruct.children{1}=dropdownButton;

                elseif strcmp(class(subItem),'DAStudio.ActionSchema')==1 %#ok
                    columnStruct.type='Column';
                    columnStruct.name=[sectionStruct.name,':column',num2str(j)];

                    pushButton.type='PushButton';
                    pushButton.name=[columnStruct.name,':pushbutton',num2str(j)];
                    pushButton.enabled=true;
                    pushButton.path16px='custom_16.png';
                    pushButton.path24px='custom_24.png';
                    pushButton.text=subItem.label;
                    pushButton.callback='customizationCallback';
                    pushButton.userdata=subItem.userdata;

                    columnStruct.children{1}=pushButton;

                    if~isempty(matFileName)
                        callback=strrep([subItem.userdata,':cb'],':','_');
                        eval([callback,' = ','subItem.callback;']);
                        if exist(matFileName,'file')
                            save(matFileName,callback,'-append');
                        else
                            save(matFileName,callback);
                        end
                    end

                end

                columnArray{end+1}=columnStruct;
            end

            sectionStruct.children=columnArray;

            sectionArray{end+1}=sectionStruct;
        end
    end

    if isempty(sectionArray)
        jsonStruct=[];
        return;
    end

    tabStruct.type='Tab';
    tabStruct.name='ConvertTab';
    tabStruct.label='SLCustomization Tab';
    tabStruct.parentName='customTabGroup';
    tabStruct.children=sectionArray;

    jsonStruct.packageUris='[]';
    jsonStruct.version='1.0';
    jsonStruct.entries{1}=tabStruct;

    jsonStr=jsonencode(jsonStruct);
end
