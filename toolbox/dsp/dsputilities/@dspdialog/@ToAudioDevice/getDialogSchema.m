function dlgStruct=getDialogSchema(this,~)





    function addToList(type,name,prop)
        dlgstruct=dspGetLeafWidgetBase(type,name,prop,this,prop);
        itemList{end+1}=dlgstruct;
        curRow=curRow+[1,1];
        itemList{end}.RowSpan=curRow;
        itemList{end}.ColSpan=maxColSpan;
    end


    curRow=[0,0];
    maxColSpan=[1,8];
    itemList=cell(0);


    addToList('combobox','Device:','deviceNamePopup');
    itemList{end}.Entries=this.deviceList;
    itemList{end}.DialogRefresh=1;


    addToList('checkbox','Inherit sample rate from input','inheritSampleRate');
    itemList{end}.DialogRefresh=1;
    addToList('edit','Sample rate (Hz):','sampleRate');
    itemList{end}.Visible=~this.inheritSampleRate;
    itemList{end}.ColSpan=[2,maxColSpan(2)];


    addToList('combobox','Device data type:','deviceDatatype');


    addToList('checkbox','Automatically determine buffer size','autoBufferSize');
    itemList{end}.DialogRefresh=1;
    addToList('edit','Buffer size (samples):','bufferSize');
    itemList{end}.ColSpan=[2,maxColSpan(2)];
    itemList{end}.Visible=~this.autoBufferSize;


    addToList('edit','Queue duration (seconds):','queueDuration');


    addToList('checkbox','Use default mapping between Data and Device Output Channels',...
    'defaultOutputChannelMapping');
    itemList{end}.DialogRefresh=1;




    simStatus=get_param(bdroot(this.getBlock.getFullName),'SimulationStatus');
    if strcmp(simStatus,'stopped')
        if this.defaultOutputChannelMapping
            maxNumOutputChannels=computeMaxChannelsForDevice(this.deviceNamePopup,'output');
            if(maxNumOutputChannels==0)||(maxNumOutputChannels==1)
                this.outputChannelMapping=sprintf('%d',maxNumOutputChannels);
            else
                this.outputChannelMapping=sprintf('%d:%d',1,maxNumOutputChannels);
            end
        end
    end
    addToList('edit','Device Output Channels:','outputChannelMapping');
    itemList{end}.ColSpan=[2,maxColSpan(2)];
    itemList{end}.Visible=~this.defaultOutputChannelMapping;


    parametersPane=dspGetContainerWidgetBase('group','Parameters','parametersPane');
    parametersPane.Items=itemList;
    parametersPane.RowSpan=[2,2];
    parametersPane.ColSpan=[1,1];
    parametersPane.Tag='parametersPane';
    parametersPane.LayoutGrid=[1,1];


    curRow=[0,0];
    itemList=cell(0);


    addToList('checkbox','Output number of samples by which the queue was underrun','outputNumUnderrunSamples');


    outputsPane=dspGetContainerWidgetBase('group','Outputs','outputsPane');
    outputsPane.Items=itemList;
    outputsPane.RowSpan=[3,3];
    outputsPane.ColSpan=[1,1];
    outputsPane.Tag='outputsPane';
    outputsPane.LayoutGrid=[1,1];


    dlgStruct=getBaseSchemaStruct(this,{parametersPane,outputsPane});


    dlgStruct.OpenCallback=@enableApply;
    function enableApply(dialog)
        if isempty(strmatch(this.Block.deviceName,this.deviceList))
            dialog.enableApplyButton(true);
        end
    end

end
