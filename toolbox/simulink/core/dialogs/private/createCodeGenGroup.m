function grpCodeGen=createCodeGenGroup(hProxy,groupNameId,tooltipId)




    grpCodeGen.Items={};

    if isa(hProxy,'Simulink.SlidDAProxy')
        hSlidObject=hProxy.getObject();
        h=hSlidObject.WorkspaceObjectSharedCopy;
        if isempty(h)
            return;
        end
        ownedByModel=true;
    else
        h=hProxy;
        ownedByModel=false;
    end

    coderInfo=h.CoderInfo;
    storageClass=coderInfo.StorageClass;
    props=Simulink.data.getPropList(coderInfo,'GetAccess','public');
    numItems=1;
    immediateMode=true;
    wid=[];
    wid.RowSpan=[numItems,numItems];
    wid.ColSpan=[1,2];
    wid.Source=h;
    wid.Type='combobox';
    wid.ObjectProperty='StorageClass';
    wid.Tag='StorageClass';
    wid.Entries=h.getPropAllowedValues('StorageClass');
    if strcmp(hProxy.getPropValue('Argument'),'on')
        wid.Entries={'Auto','Model default'};
    end
    wid.Name=DAStudio.message('Simulink:dialog:DataStorageClassPrompt');
    if(slfeature('ModelOwnedDataIM')>0&&ownedByModel)
        wid.Source=hProxy;
        wid.Entries=hProxy.getPropAllowedValues('StorageClass');
    end

    wid.KeepOrigPrompt=true;
    wid.Mode=immediateMode;
    wid.DialogRefresh=immediateMode;
    wid.ToolTip=DAStudio.message(tooltipId);
    grpCodeGen.Items{numItems}=wid;
    numItems=numItems+1;




    if(strcmp(storageClass,'Custom'))

        hCoderInfoClass=classhandle(coderInfo);
        csAttribsProp=findprop(hCoderInfoClass,'CustomAttributes');


        immediateMode=true;
        wid=populate_widget_from_object_property(coderInfo,csAttribsProp,h,immediateMode);
        wid.Name=DAStudio.message('Simulink:dialog:DataCustomAttributesPrompt');



        wid.Enabled=true;


        wid.RowSpan=[numItems,numItems];
        wid.ColSpan=[1,2];

        if(isfield(wid,'Items')&&~isempty(wid.Items))
            wid.Items=align_names(wid.Items);
            wid.LayoutGrid=[length(wid.Items),2];


            item_num=length(wid.Items);
            for j=1:item_num
                switch wid.Items{j}.Tag
                case 'MemorySection'

                    wid.Items{j}.Entries=getPropAllowedValues(coderInfo,'CustomAttributes.MemorySection');
                case{'Latching','Latching:'}

                    if((slfeature('LatchingForDataObjects')<2)&&...
                        strcmp(coderInfo.ParameterOrSignal,'Parameter')&&...
                        strcmp(coderInfo.CustomAttributes.Latching,'None'))
                        wid.Items{j}.Visible=0;
                    end
                case{'ConcurrentAccess','ConcurrentAccess:'}

                    if(~coderInfo.CustomAttributes.ConcurrentAccess&&(slfeature('BackFoldSafeCSC')<3))
                        wid.Items{j}.Visible=0;
                        if item_num==1
                            wid.Visible=0;
                        end
                    end
                case{'PreserveDimensions'}
                    wid.Items{j}.Name=DAStudio.message('Simulink:dialog:DataPreserveDimensionsPrompt');
                end

            end


            if(strcmp(coderInfo.CustomStorageClass,'GetSet'))
                item_num=length(wid.Items);
                for k=1:item_num
                    if(strcmp(wid.Items{k}.Name,'Get function:')==true)
                        wid.Items{k}.Name=DAStudio.message('Simulink:dialog:DataCustomAttributesGetFunctionPrompt');
                        wid.Items{k}.Tag=wid.Items{k}.Name;
                    elseif(strcmp(wid.Items{k}.Name,'Set function:')==true)
                        wid.Items{k}.Name=DAStudio.message('Simulink:dialog:DataCustomAttributesSetFunctionPrompt');
                        wid.Items{k}.Tag=wid.Items{k}.Name;
                    end
                end
            end

            grpCodeGen.Items{numItems}=wid;
            numItems=numItems+1;
        end
    end








    if slfeature('ReplaceAliasWithIdentifierProperty')>0

        propertyToSkip='Alias';
    else

        propertyToSkip='Identifier';
    end

    propsToSkip={'StorageClass';'CustomStorageClass';'CustomAttributes';
    'CSCPackageName';'ParameterOrSignal';'CustomStorageClassForCopy';
    'SaveVarsCalledFromDataObject';'Path';'hierarchySimStatus';propertyToSkip};

    immediateMode=false;
    for i=1:length(props)
        propName=props(i).Name;
        if ismember(propName,propsToSkip)
            continue;
        end

        wid=populate_widget_from_object_property(coderInfo,props(i),h,immediateMode);
        if(strcmp(wid.Type,'unknown')==1)
            continue;
        end


        switch propName
        case{'Alias','Identifier','Alignment','TypeQualifier'}
            wid.Name=DAStudio.message(['Simulink:dialog:Data',propName,'Prompt']);

            wid.KeepOrigPrompt=true;

            temporaryTooltipID=propName;
            if strcmp(propName,'Identifier')


                temporaryTooltipID='Alias';
            end

            wid.ToolTip=DAStudio.message(['Simulink:dialog:Data',temporaryTooltipID,'ToolTip']);
            wid.Mode=1;
        end

        wid.RowSpan=[numItems,numItems];
        wid.ColSpan=[1,2];



        grpCodeGen.Items{numItems}=wid;
        numItems=numItems+1;
    end

    grpCodeGen.Items=align_names(grpCodeGen.Items);
    grpCodeGen.LayoutGrid=[numItems,2];
    grpCodeGen.RowStretch=[zeros(1,numItems-1),1];
    grpCodeGen.ColStretch=[0,1];

    grpCodeGen.Name=DAStudio.message(groupNameId);
    grpCodeGen.Type='group';
    grpCodeGen.RowSpan=[2,2];
    grpCodeGen.ColSpan=[1,2];
    grpCodeGen.Source=h.CoderInfo;
    grpCodeGen.Tag='GrpCodeGen';
end
