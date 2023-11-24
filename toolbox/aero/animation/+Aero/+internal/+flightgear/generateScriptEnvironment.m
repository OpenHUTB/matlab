function lines=generateScriptEnvironment(h,operatingSystem)

    lines=repmat(string,0);

    switch operatingSystem
    case "PCWIN64"
        lines(1)="SET FG_ROOT="+h.FlightGearBaseDirectory+"\data";
    case "GLNXA64"
        lines(1)="export FG_ROOT="+h.FlightGearBaseDirectory+"/data";
        lines(2)="export PATH=$PATH:$FG_ROOT/../bin";
        lines(3)="export FG_SCENERY=$FG_ROOT/Scenery:$FG_ROOT/WorldScenery";
    case{"MACI64","MACA64"}
        lines(1)="export FG_ROOT="+h.FlightGearBaseDirectory;
    end


    lines=lines(:);
end
