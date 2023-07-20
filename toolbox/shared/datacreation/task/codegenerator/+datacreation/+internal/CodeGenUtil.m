classdef CodeGenUtil<handle





    methods(Static)


        function codeOut=generateCreateCommentLine(varType,inDataType)
            codeOut=['% Create a ',varType,' with data type ',inDataType,'.',newline];
        end


        function code=codeConformer(codeIn)

            NUM_CHAR_PER_LINE=80;

            INSERT_BREAK_LINE_CHAR_ARRAY=[' ...',newline];
            INSERT_AUTO_TAB=blanks(4);

            if length(codeIn)<=NUM_CHAR_PER_LINE

                code=codeIn;
                return;

            end

            code='';
            codeLeft=codeIn;

            delimeter={';',',',' ','(',')','[',']','='};


            if~contains(codeLeft,delimeter)
                code=codeIn;
                return;
            end

            k=NUM_CHAR_PER_LINE-5;

            while~any(strcmp(codeLeft(k),delimeter))
                k=k-1;
            end

            code=[code,codeLeft(1:k),INSERT_BREAK_LINE_CHAR_ARRAY];
            codeLeft=codeLeft(k+1:end);

            while length(codeLeft)>80

                k=NUM_CHAR_PER_LINE-(length(INSERT_BREAK_LINE_CHAR_ARRAY)+...
                length(INSERT_AUTO_TAB));


                if~contains(codeLeft(1:k),delimeter)

                    while~contains(codeLeft(1:k),delimeter)
                        k=k+1;
                    end
                end


                while~any(strcmp(codeLeft(k),delimeter))
                    k=k-1;
                end


                code=[code,INSERT_AUTO_TAB,codeLeft(1:k),INSERT_BREAK_LINE_CHAR_ARRAY];
                codeLeft=codeLeft(k+1:end);
            end

            code=[code,INSERT_AUTO_TAB,codeLeft];
        end


        function code=generateVector(varNameCode,dataTypeIn,dataValuesStr)

            if strcmpi(dataTypeIn,'logical')||...
                strcmpi(dataTypeIn,'boolean')||...
                ~isempty(enumeration(dataTypeIn))

                code=[varNameCode,' = '...
                ,dataValuesStr,';'];
                code=datacreation.internal.CodeGenUtil.codeConformer(code);
                return;
            end



            code=[varNameCode,' = '...
            ,dataTypeIn,'(',dataValuesStr,');'];
            code=datacreation.internal.CodeGenUtil.codeConformer(code);

        end


        function code=generateTable(varNameCode,dataTypeIn,dataValuesStr,columnName)

            if strcmpi(dataTypeIn,'logical')||...
                strcmpi(dataTypeIn,'boolean')||...
                ~isempty(enumeration(dataTypeIn))

                code=[varNameCode,' = table('...
                ,dataValuesStr,');'];
                code=datacreation.internal.CodeGenUtil.codeConformer(code);
                code=[code,newline,varNameCode...
                ,'.Properties.VariableNames = "'...
                ,columnName,'";',newline];
                return;
            end


            code=[varNameCode,' = table('...
            ,dataTypeIn,'(',dataValuesStr,'));'];
            code=datacreation.internal.CodeGenUtil.codeConformer(code);
            codeVarNameAssign=[varNameCode...
            ,'.Properties.VariableNames = "'...
            ,columnName,'";'];
            code=[code,newline,codeVarNameAssign,newline];

        end


        function code=generateTimeTable(varNameCode,dataTypeCode,...
            timeValueStr,dataValuesStr,columnName,durationDataType)

            if strcmpi(dataTypeCode,'logical')||...
                strcmpi(dataTypeCode,'boolean')||...
                ~isempty(enumeration(dataTypeCode))

                leftHandSide=['timetable(',durationDataType,'(',timeValueStr,'),'...
                ,dataValuesStr,');',newline];

                code=[varNameCode,' = '...
                ,leftHandSide];
                code=datacreation.internal.CodeGenUtil.codeConformer(code);
                code=[code,varNameCode...
                ,'.Properties.VariableNames = "'...
                ,columnName,'";',newline];
                return;
            end


            leftHandSide=['timetable(',durationDataType,'(',timeValueStr,'),'...
            ,dataTypeCode,'(',dataValuesStr,'));',newline];

            code=[varNameCode,' = '...
            ,leftHandSide];
            code=datacreation.internal.CodeGenUtil.codeConformer(code);
            code=[code,[varNameCode...
            ,'.Properties.VariableNames = "'...
            ,columnName,'";'],newline];

        end


        function code=generateTimeseries(varNameCode,dataTypeCode,...
            timeValueStr,dataValuesStr)


            if strcmpi(dataTypeCode,'logical')||...
                strcmpi(dataTypeCode,'boolean')||...
                ~isempty(enumeration(dataTypeCode))

                leftHandSide=['timeseries(',dataValuesStr,','...
                ,timeValueStr,');',newline];

                code=[varNameCode,' = '...
                ,leftHandSide];
                code=datacreation.internal.CodeGenUtil.codeConformer(code);
                return;
            end


            leftHandSide=['timeseries(',dataTypeCode,'(',dataValuesStr,'),'...
            ,timeValueStr,');',newline];

            code=[varNameCode,' = '...
            ,leftHandSide];
            code=datacreation.internal.CodeGenUtil.codeConformer(code);

        end


        function code=generateDataArray(varNameCode,~,...
            timeValueStr,dataValuesStr)






            leftHandSide=['[',timeValueStr,' ',dataValuesStr,'];',newline];

            code=[varNameCode,' = '...
            ,leftHandSide];
            code=datacreation.internal.CodeGenUtil.codeConformer(code);

        end


        function code=generateDisplayComments()
            code=['% Display results',newline];
        end


        function code=generatePlotCodeSequence(inSequenceVals,colorString,displayName,lineWidthString,varargin)

            colorStr=['"Color",',colorString];
            displayNameStr=['"DisplayName","',displayName,'"'];

            plotCmd='plot';

            if~isempty(varargin)&&any(strcmp(varargin{1},{'plot','stairs'}))
                plotCmd=varargin{1};
            end
            if isempty(lineWidthString)

                code=sprintf([plotCmd,'(',inSequenceVals,',%s,%s);'],...
                colorStr,displayNameStr);
            else
                lineWidthStr=['"LineWidth",',lineWidthString];
                code=sprintf([plotCmd,'(',inSequenceVals,',%s,%s,%s);'],...
                colorStr,lineWidthStr,displayNameStr);
            end

            code=datacreation.internal.CodeGenUtil.codeConformer(code);
        end


        function code=generatePlotCodeTimeBased(inTimeVals,...
            inSequenceVals,colorString,displayName,lineWidthString,varargin)


            colorStr=['"Color",',colorString];
            displayNameStr=['"DisplayName","',displayName,'"'];
            plotCmd='plot';

            if~isempty(varargin)&&any(strcmp(varargin{1},{'plot','stairs'}))
                plotCmd=varargin{1};
            end
            if isempty(lineWidthString)

                code=sprintf([plotCmd,'(',inTimeVals,',',inSequenceVals,',%s,%s);'],...
                colorStr,displayNameStr);
            else
                lineWidthStr=['"LineWidth",',lineWidthString];
                code=sprintf([plotCmd,'(',inTimeVals,',',inSequenceVals,',%s,%s,%s);'],...
                colorStr,lineWidthStr,displayNameStr);
            end

            code=datacreation.internal.CodeGenUtil.codeConformer(code);

        end
    end
end
