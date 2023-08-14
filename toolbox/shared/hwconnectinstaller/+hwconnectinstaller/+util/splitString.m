function substr=splitString(asciistr,columnWidth)






    persistent charwidth
    if isempty(charwidth)
        charwidth=hwconnectinstaller.util.getCharacterWidthMapping;
    end
    substr={};


    while(numel(asciistr)>0)
        indx=getSubStringIndex(asciistr,charwidth,columnWidth);
        tempsubstr=asciistr(1:indx);
        space=find(tempsubstr==32);
        if indx<numel(asciistr)&&~isempty(space)
            splitindex=space(end);
            substr{end+1}=asciistr(1:splitindex-1);
            asciistr=asciistr(splitindex+1:end);
        else
            tempasciistr=asciistr(indx+1:end);
            nextspace=find(tempasciistr==32);
            if isempty(nextspace)
                substr{end+1}=asciistr(1:end);%#ok<*AGROW>
                asciistr='';
            else
                substr{end+1}=[asciistr(1:indx),tempasciistr(1:nextspace-1)];
                asciistr=tempasciistr(nextspace+1:end);
            end

        end
    end
end

function i=getSubStringIndex(asciistr,charwidth,columnWidth)

    sum=0;
    fractlength=charwidth(asciistr);

    for i=1:numel(asciistr)
        sum=sum+fractlength(i);
        if sum>=columnWidth-1
            break;
        end
    end

end
