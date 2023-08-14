function res=lineHasUnconnectedOutport(line)




    terminators=SLStudio.Utils.getLineOutportTerminators(line);
    res=~isempty(terminators);
end
