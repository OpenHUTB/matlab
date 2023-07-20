


























function BlockDataTypeTable=loc_createBlockDataTypeTable
    BlockDataTypeTable=[];
    idx=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';



    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Band-Limited\nWhite Noise');
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=1;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Chirp Signal');
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Clock';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='DigitalClock';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='FromFile';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='FromWorkspace';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='DiscretePulseGenerator';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=1;
    BlockDataTypeTable(idx).C2=1;
    BlockDataTypeTable(idx).C2ParamName='PulseType';
    BlockDataTypeTable(idx).C2ParamValue='Time based';
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;


    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Ramp');
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Repeating\nSequence');
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).MaskType='Sigbuilder block';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SignalGenerator';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Sin';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=1;
    BlockDataTypeTable(idx).C2ParamName='SineType';
    BlockDataTypeTable(idx).C2ParamValue='Time based';
    BlockDataTypeTable(idx).C3=1;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Step';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Stop';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='ToFile';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Derivative';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Integrator';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='StateSpace';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='TransferFcn';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='TransportDelay';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='VariableTransportDelay';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='ZeroPole';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Math\nOperations/Algebraic Constraint');
    BlockDataTypeTable(idx).RTWenable=0;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Signal\nRouting/Manual Switch');
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Discrete/First-Order\nHold');
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;


    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='InitialCondition';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='HitCross';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='MATLABFcn';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).RTWenable=0;
    BlockDataTypeTable(idx).C1=0;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).MaskType='Fixed-Point Repeating Sequence Interpolated';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=1;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).MaskType='Fixed-Point Derivative';
    BlockDataTypeTable(idx).RTWenable=1;
    BlockDataTypeTable(idx).C1=1;
    BlockDataTypeTable(idx).C2=0;
    BlockDataTypeTable(idx).C3=0;
    BlockDataTypeTable(idx).N1=0;














