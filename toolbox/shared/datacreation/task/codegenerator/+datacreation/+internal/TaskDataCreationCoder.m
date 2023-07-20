classdef(Hidden)TaskDataCreationCoder<handle





    properties(Access=protected)
app
    end


    methods


        function obj=TaskDataCreationCoder(inApp)

            obj.app=inApp;

        end


        function boolOut=canGenerateCode(obj)


            boolOut=false;

            appState=obj.app.getState();


            if strcmpi(appState.DataType,'select')
                return;
            end

            if isempty(appState.Data)||isempty(appState.Data.x)
                return;
            end

            if any(strcmpi(appState.StorageType,{'table','timetable'}))
                if isempty(appState.ColumnName)
                    return;
                end
            end

            boolOut=true;

        end


        function[code,outputs]=generateScript(obj)
            code='';
            outputs={};

            if obj.canGenerateCode()

                switch lower(obj.app.getState().StorageType)
                case 'vector'

                    [code,outputs]=generateVectorScript(obj);

                case 'table'

                    [code,outputs]=generateTableScript(obj);

                case 'timetable'

                    [code,outputs]=generateTimeTableScript(obj);

                case 'timeseries'

                    [code,outputs]=generateTimeseriesScript(obj);

                case 'dataarray'

                    [code,outputs]=generateDataArrayScript(obj);
                end
            end
        end


        function[code,outputs]=generateVectorScript(obj)

            try

                [varNameCode,dataTypeCode,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            commentCode=datacreation.internal.CodeGenUtil.generateCreateCommentLine('vector',dataTypeCode);


            assignCode=datacreation.internal.CodeGenUtil.generateVector(varNameCode,...
            dataTypeCode,dataValueCode.yValCode);

            code=[commentCode,assignCode,newline];

            outputs={obj.genVarNameCode()};

        end


        function[code,outputs]=generateTableScript(obj)

            try

                [varNameCode,dataTypeCode,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            commentCode=datacreation.internal.CodeGenUtil.generateCreateCommentLine('table',dataTypeCode);

            code=[commentCode,datacreation.internal.CodeGenUtil.generateTable(...
            varNameCode,dataTypeCode,dataValueCode.yValCode,...
            obj.app.getState().ColumnName)];

            outputs={obj.genVarNameCode()};

        end


        function[code,outputs]=generateTimeTableScript(obj)

            try

                [varNameCode,dataTypeCode,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            commentCode=datacreation.internal.CodeGenUtil.generateCreateCommentLine('timetable',dataTypeCode);


            durationDataType=obj.app.getState().TimeDuration;
            code=datacreation.internal.CodeGenUtil.generateTimeTable(...
            varNameCode,dataTypeCode,dataValueCode.xValCode,dataValueCode.yValCode,...
            obj.app.getState().ColumnName,durationDataType);

            code=[commentCode,code];

            outputs={varNameCode};
        end


        function[code,outputs]=generateTimeseriesScript(obj)

            try

                [varNameCode,dataTypeCode,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            commentCode=datacreation.internal.CodeGenUtil.generateCreateCommentLine('timeseries',dataTypeCode);

            code=datacreation.internal.CodeGenUtil.generateTimeseries(...
            varNameCode,dataTypeCode,dataValueCode.xValCode,...
            dataValueCode.yValCode);

            code=[commentCode,code];

            outputs={varNameCode};
        end


        function[code,outputs]=generateDataArrayScript(obj)

            try

                [varNameCode,dataTypeCode,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            commentCode=datacreation.internal.CodeGenUtil.generateCreateCommentLine('data array',dataTypeCode);

            code=datacreation.internal.CodeGenUtil.generateDataArray(...
            varNameCode,dataTypeCode,dataValueCode.xValCode,...
            dataValueCode.yValCode);

            code=[commentCode,code];

            outputs={varNameCode};
        end


        function code=generateVisualizationScript(obj)

            code='';
            if obj.canGenerateCode()&&obj.app.getState().PlotOutput
                switch lower(obj.app.getState().StorageType)
                case 'vector'
                    code=genVisualizationScriptForVector(obj);
                case 'table'
                    code=genVisualizationScriptForTable(obj);
                case 'timetable'
                    code=genVisualizationScriptForTimeTable(obj);
                case 'timeseries'
                    code=genVisualizationScriptForTimeseries(obj);
                case 'dataarray'
                    code=genVisualizationScriptForDataArray(obj);
                otherwise
                    return;
                end
            end
        end


        function code=genVisualizationScriptForVector(obj)

            try

                [varNameCode,dataTypeCode,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            code=datacreation.internal.CodeGenUtil.generateDisplayComments();
            code=[code,'clf;',newline];

            code=[code,datacreation.internal.CodeGenUtil.generatePlotCodeSequence(dataValueCode.yValCode,...
            '[109 185 226]/255','Input data',[])];
            code=[code,newline,'hold on'];

            code=[code,newline,datacreation.internal.CodeGenUtil.generatePlotCodeSequence(obj.genVarNameCode(),...
            '[0 114 189]/255','New data','1.5')];
            code=[code,newline,'hold off',newline,sprintf('legend;')];

            code=[code,newline];

        end


        function code=genRemoveVectorVariables(obj)

            code=['% Remove temporary variables from Workspace',newline];
            code=[code,'clear yData'];
        end


        function code=genVisualizationScriptForTable(obj)

            try

                [~,~,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            code=datacreation.internal.CodeGenUtil.generateDisplayComments();
            code=[code,'clf;',newline];

            code=[code,datacreation.internal.CodeGenUtil.generatePlotCodeSequence(dataValueCode.yValCode,...
            '[109 185 226]/255','Input data',[])];
            code=[code,newline,'hold on'];

            code=[code,newline,datacreation.internal.CodeGenUtil.generatePlotCodeSequence(...
            [obj.genVarNameCode(),'.',obj.app.getState().ColumnName],...
            '[0 114 189]/255','New data','1.5')];
            code=[code,newline,'hold off',newline,sprintf('legend;')];

            code=[code,newline];

        end


        function code=genRemoveTimeTableVariables(obj)

            code=['% Remove temporary variables from Workspace',newline];
            code=[code,'clear xData yData'];
        end


        function code=genVisualizationScriptForTimeTable(obj)

            try

                [~,~,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            code=datacreation.internal.CodeGenUtil.generateDisplayComments();
            code=[code,'clf;',newline];

            code=[code,datacreation.internal.CodeGenUtil.generatePlotCodeTimeBased(...
            [obj.app.getState().TimeDuration,'(',dataValueCode.xValCode,')'],dataValueCode.yValCode,...
            '[109 185 226]/255','Input data',[])];
            code=[code,newline,'hold on'];

            code=[code,newline,datacreation.internal.CodeGenUtil.generatePlotCodeTimeBased(...
            [obj.genVarNameCode(),'.Time'],...
            [obj.genVarNameCode(),'.',obj.app.getState().ColumnName],...
            '[0 114 189]/255','New data','1.5')];
            code=[code,newline,'hold off',newline,sprintf('legend;')];

            code=[code,newline];

        end


        function code=genVisualizationScriptForTimeseries(obj)

            try

                [~,~,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            code=datacreation.internal.CodeGenUtil.generateDisplayComments();
            code=[code,'clf;',newline];

            code=[code,datacreation.internal.CodeGenUtil.generatePlotCodeTimeBased(...
            dataValueCode.xValCode,dataValueCode.yValCode,...
            '[109 185 226]/255','Input data',[])];
            code=[code,newline,'hold on'];

            code=[code,newline,datacreation.internal.CodeGenUtil.generatePlotCodeTimeBased(...
            [obj.genVarNameCode(),'.Time'],...
            [obj.genVarNameCode(),'.Data'],...
            '[0 114 189]/255','New data','1.5')];
            code=[code,newline,'hold off',newline,sprintf('legend;')];

            code=[code,newline];

        end


        function code=genVisualizationScriptForDataArray(obj)

            try

                [~,~,dataValueCode]=...
                getParametersForCodeGen(obj);
            catch ME
                rethrow(ME);
            end

            code=datacreation.internal.CodeGenUtil.generateDisplayComments();
            code=[code,'clf;',newline];

            code=[code,datacreation.internal.CodeGenUtil.generatePlotCodeTimeBased(...
            dataValueCode.xValCode,dataValueCode.yValCode,...
            '[109 185 226]/255','Input data',[])];
            code=[code,newline,'hold on'];

            code=[code,newline,datacreation.internal.CodeGenUtil.generatePlotCodeTimeBased(...
            [obj.genVarNameCode(),'(:,1)'],...
            [obj.genVarNameCode(),'(:,2)'],...
            '[0 114 189]/255','New data','1.5')];
            code=[code,newline,'hold off',newline,sprintf('legend;')];

            code=[code,newline];

        end


        function code=codeConformer(~,codeIn)

            code=datacreation.internal.CodeGenUtil.codeConformer(codeIn);
        end
    end





    methods(Access=public)


        function[varNameCode,dataTypeCode,dataValueCode]=...
            getParametersForCodeGen(obj)

            varNameCode=genVarNameCode(obj);
            dataTypeCode=genDataTypeCode(obj);
            [xValCode,yValCode]=genDataValueCode(obj);
            dataValueCode.xValCode=xValCode;
            dataValueCode.yValCode=yValCode;
        end


        function varNameCode=genVarNameCode(obj)
            varNameCode='createdSignal';
            if~isempty(obj.app.VarName)
                varNameCode=obj.app.VarName;
            end
        end


        function dataTypeCode=genDataTypeCode(obj)
            dataTypeCode=obj.app.getState().DataType;
        end


        function[xValCode,yValCode]=genDataValueCode(obj)


            xValCode=genXDataValueCode(obj);
            yValCode=genYDataValueCode(obj);
        end


        function xValCode=genXDataValueCode(obj)

            if strcmpi(obj.app.getState().VectorType,'Column')||...
                ~any(strcmpi(obj.app.getState().StorageType,{'vector','table'}))

                xValCode=mat2str(obj.app.getState().Data.x);
            else
                xValCode=mat2str(obj.app.getState().Data.x');
            end
        end


        function yValCode=genYDataValueCode(obj)

            if strcmpi(obj.app.getState().VectorType,'Column')||...
                ~any(strcmpi(obj.app.getState().StorageType,{'vector','table'}))
                yValCode=mat2str(obj.app.getState().Data.y);
            else
                yValCode=mat2str(obj.app.getState().Data.y');
            end
        end

    end
end
