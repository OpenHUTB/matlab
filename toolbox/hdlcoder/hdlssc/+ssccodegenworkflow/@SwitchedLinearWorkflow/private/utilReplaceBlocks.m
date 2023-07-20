function utilReplaceBlocks(hinterfaceSystem,origSubsystem)












    outports=get_param(origSubsystem,'PortHandles').Outport;
    inports=get_param(origSubsystem,'PortHandles').Inport;


    origSubsystemParent=get_param(origSubsystem,'parent');


    lineInfo=cell(numel(outports),2);

    for i=1:numel(outports)
        lineInfo{i,1}=get_param(outports(i),'line');
        lineInfo{i,2}=get_param(lineInfo{i,1},'DstPortHandle');
    end


    for i=1:numel(inports)
        delete_line(get_param(inports(i),'line'));
    end



    origPosition=get_param(origSubsystem,'Position');


    delete_block(origSubsystem)


    for i=1:numel(outports)
        delete_line(lineInfo{i,1})
    end




    set_param(hinterfaceSystem,'Position',origPosition);


    interfaceOutports=get_param(hinterfaceSystem,'PortHandles').Outport;



    for i=1:numel(outports)

        hDataTypeConversion=add_block('hdlsllib/Signal Attributes/Data Type Conversion',strcat(origSubsystemParent,'/Data Type Conversion',num2str(i)),...
        'MakeNameUnique','on',...
        'Position',[220,0,255,25],...
        'RndMeth','Nearest');


        DTCports=get_param(hDataTypeConversion,'PortHandles');
        hDTCinport=DTCports.Inport;
        hDTCoutport=DTCports.Outport;

        add_line(origSubsystemParent,interfaceOutports(i),hDTCinport)

        for j=1:numel(lineInfo{i,2})
            add_line(origSubsystemParent,hDTCoutport,lineInfo{i,2}(j));
        end
    end


    set_param(hinterfaceSystem,'Zoomfactor','fit to view')
    Simulink.BlockDiagram.expandSubsystem(hinterfaceSystem);

    Simulink.BlockDiagram.arrangeSystem(origSubsystemParent,'FullLayout','True','Animation','False')


    set_param(origSubsystemParent,'Zoomfactor','fit to view')
end


