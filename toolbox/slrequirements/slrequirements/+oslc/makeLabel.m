function label=makeLabel(id,title,projectName)









    customTemplate=rmipref('OslcLabelTemplate');

    if isempty(customTemplate)

        label=makeDefaultLabel(id,title,projectName);

    else
        label=makeCustomLabel(customTemplate,id,title,projectName);
    end
end

function label=makeDefaultLabel(id,title,projectName)
    shortTitle=trimLength(title,40);
    label=getString(message('Slvnv:oslc:MakeLabel',shortTitle,id,projectName));
end

function label=makeCustomLabel(labelTemplate,id,title,projectName)
















    matchTrimTag=regexp(labelTemplate,'%\d+','match');
    if~isempty(matchTrimTag)
        trimTag=matchTrimTag{1};
        labelTemplate=regexprep(labelTemplate,trimTag,'');
        maxLength=str2num(trimTag(2:end));%#ok<ST2NM>
    else
        maxLength=0;
    end

    templateLength=length(labelTemplate);
    formatIdx=find(labelTemplate=='%');
    if isempty(formatIdx)
        label=makeDefaultLabel(id,title,projectName);
    else
        label='';
        pos=1;
        for i=formatIdx
            label=[label,labelTemplate(pos:i-1)];%#ok<AGROW>
            if i>=templateLength
                break;
            end
            switch labelTemplate(i+1)
            case 'h'
                label=[label,title];%#ok<AGROW>
            case 'n'
                label=[label,id];%#ok<AGROW>
            case 'P'
                label=[label,projectName];%#ok<AGROW>
            otherwise
                caller='oslc.makeLabel()';
                unsupportedFormat=labelTemplate(i:i+1);
                supportedFormats='%n (item number), %h (item heading or title), %P (project name)';
                rmiut.warnNoBacktrace('Slvnv:oslc:UnsupportedLabelFormat',caller,unsupportedFormat,supportedFormats);
            end
            pos=i+2;
        end
        if pos<=templateLength
            label=[label,labelTemplate(pos:end)];
        end
    end
    if maxLength>0
        label=trimLength(label,maxLength);
    end
end

function value=trimLength(value,max)
    if length(value)>max
        value=[value(1:max),'...'];
    end
end

