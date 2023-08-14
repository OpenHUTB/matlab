function res=lineHasUnconnectedInport(line)




    terminators=SLStudio.Utils.getLineInportTerminator(line);
    res=~isempty(terminators);
end
