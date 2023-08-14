function[outT,tableStats,timeStats,tooltips,tableStatsTooltips,timetableStatsTooltips]=createSummaryTable(inputData)



    tableStats=struct();
    timeStats=struct();
    tooltips=string.empty;
    tableStatsTooltips=string.empty;
    timetableStatsTooltips=string.empty;
    if~isempty(inputData)
        t=inputData;
        if~isa(t,'tabular')
            t=array2table(t);
        end
        st=varfun(@matlab.internal.preprocessingApp.tabular.getSummaryStats,t,'OutputFormat','table');
        st.Properties.VariableNames=t.Properties.VariableNames;

        if istimetable(t)
            stats=matlab.internal.preprocessingApp.tabular.getSummaryStats(t.Properties.RowTimes);
            st.(t.Properties.DimensionNames{1})=stats;
            st=movevars(st,t.Properties.DimensionNames{1},"Before",t.Properties.VariableNames{1});
        end


        varNames=st.Properties.VariableNames;
        allFieldNames=fieldnames(st{1,1});
        for i=1:length(varNames)
            ns=struct();
            for j=1:length(allFieldNames)
                val="";
                if isfield(st.(varNames{i}),allFieldNames{j})
                    val=st.(varNames{i}).(allFieldNames{j});

                    if isdatetime(val)||isduration(val)
                        val=strtrim(evalc("disp(val)"));
                    elseif isnan(val)
                        val="";
                    elseif ischar(val)||iscellstr(val)
                        val=string(val);
                    elseif~islogical(val)

                    elseif(val)
                        val=string(getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:True')));
                    else
                        val=string(getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:False')));
                    end
                end
                ns.(allFieldNames{j})=val;
            end
            outST(i)=ns;%#ok<AGROW>
        end

        outT=struct2table(outST,'AsArray',true);
        outT.IsSorted=categorical(outT.IsSorted);
        outT.Type=categorical(outT.Type);
        outT.HasDuplicates=categorical(outT.HasDuplicates);
        try
            outT.Properties.RowNames=varNames;
        catch
            for i=1:length(varNames)
                try
                    outT.Properties.RowNames{i}=varNames{i};
                catch
                    outT.Properties.RowNames{i}=...
                    char(internal.matlab.datatoolsservices.VariableUtils.generateUniqueName(varNames{i},...
                    varNames,[]));
                end
            end
        end


        tableStats=struct();
        timeStats=struct();
        tableStats.DataType=string(class(inputData));
        if isa(inputData,'tabular')
            tableStats.NumVariables=string(width(t));
            tableStats.NumObservations=string(height(t));
            columnsWithMissing=cellfun(@(c)c(1),varfun(@(v)v.NumMissing~=0,st,'OutputFormat',"cell"));
            numVarsWithMissing=sum(columnsWithMissing);
            tableStats.NumVarsWithMissing=string(numVarsWithMissing);
            columnsWithDuplicates=cellfun(@(c)c(1),varfun(@(v)v.HasDuplicates,st,'OutputFormat',"cell"));
            numVarsWithDuplicates=sum(columnsWithDuplicates);
            tableStats.NumVarsWithDuplicates=string(numVarsWithDuplicates);


            if istimetable(t)
                if isregular(t)
                    tableStats.IsRegular=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:True'));
                else
                    tableStats.IsRegular=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:False'));
                end
                timestampHasMissing=st.(t.Properties.DimensionNames{1}).NumMissing~=0;
                tableStats.TimestampHasMissing=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:False'));
                if timestampHasMissing
                    tableStats.NumVarsWithMissing=string(numVarsWithMissing-1);
                    tableStats.TimestampHasMissing=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:True'));
                end
                timestampHasDuplicates=st.(t.Properties.DimensionNames{1}).HasDuplicates;
                tableStats.TimestampHasDuplicates=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:False'));
                if timestampHasDuplicates
                    tableStats.NumVarsWithDuplicates=string(numVarsWithDuplicates-1);
                    tableStats.TimestampHasDuplicates=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:True'));
                end
                tableStats.TimestampIsSorted=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:False'));
                if issorted(t.(t.Properties.DimensionNames{1}),'ascend')
                    tableStats.TimestampIsSorted=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:True'))+" ("+...
                    getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:TimestampSortDirectionAscending'))+")";
                elseif issorted(t.(t.Properties.DimensionNames{1}),'descend')
                    tableStats.TimestampIsSorted=getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:True'))+" ("+...
                    getString(message('MATLAB:datatools:preprocessing:tabular:summaryStats:TimestampSortDirectionDescending'))+")";
                end

                timeStats.IsRegular=tableStats.IsRegular;
                timeStats.TimestampHasMissing=tableStats.TimestampHasMissing;
                timeStats.TimestampHasDuplicates=tableStats.TimestampHasDuplicates;
                timeStats.TimestampIsSorted=tableStats.TimestampIsSorted;
            end
        else
            tableStats.NumRows=string(size(t,1));
            tableStats.NumColumns=string(size(t,2));
        end


        varNames=outT.Properties.VariableNames;
        tooltips=repmat("",length(varNames),1);
        for i=1:length(varNames)
            tooltips(i)=matlab.internal.preprocessingApp.tabular.statFieldToTooltip(varNames{i});
            varNames{i}=matlab.internal.preprocessingApp.tabular.statFieldToDisplayName(varNames{i});
        end

        outT.Properties.VariableNames=varNames;


        tableStatsFields=fieldnames(tableStats);
        tableStatsTooltips=repmat("",length(tableStatsFields),1);
        for i=1:length(tableStatsFields)
            tableStatsTooltips(i)=matlab.internal.preprocessingApp.tabular.statFieldToTooltip(tableStatsFields{i});
        end
        timetableStatsFields=fieldnames(timeStats);
        timetableStatsTooltips=repmat("",length(timetableStatsFields),1);
        for i=1:length(timetableStatsFields)
            timetableStatsTooltips(i)=matlab.internal.preprocessingApp.tabular.statFieldToTooltip(timetableStatsFields{i});
        end
    else
        outT=matlab.internal.preprocessingApp.tabular.getSummaryStats([]);
        outT=struct2table(outT,'AsArray',true);
        outT(1,:)=[];
        tableStats=struct();
    end
end
