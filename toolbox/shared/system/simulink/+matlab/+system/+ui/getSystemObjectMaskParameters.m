function[paramStruct,groups]=getSystemObjectMaskParameters(blkH,sysMetaClass,sysObj)




    className=sysMetaClass.Name;


    paramStruct=struct('Name',{},'Alias',{},'Type',{},'Prompt',{},...
    'TypeOptions',{},'Default',{},'Range',{},'Attributes',{},'Row',{});


    ipws=matlab.system.internal.InactiveWarningSuppressor(sysObj);

    [lastwmsg,lastwid]=lastwarn;


    [groups,filteredProperties]=matlab.system.display.internal.Memoizer.getBlockPropertyGroups(className,...
    'DefaultIfError',true);
    dialogProps=matlab.system.ui.getPropertyList(className,groups,...
    'SetDescription',true);


    for filteredProperty=filteredProperties
        if matlab.system.ui.ParamUtils.isReservedParameterName(filteredProperty.Name)
            warning(message('Simulink:blocks:SystemBlockParameterNameClash',...
            getfullname(blkH),filteredProperty.Name));
        elseif filteredProperty.IsDependent&&~filteredProperty.IsObjectDisplayOnly
            warning(message('SystemBlock:MATLABSystem:ParameterCannotBeDependent',...
            className,getfullname(blkH),filteredProperty.Name));
        end
    end

    paramNames={dialogProps.BlockParameterName};

    isLibraryBlock=strcmp(get_param(bdroot(blkH),'BlockDiagramType'),'library');
    isLinkedBlock=~(strcmp(get_param(blkH,'StaticLinkStatus'),'none'));


    for propInd=1:numel(dialogProps)


        property=dialogProps(propInd);
        property.setDefault(sysObj);

        paramStruct=[paramStruct,...
        matlab.system.ui.createMaskParameterStructForSysObjectProperty(blkH,property,className,...
        sysObj,paramNames,propInd,...
        (isLibraryBlock||isLinkedBlock))];
    end


    lastwarn(lastwmsg,lastwid);
end
