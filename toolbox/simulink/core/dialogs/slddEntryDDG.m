function[dlgstruct,clientCallbacks,entryValue]=slddEntryDDG(...
    dlgSource,entryName,entryValue,entryValueIsMxArray,resolvedEntryValue)








    resolved_dlgstruct=[];
    if entryValueIsMxArray

        dlgstruct=da_mxarray_get_schema(dlgSource);

        if slfeature('SLDataDictionaryVariants')&&~isempty(resolvedEntryValue)
            resolved_dlgstruct=da_mxarray_get_schema(resolvedEntryValue);
        end
    else
        if isa(entryValue,'Simulink.data.dictionary.EnumTypeDefinition')
            dlgstruct=Simulink.dd.enumtypeddg(dlgSource,entryValue,entryName);
        else

            if(slfeature('SLDataDictionaryDuplicateMode')>0)&&...
                (slfeature('SLDataDictionarySingleTopModelInClosure')>0)&&...
                isa(entryValue,'Simulink.Bus')


                entryFilespec=loc_getFilespecForEntry(dlgSource);
                assert(~isempty(entryFilespec));
                slprivate('slUpdateDataTypeListSource','set',Simulink.dd.open(entryFilespec));
            else
                slprivate('slUpdateDataTypeListSource','set',dlgSource.m_ddConn);
            end

            if isa(entryValue,'Simulink.ConfigSet')||...
                isa(entryValue,'Simulink.ConfigSetRef')
                hController=entryValue.getDialogController;



                hController.DataDictionary=loc_getFilespecForEntry(dlgSource);
            end

            try
                if isa(entryValue,'Simulink.VariantConfigurationData')
                    entryValue.DataDictionaryName=dlgSource.m_originalDataSource;
                    entryValue.DataDictionarySection=dlgSource.m_scope;
                end
                if((slfeature('EnableStoredIntMinMax')>0)&&(isa(entryValue,'Simulink.Parameter')||isa(entryValue,'Simulink.Signal')))
                    try


                        dd=Simulink.data.dictionary.open(dlgSource.m_originalDataSource);
                        if isa(entryValue,'Simulink.Signal')
                            type='signal';
                        else
                            type='data';
                        end
                        if(slfeature('CalibrationWorkflowInDD')>0)&&...
                            (isa(entryValue,'Simulink.Parameter'))&&...
                            ~isempty(dlgSource.m_ddConn.getOverrideValue(entryName))

                            dlgstruct=dataddg(entryValue,entryName,'data',...
                            dd.getSection(dlgSource.m_scope),...
                            'OverrideValue',dlgSource.m_ddConn.getOverrideValue(entryName));
                        else
                            dlgstruct=dataddg(entryValue,entryName,type,dd.getSection(dlgSource.m_scope));
                        end
                    catch ME
                        assert(strcmp(ME.identifier,'SLDD:sldd:OpenFailed'))

                        dlgstruct=entryValue.getDialogSchema(entryName);
                    end
                elseif((slfeature('EnableStoredIntMinMax')>1)&&...
                    (isa(entryValue,'Simulink.LookupTable')||isa(entryValue,'Simulink.Breakpoint')))
                    try
                        dd=Simulink.data.dictionary.open(dlgSource.m_originalDataSource);
                        if isa(entryValue,'Simulink.LookupTable')
                            dlgstruct=lookuptableddg(entryValue,entryName,dd.getSection(dlgSource.m_scope),dlgSource.m_originalDataSource);
                        else
                            dlgstruct=breakpointobjectddg(entryValue,entryName,dd.getSection(dlgSource.m_scope));
                        end
                    catch ME
                        assert(strcmp(ME.identifier,'SLDD:sldd:OpenFailed'))

                        dlgstruct=entryValue.getDialogSchema(entryName);
                    end
                else
                    if(slfeature('CalibrationWorkflowInDD')>0)&&...
                        (isa(entryValue,'Simulink.Parameter'))&&...
                        ~isempty(dlgSource.m_ddConn.getOverrideValue(entryName))

                        dlgstruct=dataddg(entryValue,entryName,'data',...
                        'OverrideValue',dlgSource.m_ddConn.getOverrideValue(entryName));
                    else
                        dlgstruct=entryValue.getDialogSchema(entryName);
                    end
                end
                if slfeature('SLDataDictionaryVariants')&&~isempty(resolvedEntryValue)
                    resolved_dlgstruct=resolvedEntryValue.getDialogSchema(entryName);
                end
            catch

                dlgstruct=get_object_default_ddg(dlgSource,entryName,entryValue);
            end

            slprivate('slUpdateDataTypeListSource','clear');
        end
    end
    objGrp.Name='';
    objGrp.Type='group';
    objGrp.Items=dlgstruct.Items;
    objGrp.RowSpan=[1,1];
    objGrp.ColSpan=[1,2];
    if isfield(dlgstruct,'LayoutGrid')
        objGrp.LayoutGrid=dlgstruct.LayoutGrid;
    end
    if isfield(dlgstruct,'RowStretch')
        objGrp.RowStretch=dlgstruct.RowStretch;
    end
    if isfield(dlgstruct,'ColStretch')
        objGrp.ColStretch=dlgstruct.ColStretch;
    end
    if slfeature('SLDataDictionaryVariants')&&~isempty(resolved_dlgstruct)
        resolved_objGrp.Name='';
        resolved_objGrp.Type='group';
        resolved_objGrp.Items=resolved_dlgstruct.Items;
        resolved_objGrp.RowSpan=[1,1];
        resolved_objGrp.ColSpan=[1,2];
        if isfield(resolved_dlgstruct,'LayoutGrid')
            resolved_objGrp.LayoutGrid=resolved_dlgstruct.LayoutGrid;
        end
        if isfield(resolved_dlgstruct,'RowStretch')
            resolved_objGrp.RowStretch=resolved_dlgstruct.RowStretch;
        end
        if isfield(resolved_dlgstruct,'ColStretch')
            resolved_objGrp.ColStretch=resolved_dlgstruct.ColStretch;
        end
    else
        resolved_objGrp=objGrp;
    end







    dataSource.Name=DAStudio.message('Simulink:dialog:DictionaryEntryDataSource');
    dataSource.RowSpan=[1,1];
    dataSource.ColSpan=[1,1];
    dataSource.Type='combobox';
    dataSource.Editable=false;
    dataSource.Entries=loc_getDataSourceEntries(dlgSource);
    dataSource.Tag='DataSource_tag';
    dataSource.ObjectProperty='DataSource';
    dataSource.Mode=1;
    dataSource.Value=dlgSource.m_entryInfo.DataSource;

    lastModStr=Simulink.dd.private.convertISOTimeToLocal(...
    dlgSource.m_entryInfo.LastModified);
    statusTextStr=DAStudio.message(...
    'Simulink:dialog:DictionaryEntryModification',...
    dlgSource.m_entryInfo.LastModifiedBy,...
    lastModStr);
    if~isempty(dlgSource.m_entryInfo.Status)
        statusTextStr=[statusTextStr,' ('...
        ,dlgSource.m_entryInfo.Status,')'];
    end
    statusText.Name=statusTextStr;
    statusText.Type='text';
    statusText.RowSpan=[2,2];
    statusText.ColSpan=[1,2];
    statusText.Tag='StatusText';

    rowIdx=2;
    entryMetadataGrp.Name='';
    entryMetadataGrp.Type='group';
    if slfeature('SLDataDictionaryVariants')&&~isempty(dlgSource.m_entryInfo.Variant)
        variantCondition.Name='Variant condition:';
        variantCondition.Type='edit';
        variantCondition.Value=dlgSource.m_entryInfo.Variant;
        variantCondition.Enabled=true;
        variantCondition.RowSpan=[rowIdx,rowIdx];
        variantCondition.ColSpan=[1,1];
        variantCondition.Tag='Variant';
        variantCondition.ObjectProperty='Variant';

        rowIdx=rowIdx+1;
        statusText.RowSpan=[rowIx,rowIdx];

        entryMetadataGrp.Items={dataSource,variantCondition,statusText};
    else
        entryMetadataGrp.Items={dataSource,statusText};
    end

    dd=Simulink.dd.open(dlgSource.m_entryInfo.DataSource);
    isInterfaceDictionary=sl.interface.dict.api.isInterfaceDictionary(dd.filespec);

    if dlgSource.m_ddConn.getIsEntryDerived(dlgSource.m_entryID)


        rowIdx=rowIdx+1;
        derivedText.Name=DAStudio.message('dds:ui:DictionaryEntryDataSource');
        derivedText.Type='text';
        derivedText.RowSpan=[rowIdx,rowIdx];
        derivedText.ColSpan=[1,2];
        derivedText.Tag='DerivedText';
        entryMetadataGrp.Items{numel(entryMetadataGrp.Items)+1}=derivedText;
    elseif isInterfaceDictionary

        rowIdx=rowIdx+1;
        derivedText.Name=DAStudio.message('interface_dictionary:common:ManagedByInterfaceDictionary');
        derivedText.Type='text';
        derivedText.RowSpan=[rowIdx,rowIdx];
        derivedText.ColSpan=[1,2];
        derivedText.Tag='DerivedText';
        entryMetadataGrp.Items{numel(entryMetadataGrp.Items)+1}=derivedText;

        rowIdx=rowIdx+1;
        openItfDictHyperlink.Name=DAStudio.message('interface_dictionary:common:ShowEntryInItfDictionary');
        openItfDictHyperlink.Type='hyperlink';
        openItfDictHyperlink.RowSpan=[rowIdx,rowIdx];
        openItfDictHyperlink.ColSpan=[1,2];
        openItfDictHyperlink.Tag='OpenItfDictHyperlink';
        openItfDictHyperlink.MatlabMethod='sl.interface.dictionaryApp.utils.showEntryByName';
        openItfDictHyperlink.MatlabArgs={entryName,dd.filespec};
        entryMetadataGrp.Items{numel(entryMetadataGrp.Items)+1}=openItfDictHyperlink;
    end

    entryMetadataGrp.LayoutGrid=[2,2];
    entryMetadataGrp.RowSpan=[2,2];
    entryMetadataGrp.ColSpan=[1,2];






    tabctrl=[];
    if slfeature('SLDataDictionaryVariants')>1
        spreadsheet.Type='spreadsheet';
        spreadsheet.Source=dlgSource;
        spreadsheet.WidgetId='spreadsheet';
        spreadsheet.Tag='v_spreadsheet';

        tabBase.Tag='tabBase';
        tabBase.WidgetId=tabBase.Tag;

        if~isempty(dlgSource.m_entryInfo.Variant)
            tabBase.Name='Variant';
            tabBase.Items={objGrp,entryMetadataGrp};
            tabVariants.Name='Varied Properties';
            spreadsheet.Columns={'Property','Variant','BaseObject'};
            tabVariants.Items={spreadsheet,entryMetadataGrp};

            tabctrl.Tabs={tabBase,tabVariants};
        else
            tabResolved.Name='Resolved';
            tabResolved.Items={resolved_objGrp};
            tabResolved.Source=resolvedEntryValue;

            tabBase.Name='Base';
            tabBase.Items={objGrp,entryMetadataGrp};

            tabVariants.Name='Variants';
            [hasVariants,spreadsheet.Columns]=loc_getVariedProperties(dlgSource);
            spreadsheet.RowSpan=[2,2];
            spreadsheet.ColSpan=[1,3];

            createBtn.Name='Create variant';
            createBtn.Type='pushbutton';
            createBtn.RowSpan=[1,1];
            createBtn.ColSpan=[1,1];
            createBtn.DialogRefresh=true;
            createBtn.Tag='CreateVariant';
            createBtn.WidgetId=createBtn.Tag;
            createBtn.ObjectMethod='AddVariant';
            createBtn.MethodArgs={'%dialog'};
            createBtn.ArgDataTypes={'handle'};
            createBtn.Enabled=true;

            tabVariants.ColStretch=[1,1,2];
            tabVariants.LayoutGrid=[3,3];

            tabVariants.Items={createBtn,spreadsheet};

            if hasVariants
                tabctrl.Tabs={tabBase,tabVariants,tabResolved};
            else
                tabctrl.Tabs={tabBase,tabVariants};
            end
        end

        tabctrl.Type='tab';
        tabctrl.Tag='Tabctrl';
        tabctrl.WidgetId=tabctrl.Tag;
    end

    if~isempty(tabctrl)
        dlgstruct.Items={tabctrl};
    else
        dlgstruct.Items={objGrp,entryMetadataGrp};
    end

    dlgstruct.LayoutGrid=[2,2];
    dlgstruct.RowStretch=[0,0];
    dlgstruct.ColStretch=[0,0];



    assert(~isfield(dlgstruct,'PreApplyMethod'));
    assert(~isfield(dlgstruct,'PostApplyMethod'));
    assert(~isfield(dlgstruct,'CloseMethod'));
    assert(~isfield(dlgstruct,'PostRevertMethod'));
    assert(~isfield(dlgstruct,'Source'),DAStudio.message('SLDD:sldd:DialogSourceNotSupported'));



    clientCallbacks=[];
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('PreApplyCallback',dlgstruct,clientCallbacks);
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('PreApplyArgs',dlgstruct,clientCallbacks);
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('PostApplyCallback',dlgstruct,clientCallbacks);
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('PostApplyArgs',dlgstruct,clientCallbacks);
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('CloseCallback',dlgstruct,clientCallbacks);
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('CloseArgs',dlgstruct,clientCallbacks);
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('PostRevertCallback',dlgstruct,clientCallbacks);
    [dlgstruct,clientCallbacks]=...
    loc_captureCallbackField('PostRevertArgs',dlgstruct,clientCallbacks);

    dlgstruct.PreApplyMethod='preApply';
    dlgstruct.PreApplyArgs={'%dialog','%source'};
    dlgstruct.PreApplyArgsDT={'handle','handle'};

    dlgstruct.PostApplyMethod='postApply';
    dlgstruct.PostApplyArgs={'%dialog','%source'};
    dlgstruct.PostApplyArgsDT={'handle','handle'};

    dlgstruct.CloseMethod='close';
    dlgstruct.CloseMethodArgs={'%dialog','%source'};
    dlgstruct.CloseMethodArgsDT={'handle','handle'};

    dlgstruct.PostRevertMethod='postRevert';
    dlgstruct.PostRevertArgs={'%dialog','%source'};
    dlgstruct.PostRevertArgsDT={'handle','handle'};

end

function[dlgstruct,clientCallbacks]=loc_captureCallbackField(...
    callbackFieldName,dlgstruct,clientCallbacks)
    if isfield(dlgstruct,callbackFieldName)
        clientCallbacks.(callbackFieldName)=dlgstruct.(callbackFieldName);
        dlgstruct=rmfield(dlgstruct,callbackFieldName);
    end
end

function entrieslist=loc_getDataSourceEntries(dlgSource)
    dependencies=dlgSource.m_ddConn.DependencyClosure;

    [~,filename,fileext]=fileparts(dlgSource.m_ddConn.filespec);
    thisDict=[filename,fileext];

    foundThisDict=false;
    foundThisSource=false;

    entrieslist={};
    for idx=1:length(dependencies)
        [~,filename,fileext]=fileparts(dependencies{idx});
        entrieslist{idx}=[filename,fileext];
        if isequal(entrieslist{idx},thisDict)
            foundThisDict=true;
        end
        if isequal(entrieslist{idx},dlgSource.m_entryInfo.DataSource)
            foundThisSource=true;
        end
    end


    if~foundThisSource
        entrieslist{end+1}=dlgSource.m_entryInfo.DataSource;
    end
    if~foundThisDict&&~isequal(thisDict,dlgSource.m_entryInfo.DataSource)
        entrieslist{end+1}=thisDict;
    end

    entrieslist=sort(entrieslist);
end


function[hasVariants,variedPropsList]=loc_getVariedProperties(dlgSource)
    variedPropsList={'VariantCondition','Value'};



    ddOld=Simulink.dd.open(dlgSource.m_originalDataSource);
    if ddOld.entryExists([dlgSource.m_scope,'.',dlgSource.m_entryInfo.Name],false)
        dd=Simulink.data.dictionary.open(dlgSource.m_originalDataSource);
        scope=dd.getSection(dlgSource.m_scope);
        try
            allVariants=scope.getEntry(dlgSource.m_entryInfo.Name);
        catch
            allVariants={};
        end
    else
        allVariants={};
    end

    hasVariants=false;
    count=length(allVariants);
    for idx=1:count
        entry=allVariants(idx).getValue();
        if isa(entry,'Simulink.dd.DataVariant')
            if~isempty(entry.m_variantProps)
                variedPropsList=[variedPropsList,fieldnames(entry.m_variantProps)'];
            end
            hasVariants=true;
        end
    end

    variedPropsList=[' ',variedPropsList,{'Status','DataSource','LastModified','LastModifiedBy'}];
    variedPropsList=unique(variedPropsList,'stable');
end



function entryFilespec=loc_getFilespecForEntry(dlgSource)
    entryFilespec='';
    dependencies=dlgSource.m_ddConn.DependencyClosure;
    entryDataSource=dlgSource.m_entryInfo.DataSource;
    for idx=1:length(dependencies)
        [~,filename,fileext]=fileparts(dependencies{idx});
        currDict=[filename,fileext];
        if isequal(entryDataSource,currDict)
            entryFilespec=dependencies{idx};
            break;
        end
    end
end


