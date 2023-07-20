function dlgStruct=getDialogSchema(obj,~)














    rowSpan=[1,1];
    colSpan=[1,6];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    rowInDialog=1;
    widgetTags=j1939.internal.createDefaultString('j1939nodeconfig');


    colSpan=[1,1];
    ConfigNameText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:ConfigNameText')),...
    widgetTags.ConfigNameText,[rowInDialog,rowInDialog],colSpan);
    ConfigNameText.Alignment=5;

    colSpan=[2,6];
    entries=localFindValidConfigNames(obj);
    ConfigNameField=tamslgate('privateslwidgetcombo',...
    getString(message('j1939:maskStrings:ConfigNameField')),widgetTags.ConfigName,...
    entries,[rowInDialog,rowInDialog],colSpan,'j1939.internal.slMaskCallback');
    ConfigNameField.Mode=true;
    ConfigNameField.HideName=true;

    dbObject=[];

    if~strcmp(obj.ConfigName,'Select a config name')

        dbObject=j1939.internal.dbSetup(obj);
    end


    rowInDialog=rowInDialog+1;
    colSpan=[1,1];
    NodeIDText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:NodeIDText')),...
    widgetTags.NodeIDText,[rowInDialog,rowInDialog],colSpan);
    NodeIDText.Alignment=5;

    colSpan=[2,3];
    entries=localFindValidNodeNames(obj,dbObject);
    NodeIDField=tamslgate('privateslwidgetcombo',...
    getString(message('j1939:maskStrings:NodeIDField')),widgetTags.NodeID,...
    entries,[rowInDialog,rowInDialog],colSpan,'j1939.internal.slMaskCallback');
    NodeIDField.Mode=true;
    NodeIDField.DialogRefresh=true;
    NodeIDField.HideName=true;


    colSpan=[4,6];
    NodeNameField=tamslgate('privateslwidgetedit',getString(message('j1939:maskStrings:NodeNameField')),widgetTags.NodeName,...
    [rowInDialog,rowInDialog],colSpan,'j1939.internal.slMaskCallback');
    NodeNameField.HideName=true;

    NodeNameField.Mode=true;


    if~any(strcmp(obj.NodeID,{'Custom','Select a node'}))&&~isempty(dbObject)
        obj.NodeName=obj.NodeID;
        nodeAttr=dbObject.nodeInfo(obj.NodeName);
        if~isempty(nodeAttr)
            for attrCount=1:length(nodeAttr.Attributes)
                switch nodeAttr.Attributes{attrCount}
                case 'NmJ1939AAC'
                    obj.AllowAAC=(nodeAttr.AttributeInfo(attrCount).Value~=0);
                case 'NmStationAddress'
                    obj.NodeAddress=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939IndustryGroup'
                    obj.IndustryGroup=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939System'
                    obj.VehicleSystem=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939SystemInstance'
                    obj.VehicleSystemInstance=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939Function'
                    obj.FunctionID=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939FunctionInstance'
                    obj.FunctionInstance=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939ECUInstance'
                    obj.ECUInstance=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939ManufacturerCode'
                    obj.ManufacturerCode=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                case 'NmJ1939IdentityNumber'
                    obj.IDNumber=num2str(nodeAttr.AttributeInfo(attrCount).Value);
                end
            end
        end
    end
    messagePane=localCreateMessageGroup(obj,widgetTags);

    if~strcmpi(obj.NodeID,'Custom')||strcmpi(obj.ConfigName,'Select a config name')
        NodeNameField.Enabled=false;
    else
        NodeNameField.Enabled=true;
    end

    if strcmpi(obj.ConfigName,'Select a config name')
        NodeIDField.Enabled=false;
    else
        NodeIDField.Enabled=true;
    end


    rowInDialog=rowInDialog+6;
    colSpan=[1,1];
    SampleTimeText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:SampleTimeText')),...
    widgetTags.SampleTimeText,[rowInDialog,rowInDialog],colSpan);

    colSpan=[2,6];
    SampleTimeField=tamslgate('privateslwidgetedit',...
    sprintf(''),widgetTags.SampleTime,...
    [rowInDialog,rowInDialog],colSpan,'j1939.internal.slMaskCallback');



    rowInDialog=rowInDialog+1;
    colSpan=[1,6];
    OutputAddress=tamslgate('privateslwidgetcheckbox',...
    getString(message('j1939:maskStrings:OutputAddress')),widgetTags.OutputAddress,...
    [rowInDialog,rowInDialog],colSpan,'j1939.internal.slMaskCallback');
    OutputAddress.Mode=true;

    rowInDialog=rowInDialog+1;
    colSpan=[1,6];
    OutputACStatus=tamslgate('privateslwidgetcheckbox',...
    getString(message('j1939:maskStrings:OutputACStatus')),widgetTags.OutputACStatus,...
    [rowInDialog,rowInDialog],colSpan,'j1939.internal.slMaskCallback');
    OutputACStatus.Mode=true;


    items={ConfigNameText,ConfigNameField,...
    NodeIDText,NodeIDField,NodeNameField,...
    messagePane,SampleTimeText,SampleTimeField,...
    OutputAddress,OutputACStatus};

    paramPane=tamslgate('privateslwidgetgroup',getString(message('j1939:maskStrings:paramPane')),widgetTags.ParameterPane,...
    items,[2,2],[1,6],[rowInDialog+1,3]);


    dlgItems={descPane,paramPane};
    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'j1939.internal.slMaskPreapply','closeCallback');


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if(isLibrary&&isLocked)||any(strcmp(obj.Root.SimulationStatus,{'running','paused','external'}))
        dlgStruct.DisableDialog=true;
    end


    obj.IsDifferentConfig=false;


    function entries=localFindValidConfigNames(obj)

        entries=j1939.internal.getConfigList(obj.Root.Name);


        errorStrings=j1939.internal.createDefaultString('errorstrings');

        if~ismember(obj.ConfigName,entries)
            if~obj.IsDifferentConfig

                errMsg=sprintf(errorStrings.ConfigNotFound,obj.ConfigName);
                uiwait(errordlg(errMsg,errorStrings.ErrorDialogTitle));
                obj.ConfigName=entries{1};
                obj.Block.ConfigName=entries{1};
                return;
            end
        end

        if(numel(entries)==1)

            if~obj.IsDifferentConfig
                if strcmpi(obj.ConfigName,entries{1})
                    if obj.ShowError
                        uiwait(errordlg(errorStrings.NoConfigFound,errorStrings.ErrorDialogTitle,'modal'));
                        obj.ShowError=false;
                    end
                    obj.ConfigName=entries{1};
                    obj.Block.ConfigName=entries{1};
                else
                    errMsg=sprintf(errorStrings.ConfigNotFound,obj.ConfigName);
                    uiwait(errordlg(errMsg,errorStrings.ErrorDialogTitle,'modal'));
                    obj.ConfigName=entries{1};
                    obj.Block.ConfigName=entries{1};
                end
                return;
            end
        end

        function entries=localFindValidNodeNames(obj,dbObject)



            if~isempty(dbObject)
                nodeListCell=dbObject.Nodes;
            else
                nodeListCell='';
            end
            entries=vertcat({'Select a node';'Custom'},nodeListCell);


            if strcmpi(obj.ConfigName,'Select a config name')
                obj.NodeID=entries{1};
                return;
            end


            if obj.IsDifferentConfig&&strcmpi(obj.NodeID,entries{1})
                if~isempty(obj.NodeName)
                    if ismember(obj.NodeName,entries)
                        obj.NodeID=obj.NodeName;
                    else
                        obj.NodeID=entries{2};
                    end
                end
            end


            errorStrings=j1939.internal.createDefaultString('errorstrings');

            if~ismember(obj.NodeID,entries)
                if~obj.IsDifferentNode

                    errMsg=sprintf(errorStrings.NodeNameNotFound,obj.NodeName);
                    uiwait(errordlg(errMsg,errorStrings.ErrorDialogTitle));
                    return;
                end
            end

            function messagePane=localCreateMessageGroup(obj,widgetTags)


                rowInDialog=1;
                colSpan=[1,6];
                AACCheckbox=tamslgate('privateslwidgetcheckbox',...
                getString(message('j1939:maskStrings:AACCheckbox')),widgetTags.AllowAAC,...
                [rowInDialog,rowInDialog],colSpan,'j1939.internal.slMaskCallback');
                AACCheckbox.Mode=true;


                rowInDialog=rowInDialog+1;
                colSpan=[1,2];
                NodeAddressText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:NodeAddressText')),...
                widgetTags.NodeAddressText,[rowInDialog,rowInDialog],colSpan);
                NodeAddressText.Alignment=5;

                NodeAddressField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.NodeAddress,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');


                colSpan=[3,4];
                IndustryGroupText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:IndustryGroupText')),...
                widgetTags.IndustryGroupText,[rowInDialog,rowInDialog],colSpan);
                IndustryGroupText.Alignment=5;

                IndustryGroupField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.IndustryGroup,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');


                colSpan=[5,6];
                VehicleSystemText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:VehicleSystemText')),...
                widgetTags.VehicleSystemText,[rowInDialog,rowInDialog],colSpan);
                VehicleSystemText.Alignment=5;

                VehicleSystemField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.VehicleSystem,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');



                rowInDialog=rowInDialog+2;
                colSpan=[1,2];
                VehicleSystemInstanceText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:VehicleSystemInstanceText')),...
                widgetTags.VehicleSystemInstanceText,[rowInDialog,rowInDialog],colSpan);
                VehicleSystemInstanceText.Alignment=5;

                VehicleSystemInstanceField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.VehicleSystemInstance,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');


                colSpan=[3,4];
                FunctionIDText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:FunctionIDText')),...
                widgetTags.FunctionIDText,[rowInDialog,rowInDialog],colSpan);
                FunctionIDText.Alignment=5;

                FunctionIDField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.FunctionID,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');


                colSpan=[5,6];
                FunctionInstanceText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:FunctionInstanceText')),...
                widgetTags.FunctionInstanceText,[rowInDialog,rowInDialog],colSpan);
                FunctionInstanceText.Alignment=5;

                FunctionInstanceField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.FunctionInstance,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');



                rowInDialog=rowInDialog+2;
                colSpan=[1,2];
                ECUInstanceText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:ECUInstanceText')),...
                widgetTags.ECUInstanceText,[rowInDialog,rowInDialog],colSpan);
                ECUInstanceText.Alignment=5;

                ECUInstanceField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.ECUInstance,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');


                colSpan=[3,4];
                ManufacturerCodeText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:ManufacturerCodeText')),...
                widgetTags.ManufacturerCodeText,[rowInDialog,rowInDialog],colSpan);
                ManufacturerCodeText.Alignment=5;

                ManufacturerCodeField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.ManufacturerCode,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');


                colSpan=[5,6];
                IdentityNumberText=tamslgate('privateslwidgettext',getString(message('j1939:maskStrings:IdentityNumberText')),...
                widgetTags.IdentityNumberText,[rowInDialog,rowInDialog],colSpan);
                IdentityNumberText.Alignment=5;

                IdentityNumberField=tamslgate('privateslwidgetedit',sprintf(''),widgetTags.IdentityNumber,...
                [rowInDialog+1,rowInDialog+1],colSpan,'j1939.internal.slMaskCallback');

                if~strcmpi(obj.NodeID,'Custom')||strcmpi(obj.ConfigName,'Select a config name')
                    AACCheckbox.Enabled=false;
                    NodeAddressField.Enabled=false;
                    IndustryGroupField.Enabled=false;
                    VehicleSystemField.Enabled=false;
                    VehicleSystemInstanceField.Enabled=false;
                    FunctionIDField.Enabled=false;
                    FunctionInstanceField.Enabled=false;
                    ECUInstanceField.Enabled=false;
                    ManufacturerCodeField.Enabled=false;
                    IdentityNumberField.Enabled=false;
                else
                    AACCheckbox.Enabled=true;
                    NodeAddressField.Enabled=true;
                    IndustryGroupField.Enabled=true;
                    VehicleSystemField.Enabled=true;
                    VehicleSystemInstanceField.Enabled=true;
                    FunctionIDField.Enabled=true;
                    FunctionInstanceField.Enabled=true;
                    ECUInstanceField.Enabled=true;
                    ManufacturerCodeField.Enabled=true;
                    IdentityNumberField.Enabled=true;
                end


                items={AACCheckbox,...
                NodeAddressText,NodeAddressField,IndustryGroupText,IndustryGroupField,...
                VehicleSystemText,VehicleSystemField,VehicleSystemInstanceText,VehicleSystemInstanceField,...
                FunctionIDText,FunctionIDField,FunctionInstanceText,FunctionInstanceField,...
                ECUInstanceText,ECUInstanceField,ManufacturerCodeText,ManufacturerCodeField,...
                IdentityNumberText,IdentityNumberField};


                messagePane=tamslgate('privateslwidgetgroup',getString(message('j1939:maskStrings:messagePane')),widgetTags.MessagePane,...
                items,[4,4],[1,6],[9,20]);
                messagePane.RowStretch=[zeros(1,5),0,1,0,0];




























