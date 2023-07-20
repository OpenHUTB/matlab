classdef LookupTableTransactionStrategy<lutdesigner.editor.DataTransactionStrategy

    methods(Access=protected)

        function features=getDisablePropertyEditFeaturesForDataSourceImpl(~,dataProxy)
            numAxesInProxy=dataProxy.NumDims;
            isAxisValueReadOnly=false(numAxesInProxy,1);

            for i=1:numAxesInProxy
                axisProxy=dataProxy.getAxisProxy(i);
                readRestrictions=axisProxy.getReadRestrictionsFor('Value');
                writeRestrictions=axisProxy.getWriteRestrictionsFor('Value');
                isAxisValueReadOnly(i)=isempty(readRestrictions)&&~isempty(writeRestrictions);
            end
            tableProxy=dataProxy.getTableProxy();
            isTableValueReadOnly=~isempty(tableProxy.getWriteRestrictionsFor('Value'));

            features={};
            if any(isAxisValueReadOnly)
                features{end+1}=LUTWidget.DisableAxesEdit;
            end
            if isTableValueReadOnly
                features{end+1}=LUTWidget.DisableTableEdit;
            end
        end

        function readFromDataSourceImpl(~,dataProxy,dataModel)

            tableProxy=dataProxy.getTableProxy();
            restrictions=tableProxy.getReadRestrictionsFor('Value');
            if~isempty(restrictions)
                error(restrictions(1).Reason);
            end

            numAxesInProxy=dataProxy.NumDims;
            metaDataFields=setdiff(dataModel.FieldNames,{'Value'});


            axes=arrayfun(@(i)LUTWidget.Axis,1:numAxesInProxy);
            for i=1:numAxesInProxy
                axisProxy=dataProxy.getAxisProxy(i);


                restrictions=axisProxy.getReadRestrictionsFor('Value');
                if isempty(restrictions)
                    axes(i).Value=axisProxy.Value;
                else
                    axes(i).Value=LUTWidget.UnknownDataSource;
                end


                for j=1:numel(metaDataFields)
                    fieldName=metaDataFields{j};
                    if isempty(axisProxy.getReadRestrictionsFor(fieldName))
                        axes(i).(fieldName)=axisProxy.(fieldName);
                    end
                end
            end


            table=LUTWidget.Table;


            table.Value=tableProxy.Value;


            for j=1:numel(metaDataFields)
                fieldName=metaDataFields{j};
                if isempty(tableProxy.getReadRestrictionsFor(fieldName))
                    table.(fieldName)=tableProxy.(fieldName);
                end
            end


            dataModel.setBaselineData(table,axes);
        end

        function writeToDataSourceImpl(~,dataProxy,dataModel)
            numAxesInModel=numel(dataModel.Axes);
            numAxesInProxy=dataProxy.NumDims;
            restrictions=getNumDimsWriteRestrictions(dataProxy);
            assert(isempty(restrictions)||numAxesInModel==numAxesInProxy);
            if numAxesInModel~=numAxesInProxy
                dataProxy.NumDims=numAxesInModel;
            end

            for i=1:numAxesInModel
                axisProxy=dataProxy.getAxisProxy(i);
                for j=1:numel(dataModel.FieldNames)
                    fieldName=dataModel.FieldNames{j};
                    if isempty(axisProxy.getWriteRestrictionsFor(fieldName))
                        axisProxy.(fieldName)=dataModel.Axes(i).(fieldName);
                    end
                end
            end

            tableProxy=dataProxy.getTableProxy();
            for j=1:numel(dataModel.FieldNames)
                fieldName=dataModel.FieldNames{j};
                if isempty(tableProxy.getWriteRestrictionsFor(fieldName))
                    tableProxy.(fieldName)=dataModel.Table.(fieldName);
                end
            end
        end
    end
end
