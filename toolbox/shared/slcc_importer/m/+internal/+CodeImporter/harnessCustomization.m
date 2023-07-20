function harnessCustomization(harnessInfo)


























    set_param(harnessInfo.HarnessModel,'Solver','FixedStepDiscrete');
    set_param(harnessInfo.HarnessModel,'CovEnable','on');
    set_param(harnessInfo.HarnessModel,'CovSFcnEnable','on');


    psObj=get_param(harnessInfo.HarnessCUT,'FunctionPortSpecification');
    blockArguments=[psObj.ReturnArgument,psObj.InputArguments,psObj.GlobalArguments];

    for i=1:length(blockArguments)
        arg=blockArguments(i);
        if strcmpi(arg.Scope,'Input')
            portName=getPortName('In',arg.PortNumber,arg.Label);
            setPortProps(harnessInfo.Sources(arg.PortNumber),...
            portName,arg.Type,arg.Size);
        elseif strcmpi(arg.Scope,'Output')
            portName=getPortName('Out',arg.PortNumber,arg.Label);
            setPortProps(harnessInfo.Sinks(arg.PortNumber),...
            portName,arg.Type,arg.Size);
        elseif strcmpi(arg.Scope,'InputOutput')

            portName=getPortName('In',arg.PortNumber(1),arg.Label);
            setPortProps(harnessInfo.Sources(arg.PortNumber(1)),...
            portName,arg.Type,arg.Size);


            portName=getPortName('Out',arg.PortNumber(2),arg.Label);
            setPortProps(harnessInfo.Sinks(arg.PortNumber(2)),...
            portName,arg.Type,arg.Size);
        end
    end

    function portName=getPortName(inOrOut,portNumber,label)
        portName=[inOrOut,num2str(portNumber),'_',label];
    end

    function setPortProps(port,name,type,dims)
        set_param(port,'Name',name);
        set_param(port,'OutDataTypeStr',type);
        if strncmpi(type,'Bus:',4)
            set_param(port,'BusOutputAsStruct','on');
        end
        set_param(port,'PortDimensions',dims);
    end

end
