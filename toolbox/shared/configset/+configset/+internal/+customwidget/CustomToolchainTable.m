function[modelSpecificTable,dscr]=CustomToolchainTable(cs,~)














    dscr='';

    cs=cs.getConfigSet;
    adp=configset.internal.getConfigSetAdapter(cs);


    if isempty(adp.toolchainInfo)
        configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
    end

    if~isfield(adp.toolchainInfo,'BcFound')
        configset.internal.customwidget.BuildConfigValues(cs,'BuildConfiguration',0);
    end

    tc=adp.toolchainInfo.Tc;

    bcName=cs.get_param('BuildConfiguration');
    if isempty(bcName)
        bcName=coder.make.internal.getDefaultBuildConfigurationName;
    end

    if(adp.toolchainInfo.ModelSpecific)
        toolsAndOptions=cs.get_param('CustomToolchainOptions');
    elseif~isempty(tc)
        if adp.toolchainInfo.BcFound
            toolsAndOptions=coder.make.internal.getToolsAndOptionsFromToolchain(tc,bcName);
        else
            toolsAndOptions=coder.make.internal.getToolsAndOptionsFromToolchain(tc);
        end
    else
        toolsAndOptions={'',''};
    end
    assert(mod(length(toolsAndOptions),2)==0);

    numOptions=length(toolsAndOptions)/2;
    modelSpecificData=cell(numOptions,1);
    types=cell(numOptions,1);
    m=1;
    for i=1:numOptions
        modelSpecificData{i,1}=toolsAndOptions{m};
        modelSpecificData{i,2}=toolsAndOptions{m+1};
        types{i,1}='edit';
        types{i,2}='edit';
        m=m+2;
    end

    toolName=configset.internal.getMessage('RTWToolchainBuildConfigurationTool');
    optionsName=configset.internal.getMessage('RTWToolchainBuildConfigurationOptions');

    modelSpecificTable.SelectRow=false;
    modelSpecificTable.Size=[numOptions,2];
    modelSpecificTable.Data=modelSpecificData;
    modelSpecificTable.Types=types;
    modelSpecificTable.RowHeaders=false;
    modelSpecificTable.ColumnHeaders=true;
    modelSpecificTable.ColumnLabels={toolName,optionsName};
    modelSpecificTable.ColumnEditable=[false,true];
    modelSpecificTable.ColumnIDs={'Tool','Options'};
    modelSpecificTable.DisableCompletely=false;


