function dialogStruct=functionddg(h,name,source)





    rowIdx=1;

    ProtoypeLbl.Name=DAStudio.message('Simulink:blkprm_prompts:FcnEntryPrototype');
    ProtoypeLbl.Type='text';
    ProtoypeLbl.RowSpan=[rowIdx,rowIdx];
    ProtoypeLbl.ColSpan=[1,1];
    ProtoypeLbl.Tag='prototype_label';

    rowIdx=rowIdx+1;
    protoTypeValue.Name=ProtoypeLbl.Name;
    protoTypeValue.HideName=1;
    protoTypeValue.RowSpan=[rowIdx,rowIdx];
    protoTypeValue.ColSpan=[1,4];
    protoTypeValue.Type='edit';
    protoTypeValue.Tag='prototype_val';
    protoTypeValue.Value=h.Prototype;
    protoTypeValue.Bold=1;
    protoTypeValue.Enabled=false;

    rowIdx=rowIdx+1;
    argInfoLbl.Name=DAStudio.message('Simulink:blkprm_prompts:FcnEntryArguments');
    argInfoLbl.Type='text';
    argInfoLbl.RowSpan=[rowIdx,rowIdx];
    argInfoLbl.ColSpan=[1,1];
    argInfoLbl.Tag='prototype_label';

    rowIdx=rowIdx+1;


    args=h.Argument.toArray;


    argNameSet=containers.Map;
    maxNumberOfArgs=length(args);



    argData=cell(maxNumberOfArgs,5);
    if((~isempty(args))&&(isa(args(1),'slid.Argument')))
        argData=cell(maxNumberOfArgs,4);
    end

    dataIdx=1;
    for i=1:length(args)
        argName=args(i).Name;
        if~argNameSet.isKey(argName)
            argNameSet(argName)=true;

            if(isa(args(i),'slid.Argument'))
                argData(dataIdx,:)={argName,...
                string(args(i).Direction),...
                args(i).Type.Name,...
                args(i).Dimensions,...
                };
            else
                argData(dataIdx,:)={argName,...
                string(args(i).Direction),...
                args(i).Type.NumericType,...
                args(i).Type.Dimensions,...
                args(i).Type.Complexity};
            end
            dataIdx=dataIdx+1;
        end
    end
    argData=argData(1:argNameSet.Count,:);


    argTable.Name='';
    argTable.Type='table';
    argTable.Size=size(argData);
    argTable.Data=argData;
    argTable.Grid=1;
    argTable.ColHeader={DAStudio.message('Simulink:dialog:FcnColumnHeaderName'),...
    DAStudio.message('Simulink:dialog:FcnColumnHeaderDirection'),...
    DAStudio.message('Simulink:dialog:FcnColumnHeaderDataType'),...
    DAStudio.message('Simulink:dialog:FcnColumnHeaderDimensions'),...
    };
    argTable.HeaderVisibility=[0,1];
    argTable.ColumnCharacterWidth=[20,12,7,7];
    argTable.RowSpan=[rowIdx,rowIdx];
    argTable.ColSpan=[1,5];
    argTable.LastColumnStretchable=1;
    argTable.Tag='ArgInfoTable';
    argTable.Enabled=true;
    argTable.Editable=true;

    rowIdx=rowIdx+1;
    spacer.Type='panel';
    spacer.RowSpan=[rowIdx,rowIdx];





    fcnInfoGrp.Type='group';
    fcnInfoGrp.LayoutGrid=[rowIdx,4];
    fcnInfoGrp.RowStretch=[zeros(1,rowIdx-1),1];
    fcnInfoGrp.Items={ProtoypeLbl,...
    protoTypeValue,...
    argInfoLbl,...
    argTable,spacer};
    fcnInfoGrp.RowSpan=[1,1];
    fcnInfoGrp.ColSpan=[1,1];









    sourceLabel.Name=[DAStudio.message('Simulink:dialog:Source'),': '];
    sourceLabel.RowSpan=[1,1];
    sourceLabel.ColSpan=[1,1];
    sourceLabel.Type='text';
    sourceLabel.Tag='SourceLable_tag';

    sourceLink.Name=source;
    sourceLink.RowSpan=[1,1];
    sourceLink.ColSpan=[2,2];
    sourceLink.Type='hyperlink';
    sourceLink.Tag='Source_tag';
    sourceLink.MatlabMethod='open';
    sourceLink.MatlabArgs={source};

    try
        fileInfo=dir(source);
        lastModStr=fileInfo.date;
        info=Simulink.MDLInfo(source);
        lastModifiedBy=info.LastModifiedBy;
    catch
        lastModifiedBy='unknown';
        lastModStr='unknown time';
    end

    statusTextStr=DAStudio.message(...
    'Simulink:dialog:DictionaryEntryModification',...
    lastModifiedBy,...
    lastModStr);
    statusText.Name=statusTextStr;
    statusText.Type='text';
    statusText.RowSpan=[2,2];
    statusText.ColSpan=[1,2];
    statusText.Tag='StatusText';


    fcnMetadataGrp.Name='';
    fcnMetadataGrp.Type='group';
    fcnMetadataGrp.ColStretch=[0,1];
    fcnMetadataGrp.Items={sourceLabel,sourceLink,statusText};


    fcnMetadataGrp.LayoutGrid=[2,2];
    fcnMetadataGrp.RowSpan=[2,2];
    fcnMetadataGrp.ColSpan=[1,1];





    dialogStruct.DialogTitle=['Simulink Function: ',name];
    dialogStruct.LayoutGrid=[2,1];
    dialogStruct.RowStretch=[1,0];
    dialogStruct.Items={fcnInfoGrp,fcnMetadataGrp};
    dialogStruct.HelpMethod='helpview';
    dialogStruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};


