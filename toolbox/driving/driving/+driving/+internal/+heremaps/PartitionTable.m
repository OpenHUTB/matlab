classdef PartitionTable<handle











    properties(SetAccess=private)

Table
    end

    properties(Dependent)

TileIds


Layers
    end

    methods

        function this=PartitionTable()

            this.Table=driving.internal.heremaps.PartitionTable.createTable(0);
        end

        function add(this,newRows)











            rowsToAdd=~ismember(newRows(:,1:4),this.Table(:,1:4));


            this.Table=[this.Table;newRows(rowsToAdd,:)];
        end

        function replace(this,newRows)





            rowsToReplace=ismember(this.Table(:,1:4),newRows(:,1:4));


            this.Table(rowsToReplace,:)=newRows;
        end

        function T=findByLayer(this,layer)





            T=this.find('Layer',...
            driving.internal.heremaps.LayerType.(layer));
        end

        function T=find(this,var,value)





            T=this.Table(this.Table.(var)==value,:);
        end

        function tileIds=get.TileIds(this)

            tileIds=unique(this.Table.TileId);
        end

        function layers=get.Layers(this)

            layers=unique(string(this.Table.Layer));
        end

        function S=getTiledPartitions(this)
            G=findgroups(this.Table.TileId);
            S=splitapply(...
            @(id,L,F)makeTileStruct(id(1),L,F),...
            this.Table.TileId,this.Table.Layer,this.Table.FilePath,G);
        end

    end

    methods(Static)

        function T=createTable(numRows)








            variableNames={'Catalog','Version','TileId',...
            'Layer','DataURL','DataHandle','Checksum','FilePath'};
            variableTypes={'string','double','uint32',...
            'driving.internal.heremaps.LayerType','string',...
            'string','string','string'};


            T=table(...
            'Size',[numRows,numel(variableNames)],...
            'VariableTypes',variableTypes,...
            'VariableNames',variableNames);
        end

    end
end

function S=makeTileStruct(id,L,F)
    partitions=struct('Name',{L.Name},'FilePath',num2cell(F)');
    S=struct('TileId',id,'Partitions',partitions);
end