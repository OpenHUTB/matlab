function lines=generateScriptCommand(~,operatingSystem)

    lines="";

    switch operatingSystem
    case "PCWIN64"
        lines="START .\\bin\fgfs.exe";
    case "GLNXA64"

        lines="fgfs";
    case{"MACI64","MACA64"}
        lines="./../MacOS/fgfs";
    end

end
