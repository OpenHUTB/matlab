classdef(Sealed)MemoryUsageTableBuilder<handle





    properties(Constant)

        MetaData=struct(...
        'MemoryColumnName','MemoryUsage',...
        'MemoryDescription',message('SimulinkFixedPoint:functionApproximation:descriptionForMemoryColumn').getString(),...
        'PathsColumnName','BlockPath',...
        'PathDescription',message('SimulinkFixedPoint:functionApproximation:descriptionForBlockPathColumn').getString(),...
        'TotalMemoryUserDataPropertyName','TotalMemory')
    end

    methods
        function usageTable=build(this,context)




            database=context.DataBase;
            descriptionGenerator=context.DescriptionGenerator;
            pathForDescription=context.Path;



            usageTable=getEmptyTable(this,numel(database));


            allPaths=getAllPaths(this,database);
            usageTable{:,this.MetaData.PathsColumnName}=string(allPaths);


            memoryUsage=getMemoryUsage(this,database);
            usageTable{:,this.MetaData.MemoryColumnName}=memoryUsage;


            usageTable=sortrows(usageTable,this.MetaData.MemoryColumnName,'descend');


            rowNames=string(1:numel(allPaths));
            usageTable.Properties.RowNames=rowNames;


            usageTable.Properties.Description=descriptionGenerator.generate(pathForDescription);
            usageTable.Properties.VariableUnits={'','bytes'};
            usageTable.Properties.VariableDescriptions={this.MetaData.PathDescription,this.MetaData.MemoryDescription};


            sumOfMemory=sum(usageTable{:,this.MetaData.MemoryColumnName});
            usageTable.Properties.UserData.(this.MetaData.TotalMemoryUserDataPropertyName)=sumOfMemory;
        end
    end

    methods(Hidden)
        function memoryUsage=getMemoryUsage(~,database)


            memoryUsage=cellfun(@(x)x.MemoryUsage.getBytes(),database);
        end

        function allPaths=getAllPaths(~,database)


            allPaths=cellfun(@(x)x.Path,database,'UniformOutput',false);
            nRows=numel(allPaths);
            for iPath=1:nRows
                allPaths{iPath}=Simulink.BlockPath(allPaths{iPath}).convertToCell{1};
            end
        end

        function usageTable=getEmptyTable(this,nRows)



            columnNames={this.MetaData.PathsColumnName,this.MetaData.MemoryColumnName};
            usageTable=table('Size',[nRows,2],'VariableTypes',{'string','double'},'VariableNames',columnNames);
        end
    end
end