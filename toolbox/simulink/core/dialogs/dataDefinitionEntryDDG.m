function[dlgstruct,clientCallbacks,entryValue]=dataDefinitionEntryDDG(...
    dlgSource,entryName,entryValue,entryValueIsMxArray,source,section)








    resolved_dlgstruct=[];
    if entryValueIsMxArray

        dlgstruct=da_mxarray_get_schema(dlgSource);
    else
        if isa(entryValue,'Simulink.data.dictionary.EnumTypeDefinition')
            dlgstruct=Simulink.dd.enumtypeddg(dlgSource,entryValue,entryName);
        else
            try
                if isa(entryValue,'Simulink.VariantConfigurationData')
                    entryValue.DataDictionaryName=dlgSource.m_originalDataSource;
                    entryValue.DataDictionarySection=dlgSource.m_scope;
                end
                if((slfeature('EnableStoredIntMinMax')>0)&&(isa(entryValue,'Simulink.Parameter')||isa(entryValue,'Simulink.Signal')))
                    try
                        if isa(entryValue,'Simulink.Signal')
                            type='signal';
                        else
                            type='data';
                        end
                        dlgstruct=dataddg(entryValue,entryName,type);
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
                    dlgstruct=entryValue.getDialogSchema(entryName);
                end
            catch

                dlgstruct=get_object_default_ddg(dlgSource,entryName,entryValue);
            end
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
    resolved_objGrp=objGrp;






    dataSource.Name=DAStudio.message('Simulink:dialog:DictionaryEntryDataSource');
    dataSource.RowSpan=[1,1];
    dataSource.ColSpan=[1,1];
    dataSource.Type='text';
    dataSource.Editable=false;
    dataSource.Tag='DataSource_tag';



    dataFileName.Name=source;
    dataFileName.RowSpan=[1,1];
    dataFileName.ColSpan=[2,2];
    dataFileName.Type='text';
    dataFileName.Editable=false;
    dataFileName.Tag='DataFileName_tag';


    entryMetadataGrp.Items={dataSource,dataFileName};
    entryMetadataGrp.LayoutGrid=[2,2];
    entryMetadataGrp.RowSpan=[2,2];
    entryMetadataGrp.ColSpan=[1,2];
    entryMetadataGrp.Type='group';





    tabctrl=[];
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



