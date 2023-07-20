function hBlackBoxC=createBlackBoxComp(this,hN,hC)


























    bbxStrategyType=this.CodeGenMode;

    numDataIn=hC.NumberOfPirInputPorts('data');
    numDataOut=hC.NumberOfPirOutputPorts('data');

    hBlackBoxC=hN.addComponent('black_box_comp',bbxStrategyType,...
    numDataIn,numDataOut);


    hBlackBoxC.SimulinkHandle=hC.SimulinkHandle;

    setHDLImplParams(this,hBlackBoxC);


    if strcmp(bbxStrategyType,'instantiation')
        copyPortNames(this,hBlackBoxC,hC);
    end

    if numDataIn~=hC.NumberOfPirInputPorts

        for ii=1:hC.NumberOfPirInputPorts
            if~strcmp(hC.PirInputPorts(ii).Kind,'data')
                hBlackBoxC.addInputPort(hC.PirInputPorts(ii).Kind,hC.PirInputPorts(ii).Name);
            end
        end
    end

    if numDataOut~=hC.NumberOfPirOutputPorts

        for ii=1:hC.NumberOfPirOutputPorts
            if~strcmp(hC.PirOutputPorts(ii).Kind,'data')
                hBlackBoxC.addOutputPort(hC.PirOutputPorts(ii).Kind,hC.PirOutputPorts(ii).Name);
            end
        end
    end


    for ii=1:hC.NumberOfPirInputPorts
        hBlackBoxC.setInPortBidirectional((ii-1),hC.getInPortBidirectional(ii-1));
    end
    for ii=1:hC.NumberOfPirOutputPorts
        hBlackBoxC.setOutPortBidirectional((ii-1),hC.getOutPortBidirectional(ii-1));
    end




    userData.CodeGenFunction=this.CodeGenFunction;

    if isempty(this.CodeGenParams)
        params={};
    elseif iscell(this.CodeGenParams)
        params=this.CodeGenParams;
    else
        params={this.CodeGenParams};
    end






    switch this.FirstParam
    case 'useobjandcomphandles'

        firstArgs={this,hBlackBoxC};
    case 'usecomphandle'

        firstArgs={hBlackBoxC};
    case 'useslhandle'

        firstArgs={hC.SimulinkHandle};
    otherwise
        error(message('hdlcoder:validate:invalidemission'));
    end









    userData.CodeGenParams={firstArgs{:},params{:}};

    userData.generateSLBlockFunction=this.generateSLBlockFunction;
    userData.generateSLBlockParams=firstArgs;


    hBlackBoxC.ImplementationData=userData;


    hBlackBoxC.Name=hC.Name;

    function setHDLImplParams(this,hBBC)

        lat=this.getImplParams('ImplementationLatency');
        if~isempty(lat)&&lat>=0
            hBBC.setImplementationLatency(lat);
        end

        dpok=this.getImplParams('AllowDistributedPipelining');
        if~isempty(dpok)&&ischar(dpok)
            hBBC.setAllowDistributedPipelining(strcmpi(dpok,'on'));
        end


        function copyPortNames(this,hBlackBox,hC)

            bfp=hBlackBox.SimulinkHandle;



            if bfp~=-1
                [inPortNames,outPortNames]=this.getPortNamesFromSimulink(bfp);
                for n=1:length(inPortNames)
                    hBlackBox.setInputPortName(n-1,inPortNames{n});
                end
                for n=1:length(outPortNames)
                    hBlackBox.setOutputPortName(n-1,outPortNames{n});
                end
            else
                nin=length(hC.PirInputPorts);
                nout=length(hC.PirOutputPorts);
                for ii=1:nin
                    hBlackBox.PirInputPorts(ii).Name=hC.PirInputPorts(ii).Name;
                end
                for ii=1:nout
                    hBlackBox.PirOutputPorts(ii).Name=hC.PirOutputPorts(ii).Name;
                end
            end






