function out=getClassName(rpt)
    out=fliplr(strtok(fliplr(class(rpt)),'.'));
end
