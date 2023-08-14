function string=toMScript(value)













    if ischar(value)&&...
        ~iscellstr(value)&&...
        (isrow(value)||isempty(value))
        string=loc_string(value);

    elseif iscell(value)


        string=loc_matrixToString(value,{'{','}'},true);
    elseif isscalar(value)
        if isnumeric(value)
            string=loc_numeric(value);
        elseif isstruct(value)
            string=loc_structToString(value);
        elseif islogical(value)
            string=loc_logicalToString(value);
        elseif isobject(value)
            try
                string=value.serialize();
            catch mEX %#ok<NASGU>
                warning('configset.internal.util.toMScript: value has unknown type.');
                string='[]';
            end
        else

            warning('configset.internal.util.toMScript: value has unknown type.');
            string='[]';
        end
    else

        string=loc_matrixToString(value,{'[',']'},false);
    end




    function string=loc_matrixToString(value,braces,isCell)
        [rows,cols]=size(value);

        strVal=braces{1};
        for i=1:rows
            for j=1:cols
                if isCell
                    elementValue=configset.internal.util.toMScript(value{i,j});
                else
                    elementValue=configset.internal.util.toMScript(value(i,j));
                end

                strVal=[strVal,elementValue];%#ok<AGROW>

                if j<cols
                    strVal=[strVal,','];%#ok<AGROW>
                end
            end
            if i<rows
                strVal=[strVal,';'];%#ok<AGROW>
            end
        end
        string=[strVal,braces{2}];


        function string=loc_structToString(value)
            quote='''';
            fields=fieldnames(value);
            len=length(fields);
            structarray='';

            for i=1:len
                fieldVal=value.(fields{i});
                if iscell(fieldVal)


                    fieldVal=['{',configset.internal.util.toMScript(fieldVal),'}'];
                else
                    fieldVal=configset.internal.util.toMScript(fieldVal);
                end

                if isempty(structarray)
                    structarray=[quote,fields{i},quote,',',fieldVal];
                else
                    structarray=[structarray,',',quote,fields{i},quote,',',fieldVal];%#ok<AGROW>
                end
            end

            string=['struct(',structarray,')'];


            function string=loc_string(value)
                quote='''';
                newLinePos=strfind(value,newline);
                value=regexprep(value,'''','''''');

                if isempty(newLinePos)
                    tmp=[quote,value,quote];
                    string=tmp;
                else
                    numOfMultiLines=length(newLinePos);

                    if newLinePos(length(newLinePos))<length(value)
                        numOfMultiLines=numOfMultiLines+1;
                    end

                    arg=[quote,strrep(value,newline,''','''),quote];

                    command=['sprintf(',quote];
                    for k=1:numOfMultiLines
                        temp=command;

                        if k==numOfMultiLines
                            command=[temp,'%s'];
                        else
                            command=[temp,'%s\n'];
                        end
                    end

                    string=[command,quote,',',arg,')'];
                end


                function string=loc_numeric(value)
                    quote='''';

                    string=num2str(value,'%.15G');

                    if isempty(value)
                        string=[quote,quote];
                    end


                    function string=loc_logicalToString(value)
                        if value
                            string='true';
                        else
                            string='false';
                        end
