function dlgStruct=getDialogSchema(this,path)%#ok<INUSD>





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


    if this.defaultInputChannelMapping
        maxNumInputChannels=computeMaxChannelsForDevice(this.deviceNamePopup,'input');
        if(maxNumInputChannels==0)||(maxNumInputChannels==1)
            this.inputChannelMapping=sprintf('%d',maxNumInputChannels);
        else
            this.inputChannelMapping=sprintf('%d:%d',1,maxNumInputChannels);
        end
    end
    addToList('checkbox','Use default mapping between Device Input Channels and Data',...
    'defaultInputChannelMapping');
    itemList{end}.DialogRefresh=1;
    addToList('edit','Device Input Channels:','inputChannelMapping');
    itemList{end}.Visible=~this.defaultInputChannelMapping;
    itemList{end}.ColSpan=[2,maxColSpan(2)];


    addToList('edit','Number of channels:','numChannels');
    itemList{end}.Visible=this.defaultInputChannelMapping;
    itemList{end}.ColSpan=[2,maxColSpan(2)];


    addToList('edit','Sample rate (Hz):','sampleRate');

    addToList('combobox','Device data type:','deviceDatatype');

    addToList('checkbox','Automatically determine buffer size','autoBufferSize');
    itemList{end}.DialogRefresh=1;

    addToList('edit','Buffer size (samples):','bufferSize');
    itemList{end}.Visible=~this.autoBufferSize;
    itemList{end}.ColSpan=[2,maxColSpan(2)];

    addToList('edit','Queue duration (seconds):','queueDuration');


    parametersPane=dspGetContainerWidgetBase('group','Parameters','parametersPane');
    parametersPane.Items=itemList;
    parametersPane.RowSpan=[2,2];
    parametersPane.ColSpan=[1,1];
    parametersPane.Tag='parametersPane';
    parametersPane.LayoutGrid=[1,1];


    curRow=[0,0];
    itemList=cell(0);


    addToList('checkbox','Output number of samples by which the queue was overrun',...
    'outputNumOverrunSamples');

    addToList('edit','Frame size (samples):','frameSize');

    addToList('combobox','Output data type:','outputDatatype');
    itemList{end}.Entries=set(this,'outputDatatype')';


    outputsPane=dspGetContainerWidgetBase('group','Outputs','outputsPane');
    outputsPane.Items=itemList;
    outputsPane.RowSpan=[3,3];
    outputsPane.ColSpan=[1,1];
    outputsPane.Tag='outputsPane';
    outputsPane.LayoutGrid=[1,1];


    dlgStruct=getBaseSchemaStruct(this,{parametersPane,outputsPane});

end
