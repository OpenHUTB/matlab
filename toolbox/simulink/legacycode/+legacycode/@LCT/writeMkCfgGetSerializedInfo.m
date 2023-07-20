function writeMkCfgGetSerializedInfo(h,fid,singleCPPMexFile)





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function info = get_serialized_info()\n');
    fprintf(fid,'\n');


    fieldNames={...
    'SFunctionName',...
    'IncPaths',...
    'SrcPaths',...
    'LibPaths',...
    'SourceFiles',...
    'HostLibFiles',...
    'TargetLibFiles'};

    nbFields=length(fieldNames);


    fprintf(fid,'%% Allocate the output structure array\n');
    fprintf(fid,'info(1:%d) = struct(...\n',length(h));
    for ii=1:nbFields
        switch class(h(1).(fieldNames{ii}))
        case 'char'
            initStr='''''';
        case 'cell'
            initStr='{{}}';
        otherwise

        end
        fprintf(fid,'    ''%s'', %s,...\n',fieldNames{ii},initStr);
    end

    if singleCPPMexFile

        fprintf(fid,'    ''singleCPPMexFile'', false,...\n');
    end


    fprintf(fid,'    ''Language'', ''''...\n');
    fprintf(fid,'    );\n');
    fprintf(fid,'\n');


    for ii=1:length(h)

        fprintf(fid,'%% Dependency info for S-function ''%s''\n',h(ii).SFunctionName);
        txtBuffer='';
        for jj=1:nbFields
            switch class(h(ii).(fieldNames{jj}))
            case 'char'
                if~isempty(h(ii).(fieldNames{jj}))
                    txtBuffer=[txtBuffer,...
                    sprintf('info(%d).%s = ''%s'';\n',ii,fieldNames{jj},h(ii).(fieldNames{jj}))];%#ok
                end

            case 'cell'
                if~cellfun('isempty',h(ii).(fieldNames{jj}))
                    txtBuffer=[txtBuffer,...
                    sprintf('info(%d).%s = {',ii,fieldNames{jj})];%#ok
                    sep='';
                    c=char(h(ii).(fieldNames{jj}));
                    for kk=1:size(c,1)
                        txtBuffer=[txtBuffer,...
                        sprintf('%s''%s''',sep,deblank(c(kk,:)))];%#ok
                        sep=', ';
                    end
                    txtBuffer=[txtBuffer,sprintf('};\n')];%#ok
                end


            otherwise

            end

        end

        if singleCPPMexFile

            txtBuffer=[txtBuffer,...
            sprintf('info(%d).singleCPPMexFile = %d;\n',ii,h(ii).Options.singleCPPMexFile)];%#ok
            fwrite(fid,txtBuffer);
        end


        txtBuffer=[txtBuffer,...
        sprintf('info(%d).Language = ''%s'';\n',ii,h(ii).Options.language)];%#ok
        fwrite(fid,txtBuffer);

    end

    fprintf(fid,'\n');

