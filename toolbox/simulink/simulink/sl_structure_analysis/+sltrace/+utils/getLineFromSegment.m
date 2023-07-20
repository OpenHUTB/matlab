function line=getLineFromSegment(seg)
    lineParent=seg;
    line=[];
    while(lineParent~=-1)
        line=[line,lineParent];
        lineParent=get_param(lineParent,'LineParent');
    end
    flip(line);
end