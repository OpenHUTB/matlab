function[blockGroups,filteredProperties,errorCaught]=getBlockPropertyGroups(systemName,inputs)






    try
        hasPropertyGroupsArgument=~isempty(inputs.PropertyGroupsArgument);
        if hasPropertyGroupsArgument
            groups=feval([systemName,'.getDisplayPropertyGroups'],systemName,inputs.PropertyGroupsArgument);
        else
            groups=eval([systemName,'.getDisplayPropertyGroups(''',systemName,''');']);
        end
        errorCaught=false;
    catch e



        if inputs.DefaultIfError
            groups=matlab.system.display.internal.getDefaultPropertyGroups(systemName);
            errorCaught=true;
        else
            rethrow(e)
        end
    end


    simUsingSection=getSimulateUsingGroup(systemName);


    sections=matlab.system.display.Section.empty;
    sectionGroups=matlab.system.display.SectionGroup.empty;
    foundFirstSectionGroup=false;
    foundDataTypesGroup=false;
    filteredProperties=matlab.system.display.internal.Property.empty;
    sysMetaClass=meta.class.fromName(systemName);
    for group=groups

        [group,groupFilteredProperties]=filterBlockPropertyList(group,sysMetaClass);%#ok<FXSET>
        filteredProperties=[filteredProperties,groupFilteredProperties];

        if isa(group,'matlab.system.display.SectionGroup')

            for section=group.Sections
                [section,sectionFilteredProperties]=filterBlockPropertyList(section,sysMetaClass);%#ok<FXSET>
                filteredProperties=[filteredProperties,sectionFilteredProperties];
            end


            if~foundFirstSectionGroup
                foundFirstSectionGroup=true;
                group.Sections=[group.Sections,simUsingSection];
            end
            sectionGroups(end+1)=group;%#ok<*AGROW>
        elseif isa(group,'matlab.system.display.internal.DataTypesGroup')
            foundDataTypesGroup=true;
            sectionGroups(end+1)=getBlockDataTypesGroup(group,sysMetaClass);
        else
            sections(end+1)=group;
        end
    end


    if~foundFirstSectionGroup
        sections(end+1)=simUsingSection;
    end


    if hasFiSettings(systemName)

        if foundDataTypesGroup
            warning(message('MATLAB:system:ShowFiSettingsErrorWithDataTypeGroup'));
        end


        if isempty(sectionGroups)&&~isempty(sections)
            sectionGroups(end+1)=matlab.system.display.SectionGroup(...
            'Sections',sections,...
            'TitleSource','Auto');
            sections=matlab.system.display.Section.empty;
        end

        sectionGroups(end+1)=getFiSettingsGroup(systemName);
    end


    blockGroups=[sections,sectionGroups];
end

function hasFi=hasFiSettings(systemName)
    try
        hasFi=feval([systemName,'.showFiSettings'],systemName);
    catch
        hasFi=false;
    end
end

function[group,filteredProperties]=filterBlockPropertyList(group,sysMetaClass)

    filteredProperties=matlab.system.display.internal.Property.empty;
    propertyList={};
    for property=group.getDisplayProperties(sysMetaClass)


        if property.IsFacade
            continue;
        end



        if property.IsDependent||property.IsObjectDisplayOnly||...
            matlab.system.ui.ParamUtils.isReservedParameterName(property.Name)
            filteredProperties(end+1)=property;
        else
            propertyList{end+1}=property;
        end
    end


    group.PropertyList=propertyList;
end

function simUsingGroup=getSimulateUsingGroup(systemName)
    try
        simUsing=feval([systemName,'.getSimulateUsing'],systemName);
    catch e
        warning(message('SystemBlock:MATLABSystem:GetSimulateUsingErrorOnMaskUpdate',systemName,e.message));
        simUsing=matlab.system.ui.ParamUtils.SimulateUsingParameterValues;
    end
    if numel(simUsing)>1
        simUsingDefault='Code generation';
        isReadOnly=false;
    else
        simUsingDefault=simUsing{1};
        isReadOnly=true;
    end


    if hasFiSettings(systemName)
        if strcmpi(simUsingDefault,'Interpreted execution')
            warning(message('MATLAB:system:SimulateUsingErrorWithFiSettings'));
            simUsingDefault='Code generation';
        end
        isReadOnly=true;
    end

    try
        simUsingVis=feval([systemName,'.showSimulateUsing'],systemName);
    catch e
        warning(message('SystemBlock:MATLABSystem:ShowSimulateUsingErrorOnMaskUpdate',systemName,e.message));
        simUsingVis=true;
    end

    simUsingProperty=matlab.system.display.internal.Property('SimulateUsing',...
    'IsFacade',true,...
    'Description','SystemBlock:MATLABSystem:SimulateUsing',...
    'TooltipText','SystemBlock:MATLABSystem:SimulateUsingDescription',...
    'IsHidden',~simUsingVis,...
    'IsReadOnly',isReadOnly,...
    'IsStringSet',true,...
    'StringSetValues',matlab.system.ui.ParamUtils.SimulateUsingStringSetValues,...
    'UseClassDefault',false,...
    'Default',simUsingDefault);

    simUsingGroup=matlab.system.display.Section(...
    'PropertyList',{simUsingProperty},...
    'Title','SimulationOptionsGroup',...
    'Type',matlab.system.display.SectionType.panel);
end

function group=getFiSettingsGroup(systemName)


    saturateProperty=matlab.system.display.internal.Property('SaturateOnIntegerOverflow',...
    'IsFacade',true,...
    'Description',message('SystemBlock:MATLABSystem:SaturateOnIntegerOverflow').getString,...
    'IsLogical',true,...
    'IsReadOnly',false,...
    'UseClassDefault',false,...
    'Default','on');


    fiSettings=feval([systemName,'.getFiSettings'],systemName);
    treatAsFi=fiSettings.TreatAsFi;
    treatAsFiProperty=matlab.system.display.internal.Property('TreatAsFi',...
    'IsFacade',true,...
    'Description',message('SystemBlock:MATLABSystem:TreatAsFi').getString,...
    'IsStringSet',true,...
    'IsStringLiteral',false,...
    'IsReadOnly',false,...
    'UseClassDefault',false,...
    'Default',treatAsFi{1},...
    'StringSetValues',matlab.system.ui.ParamUtils.TreatAsFiStringSetValues);


    blockDefaultFiMathProperty=matlab.system.display.internal.Property('BlockDefaultFimath',...
    'IsFacade',true,...
    'Description',message('SystemBlock:MATLABSystem:BlockDefaultFimath').getString,...
    'IsStringSet',true,...
    'IsStringLiteral',false,...
    'IsReadOnly',false,...
    'UseClassDefault',false,...
    'Default','Same as MATLAB',...
    'WidgetType',matlab.system.display.internal.WidgetType.radiobutton,...
    'StringSetValues',matlab.system.ui.ParamUtils.BlockDefaultFimathStringSetValues);


    inputFiMathProperty=matlab.system.display.internal.Property('InputFimath',...
    'IsFacade',true,...
    'Description',message('SystemBlock:MATLABSystem:InputFimath').getString,...
    'IsStringLiteral',true,...
    'IsReadOnly',false,...
    'UseClassDefault',false,...
    'WidgetType',matlab.system.display.internal.WidgetType.textarea,...
    'Default',sprintf('%s\n%s\n%s\n%s',...
    'fimath(''RoundingMethod'',''Nearest'', ...',...
    '''OverflowAction'',''Saturate'', ...',...
    '''ProductMode'',''FullPrecision'', ...',...
    '''SumMode'',''FullPrecision'')'));

    group=matlab.system.display.SectionGroup(...
    'IsFiSettings',true,...
    'PropertyList',{saturateProperty,treatAsFiProperty,blockDefaultFiMathProperty,inputFiMathProperty},...
    'Title',message('SystemBlock:MATLABSystem:SystemBlockDialogDataTypesSectionGroupTitle').getString);
end

function group=getBlockDataTypesGroup(group,sysMetaClass)
    propertyList={};
    for property=group.getDisplayProperties(sysMetaClass)
        propertyList{end+1}=property;


        if property.isDataTypeProperty()&&property.IsDataType
            dtSet=property.DataTypeSet;
            prefix=property.Prefix;

            if dtSet.HasDesignMinimum
                dMinProp=matlab.system.display.internal.DataTypeProperty([prefix,'Min'],...
                'Prefix',prefix,...
                'Description',[property.Description,' minimum']);
                dMinProp.setIsDesignMin(property.Name,dtSet);
                propertyList{end+1}=dMinProp;
            end
            if dtSet.HasDesignMaximum
                dMaxProp=matlab.system.display.internal.DataTypeProperty([prefix,'Max'],...
                'Prefix',prefix,...
                'Description',[property.Description,' maximum']);
                dMaxProp.setIsDesignMax(property.Name,dtSet);
                propertyList{end+1}=dMaxProp;
            end
        end
    end


    lockScaleProp=matlab.system.display.internal.DataTypeProperty('LockScale');
    lockScaleProp.setIsLockScale;
    propertyList{end+1}=lockScaleProp;

    group.PropertyList=propertyList;
end
