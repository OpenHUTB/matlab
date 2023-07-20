function out=BuildConfigValues(cs,~,direction,widgetVals)








    cs=cs.getConfigSet;
    adp=configset.internal.getConfigSetAdapter(cs);

    if isempty(adp.toolchainInfo)
        configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
    end

    if direction==0
        bcName=cs.get_param('BuildConfiguration');
        out={bcName,''};
    elseif direction==1
        out=widgetVals{1};
        bcName=out;
    end




    buildConfigList=adp.toolchainInfo.BcList;

    if isempty(bcName)
        bcName=coder.make.internal.getDefaultBuildConfigurationName;
    end
    bcIndex=find(strncmp(bcName,buildConfigList,length(bcName)),1);
    bcFound=~isempty(bcIndex);
    modelSpecific=coder.make.internal.isCustomBuildConfiguration(bcName);

    adp.toolchainInfo.BcFound=bcFound;
    adp.toolchainInfo.ModelSpecific=modelSpecific;


