classdef MatrixTransactionStrategy<lutdesigner.editor.DataTransactionStrategy

    methods(Access=protected)

        function features=getDisablePropertyEditFeaturesForDataSourceImpl(~,dataProxy)
            restrictions=dataProxy.getWriteRestrictionsFor('Value');
            isTableValueReadOnly=~isempty(restrictions);

            features={};
            if isTableValueReadOnly
                features{end+1}=LUTWidget.DisableTableEdit;
            end
        end

        function readFromDataSourceImpl(~,dataProxy,dataModel)

            restrictions=dataProxy.getReadRestrictionsFor('Value');
            if~isempty(restrictions)
                error(restrictions(1).Reason);
            end

            value=dataProxy.Value;
            if isvector(value)
                numAxesInProxy=1;
            else
                numAxesInProxy=ndims(value);
            end


            axes=arrayfun(@(i)LUTWidget.Axis,1:numAxesInProxy);
            for i=1:numAxesInProxy
                axes(i).Value=LUTWidget.UnknownDataSource;
                axes(i).FieldName=['Dimension',num2str(i)];
            end


            table=LUTWidget.Table;


            table.Value=value;


            if isempty(dataProxy.getReadRestrictionsFor('FieldName'))
                table.FieldName=dataProxy.FieldName;
            else
                table.FieldName='Value';
            end


            otherFields=setdiff(dataModel.FieldNames,{'Value','FieldName'});
            for j=1:numel(otherFields)
                fieldName=otherFields{j};
                if isempty(dataProxy.getReadRestrictionsFor(fieldName))
                    table.(fieldName)=dataProxy.(fieldName);
                end
            end


            dataModel.setBaselineData(table,axes);
        end

        function writeToDataSourceImpl(~,dataProxy,dataModel)
            for j=1:numel(dataModel.FieldNames)
                fieldName=dataModel.FieldNames{j};
                if isempty(dataProxy.getWriteRestrictionsFor(fieldName))
                    dataProxy.(fieldName)=dataModel.Table.(fieldName);
                end
            end
        end
    end
end
