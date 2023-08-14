



function emitInputOutputDimsRegistration(this,codeWriter,dataSpec,checkForDynSize,defaultStr,setValStmts)



    if nargin<6
        setValStmts={};
    end



    if nargin<5
        defaultStr='init';
    end



    if nargin<4
        checkForDynSize=true;
    end



    mustGardSetVal=checkForDynSize&&~strcmpi(defaultStr,'init');


    dataRole=char(dataSpec.Kind);
    dataIdx=dataSpec.Id-1;


    dimStr=legacycode.lct.gen.ExprSFunEmitter.emitAllDims(this.LctSpecInfo,dataSpec,defaultStr);
    nbDims=numel(dimStr);


    codeWriter.wBlockStart();

    if nbDims==1

        varName=sprintf('%sWidth',dataSpec.Identifier);
        codeWriter.wLine('int_T %s = %s;',varName,dimStr{1});


        stmts=legacycode.lct.gen.SFunEmitter.genCheckDimension(dataSpec,checkForDynSize,dimStr{1},varName);
        cellfun(@(aLine)codeWriter.wLine(aLine),stmts);

        if mustGardSetVal

            codeWriter.wBlockStart('if (%s != DYNAMICALLY_SIZED)',varName);
        end

        if isempty(setValStmts)

            codeWriter.wLine('ssSet%sPortWidth(S, %d, %s);',dataRole,dataIdx,varName);
        else

            cellfun(@(aLine)codeWriter.wLine(aLine),setValStmts);
        end

        if mustGardSetVal

            codeWriter.wBlockEnd();
        end

    elseif nbDims==2

        varNumRows=sprintf('%sNumRows',dataSpec.Identifier);
        varNumCols=sprintf('%sNumCols',dataSpec.Identifier);
        codeWriter.wLine('int_T %s = %s;',varNumRows,dimStr{1});
        codeWriter.wLine('int_T %s = %s;',varNumCols,dimStr{2});


        stmts=legacycode.lct.gen.SFunEmitter.genCheckDimension(...
        dataSpec,checkForDynSize,dimStr,{varNumRows,varNumCols});
        cellfun(@(aLine)codeWriter.wLine(aLine),stmts);

        if mustGardSetVal

            codeWriter.wBlockStart('if ((%s != DYNAMICALLY_SIZED) && (%s != DYNAMICALLY_SIZED))',...
            varNumRows,varNumCols);
        end

        if isempty(setValStmts)

            codeWriter.wLine('ssSet%sPortMatrixDimensions(S, %d, %s, %s);',...
            dataRole,dataIdx,varNumRows,varNumCols);
        else

            cellfun(@(aLine)codeWriter.wLine(aLine),setValStmts);
        end

        if mustGardSetVal

            codeWriter.wBlockEnd();
        end
    else
        if ismember('DYNAMICALLY_SIZED',dimStr)&&strcmpi(defaultStr,'init')


            codeWriter.wLine('ssSet%sPortDimensionInfo(S,  %d, DYNAMIC_DIMENSION);',dataRole,dataIdx);
        else

            varName=sprintf('%sDimsInfo',dataSpec.Identifier);
            codeWriter.wLine('DECL_AND_INIT_DIMSINFO(%s);',varName);

            if mustGardSetVal


                codeWriter.wLine('boolean_T hasDynSize = 0;');
            end


            nbDims=length(dimStr);
            varDims=sprintf('%sDims',dataSpec.Identifier);
            codeWriter.wLine('int_T %s[%d];',varDims,nbDims);
            codeWriter.wLine('%s.numDims = %d;',varName,nbDims);
            codeWriter.wNewLine;


            widthStr='';
            multStr='';
            for ii=1:nbDims

                codeWriter.wNewLine;
                codeWriter.wLine('%s[%d] = %s;',varDims,ii-1,dimStr{ii});


                stmts=legacycode.lct.gen.SFunEmitter.genCheckDimension(...
                dataSpec,checkForDynSize,dimStr{ii},varDims,ii);
                cellfun(@(aLine)codeWriter.wLine(aLine),stmts);


                widthStr=sprintf('%s %s %s[%d]',widthStr,multStr,varDims,ii-1);
                multStr='*';

                if mustGardSetVal

                    codeWriter.wLine('if (%s[%d]==DYNAMICALLY_SIZED) {',varDims,ii-1);
                    codeWriter.wLine('    hasDynSize |= 1;');
                    codeWriter.wLine('}');
                end
            end


            codeWriter.wNewLine;
            codeWriter.wLine('%s.dims = &%s[0];',varName,varDims);
            codeWriter.wLine('%s.width = %s;',varName,widthStr);
            codeWriter.wNewLine;

            if mustGardSetVal

                codeWriter.wBlockStart('if (!hasDynSize)');
            end

            if isempty(setValStmts)

                codeWriter.wLine('ssSet%sPortDimensionInfo(S,  %d, &%s);',...
                dataRole,dataIdx,varName);
            else

                cellfun(@(aLine)codeWriter.wLine(aLine),setValStmts);
            end

            if mustGardSetVal

                codeWriter.wBlockEnd();
            end
        end
    end


    codeWriter.wBlockEnd();


