function scriptText=generateScriptReference(blockPath)

















    scriptText="";
    blkPath=regexprep(blockPath,'\n',' ');


    params=get_param(blkPath,'DialogParameters');
    if isempty(params)
        return;
    end

    blkPathText=regexprep(blkPath,'''','''''');
    paramNames=fieldnames(params);
    for paramIdx=1:numel(paramNames)
        paramName=paramNames{paramIdx};
        param=params.(paramName);


        if isempty(param.Prompt)
            continue;
        end


        titleLineText=sprintf("%%%% %s <%s>\n",regexprep(param.Prompt,'\n',' '),paramName);
        scriptText=scriptText+titleLineText;


        getLineText=sprintf("  get_param('%s', '%s');\n",blkPathText,paramName);
        scriptText=scriptText+getLineText;


        paramValue=get_param(blkPath,paramName);
        if ismember('read-only',param.Attributes)
            setLineText=sprintf("%% '%s' is read-only.\n",paramName);
        else
            switch class(paramValue)
            case{'char','string'}
                setLineText=locHandleStringPrmValue(paramValue,blkPathText,paramName);
            otherwise
                setLineText=sprintf("%% set_param('%s', '%s', <%s>);\n",...
                blkPathText,paramName,[class(paramValue),' type value']);
            end
        end
        scriptText=scriptText+setLineText;
    end
end

function lineText=locHandleStringPrmValue(paramValue,blkPathText,paramName)


    if isa(paramValue,'string')&&numel(paramValue)>1

        lineText=sprintf("%% set_param('%s', '%s', <%s>);\n",...
        blkPathText,paramName,[class(paramValue),' array']);
        return;
    end

    paramValueText=regexprep(paramValue,'"','""');
    if contains(paramValue,newline)
        paramValueText=...
        regexprep(...
        regexprep(...
        regexprep(paramValueText,'%','%%'),...
        '\','\\'),...
        newline,'\\n');
        lineText=sprintf("  set_param('%s', '%s', sprintf(""%s""));\n",...
        blkPathText,paramName,paramValueText);
    else
        lineText=sprintf("  set_param('%s', '%s', ""%s"");\n",...
        blkPathText,paramName,paramValueText);
    end
end
