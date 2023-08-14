function dlgStruct=getDialogSchema(this,dummy)%#ok<INUSD>







    InfoMsg1=sprintf(['Suggested timescale:\n'...
    ,'1 second in Simulink corresponds to %s s in the HDL simulator'],num2str(this.UserData.DefaultTimeScale,'%16.15g'));
    if(this.isCurrentTimeScaleValid)
        InfoMsg2=sprintf(['The timescale is currently set to:\n'...
        ,'1 second in Simulink corresponds to %s s in the HDL simulator'],num2str(this.UserData.TimeScale,'%16.15g'));
    else
        InfoMsg2=sprintf(['The timescale is currently set to:\n'...
        ,'There is no valid timescale that corresponds to your current inputs.  Consider using the suggested timescale instead.']);
    end
    InfoMsg3=['Based upon the current timescale, the relationships ',...
    'between Simulink sample times and HDL sample times are ',...
    'shown in the following table for port signals in your ',...
    'design. If this timescale does not satisfy your requirements, ',...
    'supply the desired sample time in one ',...
    'of the editable cells of the table. The other table cells ',...
    'and the current timescale will be updated accordingly.'];












    Text1.Type='text';
    Text1.Name=InfoMsg1;
    Text1.Tag='timescaleText1';
    Text1.RowSpan=[1,1];
    Text1.ColSpan=[1,2];

    Text1.Bold=true;

    Text2.Type='text';
    Text2.Name=InfoMsg2;
    Text2.Tag='timescaleText2';
    Text2.RowSpan=[1,1];
    Text2.ColSpan=[1,4];
    Text2.WordWrap=true;
    Text2.Bold=true;

    Text3.Type='text';
    Text3.Name=InfoMsg3;
    Text3.Tag='timescaleText3';
    Text3.RowSpan=[2,2];
    Text3.ColSpan=[1,4];
    Text3.WordWrap=true;


    RestoreDefault.Type='pushbutton';
    RestoreDefault.Name='Use Suggested Timescale';
    RestoreDefault.Tag='timescaleRestoreDefault';
    RestoreDefault.RowSpan=[1,1];
    RestoreDefault.ColSpan=[4,4];
    RestoreDefault.ObjectMethod='onRestore';
    RestoreDefault.MethodArgs={'%dialog'};
    RestoreDefault.ArgDataTypes={'handle'};

    Group1.Type='group';
    Group1.Tag='timescaleGroup1';
    Group1.LayoutGrid=[1,4];
    Group1.RowSpan=[1,1];
    Group1.ColSpan=[1,4];
    Group1.Items={Text1,RestoreDefault};

    Group2.Type='group';
    Group2.Tag='timescaleGroup2';
    Group2.LayoutGrid=[2,4];
    Group2.RowSpan=[2,2];
    Group2.ColSpan=[1,4];
    Group2.Items={Text2,Text3};


    HdlUnit.Type='combobox';
    HdlUnit.Name='HDL time unit:';
    HdlUnit.Tag='HdlTimeUnit';
    HdlUnit.Entries={'Tick','fs','ps','ns','us','ms','s'};
    HdlUnit.Values=[-1,0,1,2,3,4,5];
    HdlUnit.RowSpan=[3,3];
    HdlUnit.ColSpan=[1,1];
    HdlUnit.ObjectProperty='HdlTimeUnit';
    HdlUnit.DialogRefresh=true;
    HdlUnit.Mode=1;

    [HdlTimeUnitValue,HdlTimeUnitName]=l_getHdlTimeUnitValue(this.HdlTimeUnit,this.UserData.Precision);


    row=numel(this.UserData.UsedPorts);

    FirstColWidth=10;
    for m=1:row
        FirstColWidth=max(FirstColWidth,length(this.UserData.UsedPorts{m}.Name));



        if(this.isValueChangeValid)
            UseSlTime=this.UserData.UsedPorts{m}.UseSlTime;
            if(UseSlTime)
                SlSampleTime=this.UserData.UsedPorts{m}.SampleTime;
                HdlSampleTime=this.UserData.UsedPorts{m}.SampleTime*this.UserData.TimeScale/HdlTimeUnitValue;
            else
                SlSampleTime=this.UserData.UsedPorts{m}.SampleTime/this.UserData.TimeScale;
                HdlSampleTime=this.UserData.UsedPorts{m}.SampleTime/HdlTimeUnitValue;
            end
            this.TableData{m,2}.Value=num2str(SlSampleTime,'%16.15g');
            this.TableData{m,3}.Value=num2str(HdlSampleTime,'%16.15g');
        end
    end



    PortList.Type='table';
    PortList.HeaderVisibility=[0,1];
    PortList.ColHeader={'Port Name',...
    'Simulink Sample Time (s)',...
    ['HDL Sample Time (',HdlTimeUnitName,')']};
    PortList.RowHeader={};
    PortList.Enabled=true;
    PortList.Editable=true;
    PortList.Mode=1;
    PortList.ColumnHeaderHeight=1;
    PortList.ColumnCharacterWidth=[(FirstColWidth+2),25,22];
    PortList.MinimumSize=[300,200];
    PortList.FontFamily='Courier';
    PortList.Name='Port List';
    PortList.Tag='timescalePortList';
    PortList.RowSpan=[4,8];
    PortList.ColSpan=[1,4];
    PortList.Data=this.TableData;
    PortList.Size=size(this.TableData);
    PortList.ValueChangedCallback=@l_ValueChangedCB;


    WidgetGroup.Type='panel';
    WidgetGroup.Tag='WidgetGroup';
    WidgetGroup.Name='';
    WidgetGroup.LayoutGrid=[8,4];
    WidgetGroup.ColStretch=[1,1,1,1];
    WidgetGroup.Items={Group1,Group2,HdlUnit,PortList};


    dlgStruct.DialogTitle='Timescale Details';
    dlgStruct.DialogTag='AutoTimescaleDlg';
    dlgStruct.StandaloneButtonSet={'OK','Help'};
    dlgStruct.Items={WidgetGroup};
    dlgStruct.Sticky=true;

    buttonWidget=l_getButtonSet({'OK','Cancel','Help'});
    dlgStruct.StandaloneButtonSet=buttonWidget;









end

function l_ValueChangedCB(dlg,row,col,value)
    h=getSource(dlg);
    try
        h.isValueChangeValid=false;
        sampleTime=eval(value);
        assert(~isempty(sampleTime)&&~isnan(sampleTime),...
        'HDLLink:AutoTimescale:NotNumber','Sample time must be a number.');
        assert(sampleTime>0,'HDLLink:NegativeSampleTime','Sample time must be positive number.');
        [HdlTimeUnitValue,~]=l_getHdlTimeUnitValue(h.HdlTimeUnit,h.UserData.Precision);

        if(h.UserData.UsedPorts{row+1}.UseSlTime)
            h.UserData.TimeScale=sampleTime*HdlTimeUnitValue/h.UserData.UsedPorts{row+1}.SampleTime;
        else
            h.UserData.TimeScale=h.UserData.UsedPorts{row+1}.SampleTime/sampleTime;
        end
        h.isValueChangeValid=true;

        l_checkTimesScale(h.UserData,h.UserData.TimeScale);

        h.isCurrentTimeScaleValid=true;
    catch ME
        h.isCurrentTimeScaleValid=false;




        if(~h.isValueChangeValid)
            h.TableData{row+1,col+1}.Value=value;
        end
        errdlg=DAStudio.DialogProvider;
        errdlg.errordlg(ME.message,'Error',true);
    end
    dlg.refresh;
end

function l_checkTimesScale(UserData,TimeScale)
    newST=zeros(1,numel(UserData.UsedPorts));
    for m=1:numel(UserData.UsedPorts)
        if(UserData.UsedPorts{m}.UseSlTime)

            newST(m)=UserData.UsedPorts{m}.SampleTime*TimeScale;

            tInTicks=l_quantizeTimeToTicks(UserData.UsedPorts{m}.SampleTime,TimeScale,UserData.Precision);
            if(tInTicks<0)
                error(message('HDLLink:AutoTimescale:NotMultipleTicks',sprintf('%g',TimeScale),UserData.UsedPorts{m}.Name,sprintf('%g',newST(m)),sprintf('%g',UserData.Precision)));
            end
            if(newST(m)>UserData.MaxHdlTime)
                error(message('HDLLink:AutoTimescale:HdlTimeOverLimit',sprintf('%g',TimeScale),UserData.UsedPorts{m}.Name,sprintf('%g',newST(m)),sprintf('%e',UserData.Precision)));
            end
        else
            newST(m)=UserData.UsedPorts{m}.SampleTime/TimeScale;
        end
    end
end

function[hdlTimeUnitValue,hdlTimeUnitName]=l_getHdlTimeUnitValue(hdlTimeUnit,hdlPrecision)
    switch(hdlTimeUnit)
    case-1
        hdlTimeUnitValue=hdlPrecision;hdlTimeUnitName='Tick';
    case 0
        hdlTimeUnitValue=1e-15;hdlTimeUnitName='fs';
    case 1
        hdlTimeUnitValue=1e-12;hdlTimeUnitName='ps';
    case 2
        hdlTimeUnitValue=1e-9;hdlTimeUnitName='ns';
    case 3
        hdlTimeUnitValue=1e-6;hdlTimeUnitName='us';
    case 4
        hdlTimeUnitValue=1e-3;hdlTimeUnitName='ms';
    case 5
        hdlTimeUnitValue=1;hdlTimeUnitName='s';
    otherwise
        error(message('HDLLink:AutoTimescale:InvalidTimeUnit'));
    end
end


function buttons=l_getButtonSet(buttonNames)
    items=cell(1,numel(buttonNames));
    for m=1:numel(buttonNames)
        tmp.Name=buttonNames{m};
        tmp.Type='pushbutton';
        tmp.ObjectMethod=['on',buttonNames{m}];
        tmp.Tag=['timescale',buttonNames{m}];
        tmp.MethodArgs={'%dialog'};
        tmp.ArgDataTypes={'handle'};
        tmp.RowSpan=[1,1];
        tmp.ColSpan=[m,m];
        items{m}=tmp;
    end

    buttons.Type='panel';
    buttons.Name='Buttons';
    buttons.LayoutGrid=[1,numel(buttonNames)];
    buttons.Items=items;
end



function tick=l_quantizeTimeToTicks(period,TimeScale,Precision)
    PrecisionExp=round(log10(Precision));

    tInTicks=period*TimeScale*(10^(-PrecisionExp));

    qtInTicks=floor(tInTicks+0.5);

    delta=abs(tInTicks-qtInTicks);
    tolerance=tInTicks*128*eps;
    if(delta>tolerance)
        tick=-1;
    else
        tick=qtInTicks;
    end
end

