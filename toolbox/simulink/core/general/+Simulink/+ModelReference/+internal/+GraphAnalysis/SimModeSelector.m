classdef SimModeSelector<handle





    properties(Access=protected)
        MyAnalyzer;
        MyTable;
    end


    methods(Sealed)

        function this=SimModeSelector(analyzer)
            this.MyAnalyzer=analyzer;
            this.MyTable=[];
        end


        function result=getQueryResult(obj)

            obj.MyTable=obj.MyAnalyzer.getTable();
            options=obj.MyAnalyzer.getOptions();


            indices=obj.getIndices();


            result=obj.MyTable(indices,{'Name','IsLoaded','BlockPath'});
            result.Properties.VariableNames{'Name'}='RefModel';


            if strcmpi(options.ResultView,'File')

                [models,ind]=unique(result.RefModel,'stable');

                isloaded=result.IsLoaded(ind);


                blocks={};
                for i=1:length(models)
                    blocks=[blocks;...
                    {unique(result.BlockPath(strcmp(result.RefModel,models{i})),'stable')}];%#ok<AGROW>
                end


                aTable=table(models,isloaded,blocks,'VariableNames',...
                {'RefModel','IsLoaded','BlockPath'});
                result=aTable;
            end
        end
    end


    methods(Access=protected)

        function indices=getIndices(obj)
            indices=(1:size(obj.MyTable.Tag,1))';
        end
    end
end