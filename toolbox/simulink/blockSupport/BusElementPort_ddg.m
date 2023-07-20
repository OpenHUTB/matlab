function dlgStruct=BusElementPort_ddg(~,h)



    elementFullPath=h.PortName;
    if~isempty(h.Element)
        elementFullPath=[elementFullPath,'.',h.Element];
    end


    if slfeature('compositePortsAtRoot')==1
        if strcmpi(h.BlockType,'Inport')
            if strcmpi(get_param(h.handle,'isClientServer'),'on')





                descTxt.Name=getString(message('Simulink:BusElPorts:BlockDescBEIFunctions'));
            else
                descTxt.Name=getString(message('Simulink:BusElPorts:BlockDescBEIAtRoot'));
            end
        else
            if strcmpi(get_param(h.handle,'isClientServer'),'on')





                descTxt.Name=getString(message('Simulink:BusElPorts:BlockDescBEOFunctions'));
            else
                descTxt.Name=getString(message('Simulink:BusElPorts:BlockDescBEOAtRoot'));
            end
        end
    else
        if strcmpi(h.BlockType,'Inport')
            descTxt.Name=getString(message('Simulink:BusElPorts:BlockDescBEI'));
        else
            descTxt.Name=getString(message('Simulink:BusElPorts:BlockDescBEO'));
        end
    end

    descTxt.Type='text';
    descTxt.WordWrap=true;
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    hyperlink.Name=elementFullPath;
    hyperlink.Type='hyperlink';
    hyperlink.ToolTip=getString(message('Simulink:dialog:openBlockTooltip'));
    hyperlink.MatlabMethod='open_system';
    hyperlink.MatlabArgs={h.Handle};


    filler.Name='';
    filler.Visible=false;
    filler.Type='text';
    filler.WordWrap=true;
    filler.RowSpan=[2,2];
    filler.ColSpan=[1,1];

    if strcmpi(h.BlockType,'Inport')
        descGrp.Name=getString(message('Simulink:BusElPorts:BlockNameBEI'));
    else
        descGrp.Name=getString(message('Simulink:BusElPorts:BlockNameBEO'));
    end
    descGrp.Type='group';
    descGrp.Items={descTxt,hyperlink,filler};
    descGrp.LayoutGrid=[3,1];
    descGrp.RowStretch=[0,0,1];




    dlgStruct.Items={descGrp};
    dlgStruct.LayoutGrid=[1,1];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


