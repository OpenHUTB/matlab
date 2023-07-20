






















function BlockDataTypeTable=createMisraBlockExcludeList
    BlockDataTypeTable=[];
    idx=0;

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Derivative';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Integrator';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    'simulink/Continuous/PID Controller';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    'simulink/Continuous/PID Controller (2DOF)';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='StateSpace';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='TransferFcn';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='TransportDelay';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='VariableTransportDelay';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='ZeroPole';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='HitCross';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='RateLimiter';
    BlockDataTypeTable(idx).ReferenceBlock='';






    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Discrete/First-Order\nHold');














































    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Model-Wide\nUtilities/Timed-Based\nLinearization');

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Model-Wide\nUtilities/Trigger-Based\nLinearization');















    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Stop';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='ToFile';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='ToWorkspace';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Sources/Band-Limited\nWhite Noise');

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Sources/Chirp Signal');

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Clock';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Sources/Counter\nFree-Running');

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Sources/Counter\nLimited');






    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Sources/Repeating\nSequence');

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=...
    sprintf('simulink/Sources/Repeating\nSequence\nInterpolated');

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='DigitalClock';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='FromFile';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='FromWorkspace';
    BlockDataTypeTable(idx).ReferenceBlock='';





    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock=sprintf('simulink/Sources/Ramp');






    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SubSystem';
    BlockDataTypeTable(idx).ReferenceBlock='';
    BlockDataTypeTable(idx).MaskType='Sigbuilder block';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='SignalGenerator';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Sin';
    BlockDataTypeTable(idx).ReferenceBlock='';

    idx=idx+1;
    BlockDataTypeTable(idx).BlockType='Step';
    BlockDataTypeTable(idx).ReferenceBlock='';


