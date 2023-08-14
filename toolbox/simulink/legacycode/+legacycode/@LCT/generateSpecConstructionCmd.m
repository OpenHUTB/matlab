function txtBuffer=generateSpecConstructionCmd(iStruct,type)







    narginchk(1,2);


    if nargin<2
        type='c';
    else
        type=lower(type);
    end


    defaultStruct=legacycode.LCT.getSpecStruct(false);
    defaultOptions=legacycode.LCT.getSpecStruct(true).Options;


    fieldNames=fieldnames(iStruct);


    offsetStr='     ';
    txtBuffer=sprintf('%sdef = legacy_code(''initialize'');\n',offsetStr);


    for ii=1:length(fieldNames)


        if~isfield(defaultStruct,fieldNames{ii})
            continue
        end


        defaultVal=defaultStruct.(fieldNames{ii});
        currentVal=iStruct.(fieldNames{ii});
        if isstring(currentVal)
            if ischar(defaultVal)&&isscalar(currentVal)
                currentVal=char(currentVal);
            elseif iscell(defaultVal)
                currentVal=cellstr(currentVal);
            end
        end

        switch class(currentVal)
        case 'char'
            if~isempty(currentVal)
                if~strcmp(currentVal,defaultVal)
                    txtBuffer=sprintf('%s%sdef.%s = ''%s'';\n',...
                    txtBuffer,offsetStr,fieldNames{ii},currentVal);
                end
            end

        case 'cell'

            if~cellfun('isempty',currentVal)
                txtBuffer=sprintf('%s%sdef.%s = {',txtBuffer,offsetStr,fieldNames{ii});
                sep='';
                c=char(currentVal);
                for jj=1:size(c,1)
                    txtBuffer=sprintf('%s%s''%s''',txtBuffer,sep,deblank(c(jj,:)));
                    sep=', ';
                end
                txtBuffer=sprintf('%s};\n',txtBuffer);
            end

        case 'struct'
            if strcmp(fieldNames{ii},'Options')

                actualOptions=iStruct.Options;


                optFieldNames=fieldnames(actualOptions);


                for jj=1:length(optFieldNames)
                    if~isfield(defaultOptions,optFieldNames{jj})

                        continue
                    end
                    defaultOptVal=defaultOptions.(optFieldNames{jj});
                    currentOptVal=actualOptions.(optFieldNames{jj});
                    if ischar(defaultOptVal)
                        if~strcmp(currentOptVal,defaultOptVal)
                            txtBuffer=sprintf('%s%sdef.%s.%s = ''%s'';\n',...
                            txtBuffer,offsetStr,fieldNames{ii},optFieldNames{jj},currentOptVal);
                        end
                    else
                        if(currentOptVal~=defaultOptVal)
                            txtBuffer=sprintf('%s%sdef.%s.%s = %s;\n',...
                            txtBuffer,offsetStr,fieldNames{ii},optFieldNames{jj},mat2str(currentOptVal));
                        end
                    end
                end
            end

        otherwise
            if isnumeric(currentVal)
                txtBuffer=sprintf('%s%sdef.%s = %s;\n',txtBuffer,...
                offsetStr,fieldNames{ii},mat2str(currentVal));
            end

        end
    end

    if strcmp(type,'c')
        txtBuffer=[txtBuffer,sprintf('%slegacy_code(''sfcn_cmex_generate'', def);\n',offsetStr)];
        txtBuffer=[txtBuffer,sprintf('%slegacy_code(''compile'', def);',offsetStr)];
    else
        txtBuffer=[txtBuffer,sprintf('%slegacy_code(''sfcn_tlc_generate'', def);',offsetStr)];
    end


