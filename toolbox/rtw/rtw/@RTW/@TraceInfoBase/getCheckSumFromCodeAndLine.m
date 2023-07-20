
function[checkSum]=getCheckSumFromCodeAndLine(~,comSum,file,line)




    if(ispc)

        index=find((strcmpi(file,comSum(1).file))==1);
    else
        index=find((strcmp(file,comSum(1).file))==1);
    end
    if(ischar(line))
        line=str2double(line);
    end
    cIndx=0;

    oldLine=line;
    while(cIndx==0)
        cIndx=comSum(index).lineToIndex(line);
        line=line-1;
    end
    offsetFromComment=oldLine-line-1;


    checkSum=comSum(index).cSum{cIndx(1)};


    line=line+1;
    lineOffset=0;
    while comSum(index).lineToIndex(line)==cIndx&&line>1
        line=line-1;
        lineOffset=lineOffset+1;
    end
    lineOffset=lineOffset-1;


    checkSum=sprintf('%s_%d',checkSum,lineOffset+offsetFromComment);
end
