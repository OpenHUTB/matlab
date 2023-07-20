function num=lineNumUnconnectedOutports(line)




    terminators=SLStudio.Utils.getLineOutportTerminators(line);
    num=length(terminators);
end
