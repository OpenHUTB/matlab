function dtItems=getDataTypeAllowedItems(dtCaps,hProxy)







    if(isa(hProxy,'Simulink.SlidDAProxy'))
        slidObject=hProxy.getObject();
        hCaller=slidObject.WorkspaceObjectSharedCopy;
    else
        hCaller=hProxy;
    end

    dtCaps=setDefaultDtaItems(dtCaps);



    dtCaps.isAliasObject=isa(hCaller,'Simulink.AliasType');

    dtItems=getStandardDataTypeAllowedItems(dtCaps);


    filter.supportNumeric=0;
    filter.supportBus=0;
    filter.supportEnum=0;

    customBusFeatureOn=(slfeature('CUSTOM_BUSES')==1);
    serviceBusFeatureOn=(slfeature('ClientServerInterfaceEditor')==1);
    if customBusFeatureOn
        filter.supportConnectionBus=0;
    end
    if serviceBusFeatureOn
        filter.supportServiceBus=0;
    end
    if slfeature('SLValueType')==1
        filter.supportValueType=0;
    end
    filter.supportAlias=0;


    if dtCaps.allowsExpression
        filter.supportNumeric=1;
    end
    if dtCaps.supportsBusType
        filter.supportBus=1;
    end
    if customBusFeatureOn&&dtCaps.supportsConnectionBusType
        filter.supportConnectionBus=1;
    end

    if serviceBusFeatureOn&&dtCaps.supportsServiceBusType
        filter.supportServiceBus=1;
    end
    if slfeature('SLValueType')==1&&dtCaps.supportsValueTypeType
        filter.supportValueType=1;
    end

    if dtCaps.supportsEnumType
        filter.supportEnum=1;
    end
    if dtCaps.allowsExpression
        filter.supportAlias=2;
    end


    [dtvarnames,dtmark]=slprivate('slGetUserDataTypesFromWSDD',hProxy,filter,dtCaps);
    if~isempty(dtvarnames)
        if dtmark.hasBus

            [hasBusTemplate,idx]=ismember('Bus: <object name>',dtItems);
            if hasBusTemplate
                dtItems(idx)=[];
            end
        end
        if customBusFeatureOn&&dtmark.hasConnectionBus

            [hasConnectionBusTemplate,idx]=ismember('Bus: <object name>',dtItems);
            if hasConnectionBusTemplate
                dtItems(idx)=[];
            end
        end
        if serviceBusFeatureOn&&dtmark.hasServiceBus

            [hasServiceBusTemplate,idx]=ismember('Bus: <object name>',dtItems);
            if hasServiceBusTemplate
                dtItems(idx)=[];
            end
        end
        if slfeature('SLValueType')==1&&dtmark.hasValueType

            [hasValueTypeTemplate,idx]=ismember('ValueType: <object name>',dtItems);
            if hasValueTypeTemplate
                dtItems(idx)=[];
            end
        end
        if dtmark.hasEnum

            [hasEnumTemplate,idx]=ismember('Enum: <class name>',dtItems);
            if hasEnumTemplate
                dtItems(idx)=[];
            end
        end
        dtItems=[dtItems,dtvarnames];
    end
    if customBusFeatureOn&&dtCaps.supportsConnectionType
        physmodDoms=[];



        if Simulink.internal.isSimscapeInstalledAndLicensed
            physmodDoms=simscape.internal.availableDomains();
            physmodDoms=cellfun(@(elem)['Connection: ',elem],physmodDoms,'UniformOutput',false);
        end
        dtItems=[dtItems,physmodDoms(:)'];
    end













    function dtItems=getStandardDataTypeAllowedItems(dtCaps)

        dtItems=dtCaps.inheritRules;
        builtinTypes=dtCaps.builtinTypes;

        filteredTypes=filterBuiltInDataTypes(builtinTypes);
        dtItems={dtItems{:},filteredTypes{:}};%#ok<CCAT>



        if~isempty(dtCaps.scalingModes)
            switch dtCaps.signModes{1}
            case 'UDTSignedSign'
                field_sign='1';
            case 'UDTUnsignedSign'
                field_sign='0';
            case 'UDTInheritSign'
                field_sign='[]';
            end

            if isempty(dtCaps.tattoos.wordLength)
                field_wl='16';
            else
                field_wl=dtCaps.tattoos.wordLength;
            end
            if isempty(dtCaps.tattoos.fractionLength)
                field_fl='0';
            else
                field_fl=dtCaps.tattoos.fractionLength;
            end
            if isempty(dtCaps.tattoos.slope)
                field_slope='2^0';
            else
                field_slope=dtCaps.tattoos.slope;
            end
            if isempty(dtCaps.tattoos.bias)
                field_bias='0';
            else
                field_bias=dtCaps.tattoos.bias;
            end

            if any(strcmp(dtCaps.scalingModes,'UDTIntegerMode')|...
                strcmp(dtCaps.scalingModes,'UDTBestPrecisionMode'))
                dtItems{end+1}=['fixdt(',field_sign,',',field_wl,')'];
            end

            if any(strcmp(dtCaps.scalingModes,'UDTBinaryPointMode'))
                dtItems{end+1}=['fixdt(',field_sign,',',field_wl,',',field_fl,')'];
            end

            if any(strcmp(dtCaps.scalingModes,'UDTSlopeBiasMode'))
                dtItems{end+1}=['fixdt(',field_sign,',',field_wl,',',field_slope,',',field_bias,')'];
            end
        end

        if dtCaps.supportsStringType
            dtItems{end+1}='string';
        end

        if dtCaps.supportsEnumType
            dtItems{end+1}='Enum: <class name>';
        end

        if dtCaps.supportsBusType
            dtItems{end+1}='Bus: <object name>';
        end

        if slfeature('SupportImageInDTA')==1&&dtCaps.supportsImageDataType
            rows='480';
            cols='640';
            channels='3';
            dtItems{end+1}=['Simulink.ImageType(',rows,',',cols,',',channels,')'];

        end

        if slfeature('CUSTOM_BUSES')==1&&dtCaps.supportsConnectionBusType
            dtItems{end+1}='Bus: <object name>';
        end

        if slfeature('SLValueType')==1&&dtCaps.supportsValueTypeType
            dtItems{end+1}='ValueType: <object name>';
        end
        if dtCaps.allowsExpression
            dtItems{end+1}='<data type expression>';
        end



        dtItems{end+1}=DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace');











        function filteredTypes=filterBuiltInDataTypes(builtInTypes)

            filteredTypes=builtInTypes;
            if slfeature('SLInt64')==0
                filteredTypes(strcmp(filteredTypes,'int64'))=[];
                filteredTypes(strcmp(filteredTypes,'uint64'))=[];
            end


