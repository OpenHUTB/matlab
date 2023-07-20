classdef(Hidden)LogicalTaskDataCreationCoder<datacreation.internal.TaskDataCreationCoder






    methods


        function yValCode=genYDataValueCode(obj)

            fcnH=str2func(obj.app.getState().DataType);


            if strcmpi(obj.app.getState().VectorType,'Column')||...
                strcmpi(obj.app.getState().StorageType,'timetable')
                yValCode=mat2str(logical(obj.app.getState().Data.y));
            else
                yValCode=mat2str(logical(obj.app.getState().Data.y'));
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

            code=[code,datacreation.internal.CodeGenUtil.generatePlotCodeSequence(obj.genVarNameCode(),...
            '[0 114 189]/255','New data','1.5','stairs')];
            code=[code,newline,sprintf('legend;')];

            code=[code,newline];

        end


        function code=genVisualizationScriptForTable(obj)


            code=datacreation.internal.CodeGenUtil.generateDisplayComments();
            code=[code,'clf;',newline];

            code=[code,datacreation.internal.CodeGenUtil.generatePlotCodeSequence(...
            [obj.genVarNameCode(),'.',obj.app.getState().ColumnName],...
            '[0 114 189]/255','New data','1.5','stairs')];
            code=[code,newline,sprintf('legend;')];

            code=[code,newline];

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
            [obj.genVarNameCode(),'.Time'],...
            [obj.genVarNameCode(),'.',obj.app.getState().ColumnName],...
            '[0 114 189]/255','New data','1.5','stairs')];
            code=[code,newline,sprintf('legend;'),newline];

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

            code=[code,newline,datacreation.internal.CodeGenUtil.generatePlotCodeTimeBased(...
            [obj.genVarNameCode(),'.Time'],...
            [obj.genVarNameCode(),'.Data'],...
            '[0 114 189]/255','New data','1.5','stairs')];
            code=[code,newline,'hold off',newline,sprintf('legend;')];

            code=[code,newline];

        end
    end
end
