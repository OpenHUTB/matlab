function report=extractEquationsReport(obj)

    fModechart=matlab.internal.feature("SSC2HDLModechart");

    if(fModechart)
        numStates=size(obj.EqnData.IC.X,1);
    else
        numStates=size(obj.EqnData.IC,1);
    end


    numModes=size(obj.EqnData.IM,1);
    numClumps=~isempty(obj.EqnData.DiffClumpInfo.DiffStates)+...
    numel(obj.EqnData.ClumpInfo);

    report{1}=['Number of States: ',num2str(numStates)];


    report{2}=['Number of Modes: ',num2str(numModes)];
    report{3}=['Number of Clumps: ',num2str(numClumps)];


end

