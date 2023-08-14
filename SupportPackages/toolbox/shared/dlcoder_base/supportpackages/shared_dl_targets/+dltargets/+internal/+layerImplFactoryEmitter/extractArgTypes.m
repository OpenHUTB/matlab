





function argTypes=extractArgTypes(line,fid)





    argTypes={};


    assert(line(1)=='(','Formal parameter list passed to extractArgTypes does not start with an open parenthesis');
    line=line(2:end);

    endOfFormalParameterList=false;
    while~endOfFormalParameterList








        while contains(line,',')||contains(line,')')


            if contains(line,',')
                parameterEntry=extractBefore(line,',');



                line=extractAfter(line,[parameterEntry,',']);
            elseif contains(line,')')
                parameterEntry=extractBefore(line,')');



                line=extractAfter(line,[parameterEntry,')']);



                endOfFormalParameterList=true;
            end

            argType=iExtractArgType(parameterEntry);

            if~isempty(argType)
                argTypes=[argTypes,argType];%#ok
            end

            assert(~feof(fid)||endOfFormalParameterList,...
            'End of file reached before the end of the formal parameter list was found');
        end

        line=fgetl(fid);
    end
end
















function argType=iExtractArgType(parameterEntry)


    parameterEntry=regexprep(parameterEntry,'(/)(\*)[\w\s]*(\*)(/)','');




    parameterEntry=regexprep(parameterEntry,'\*',' * ');


    parameterEntry=regexprep(parameterEntry,'(\s)*\*','*');



    parameterEntry=strtrim(parameterEntry);






    splitParameterEntry=split(parameterEntry);


    numConsts=nnz(strcmp(splitParameterEntry,'const'));




    assert(numel(splitParameterEntry)==numConsts+1||numel(splitParameterEntry)==numConsts+2,...
    'Parameter entry should have a type and at most one type name');
    hasFormalParameterName=numel(splitParameterEntry)==numConsts+2;

    if hasFormalParameterName



        argType=strjoin(splitParameterEntry(1:end-1));
    else
        argType=strjoin(splitParameterEntry);
    end
end
