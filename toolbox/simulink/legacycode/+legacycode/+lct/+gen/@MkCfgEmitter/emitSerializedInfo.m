




function emitSerializedInfo(this,codeWriter)

    bodyTxt={...
    '%% ------------------------------------------------------------------------',...
    'function info = get_serialized_info()',...
''...
    };

    cellfun(@(aLine)codeWriter.wLine(aLine),bodyTxt);


    fieldNames={...
    'SFunctionName',...
    'IncPaths',...
    'SrcPaths',...
    'LibPaths',...
    'SourceFiles',...
    'HostLibFiles',...
    'TargetLibFiles'};

    nbFields=numel(fieldNames);


    codeWriter.wLine('% Allocate the output structure array');
    codeWriter.wLine('info(1:%d) = struct(...',numel(this.EmittingLctObjs));
    for ii=1:nbFields
        switch class(this.EmittingLctObjs(1).(fieldNames{ii}))
        case 'char'
            initStr='''''';
        case 'cell'
            initStr='{{}}';
        otherwise

        end
        codeWriter.wLine('    ''%s'', %s,...',fieldNames{ii},initStr);
    end


    codeWriter.wLine('    ''singleCPPMexFile'', false,...');


    codeWriter.wLine('    ''Language'', ''''...');
    codeWriter.wLine('    );');


    for ii=1:numel(this.EmittingLctObjs)

        codeWriter.wLine('% Dependency info for S-function ''%s''',this.EmittingLctObjs(ii).SFunctionName);
        txtBuffer='';
        for jj=1:nbFields
            switch class(this.EmittingLctObjs(ii).(fieldNames{jj}))
            case 'char'
                if~isempty(this.EmittingLctObjs(ii).(fieldNames{jj}))
                    txtBuffer=[txtBuffer,...
                    sprintf('info(%d).%s = ''%s'';\n',...
                    ii,fieldNames{jj},this.EmittingLctObjs(ii).(fieldNames{jj}))];%#ok
                end

            case 'cell'
                if~cellfun('isempty',this.EmittingLctObjs(ii).(fieldNames{jj}))
                    txtBuffer=[txtBuffer,...
                    sprintf('info(%d).%s = {',ii,fieldNames{jj})];%#ok
                    sep='';
                    c=char(this.EmittingLctObjs(ii).(fieldNames{jj}));
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

        if this.EmittingObjsIsSingleCPPMexFile

            txtBuffer=[txtBuffer,...
            sprintf('info(%d).singleCPPMexFile = %d;\n',ii,this.EmittingLctObjs(ii).Options.singleCPPMexFile)];%#ok

        end


        txtBuffer=[txtBuffer,...
        sprintf('info(%d).Language = ''%s'';',ii,this.EmittingLctObjs(ii).Options.language)];%#ok
        codeWriter.wLine(txtBuffer);

    end

    codeWriter.wNewLine;
