function dcm=createDCMComp(h,clkModule)






    dcm=eda.xilinx.ClockModule;

    dcm.SimModel='';
    dcm.UniqueName=clkModule.Design.Name;
    dcm.HDLFiles=clkModule.Design.Files;
    dcm.HDLFileDir=h.mWorkflowInfo.hdlcData.codegenDir;

    for ii=1:numel(clkModule.Design.InputPorts)
        port=clkModule.Design.InputPorts{ii};
        if isfield(port,'Type')&&strcmpi(port.Type,'Clock')
            dcm.addprop(port.Name);
            dcm.(port.Name)=eda.internal.component.ClockPort;
            dcm.(port.Name).UniqueName=port.Name;
        else
            dcm.addprop(port.Name);
            dcm.(port.Name)=eda.internal.component.ResetPort;
            dcm.(port.Name).UniqueName=port.Name;
        end
    end

    for ii=1:numel(clkModule.Design.OutputPorts)
        port=clkModule.Design.OutputPorts{ii};
        if isfield(port,'Type')&&strcmpi(port.Type,'Clock')
            dcm.addprop(port.Name);
            dcm.(port.Name)=eda.internal.component.Outport('FiType','boolean');
            dcm.(port.Name).UniqueName=port.Name;
        else
            dcm.addprop(port.Name);
            sltype=['ufix',port.Width];
            dcm.(port.Name)=eda.internal.component.Outport('FiType',sltype);
            dcm.(port.Name).UniqueName=port.Name;
        end
    end



