function lineName=getLineName(this,lineNum)



    hLines=getAllLines(this);
    if lineNum<=numel(hLines)
        lineName=get(hLines(lineNum),'DisplayName');
    else
        lineName='';
    end
end
