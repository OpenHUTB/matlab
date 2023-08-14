function thermodynamicDiagram(block)








    setup(block)

end



function setup(block)


    block.NumInputPorts=2;
    block.NumOutputPorts=0;


    block.SetPreCompInpPortInfoToDynamic;


    block.InputPort(1).DatatypeID=0;
    block.InputPort(1).Complexity="Real";
    block.InputPort(1).DirectFeedthrough=true;
    block.InputPort(2).DatatypeID=0;
    block.InputPort(2).Complexity="Real";
    block.InputPort(2).DirectFeedthrough=true;



    block.NumDialogPrms=1;




    block.SampleTimes=[0,1];


    block.SimStateCompliance="HasNoSimState";


    block.SetAccelRunOnTLC(false);


    block.OperatingPointCompliance="UseEmpty";


    block.SetSimViewingDevice(true);


    block.RegBlockMethod("SetInputPortDimensions",@SetInputPortDimensions);
    block.RegBlockMethod("PostPropagationSetup",@PostPropagationSetup);
    if block.DialogPrm(1).Data=="fluids.internal.diagrams.PHDiagram2P" %#ok<IFBDUP>
        block.RegBlockMethod("Start",@StartPHDiagram2P);
        block.RegBlockMethod("Outputs",@OutputsPHDiagram2P);
        block.RegBlockMethod("Terminate",@TerminatePHDiagram2P);
    else

        block.RegBlockMethod("Start",@StartPHDiagram2P);
        block.RegBlockMethod("Outputs",@OutputsPHDiagram2P);
        block.RegBlockMethod("Terminate",@TerminatePHDiagram2P);
    end

end



function SetInputPortDimensions(block,idx,dim)

    block.InputPort(idx).Dimensions=dim;

end



function PostPropagationSetup(block)

    if any(block.InputPort(1).Dimensions~=block.InputPort(2).Dimensions)
        throwAsCaller(MSLException(block.BlockHandle,...
        message("physmod:fluids:diagrams:InputsSameDim")))
    end

end



function StartPHDiagram2P(block)

    fluids.internal.diagrams.PHDiagram2P.Start(...
    get_param(block.BlockHandle,"Parent"),prod(block.InputPort(1).Dimensions))

end



function OutputsPHDiagram2P(block)

    fluids.internal.diagrams.PHDiagram2P.Outputs(...
    get_param(block.BlockHandle,"Parent"),...
    block.InputPort(1).Data,block.InputPort(2).Data,block.CurrentTime)

end



function TerminatePHDiagram2P(block)

    fluids.internal.diagrams.PHDiagram2P.Terminate(...
    get_param(block.BlockHandle,"Parent"))

end