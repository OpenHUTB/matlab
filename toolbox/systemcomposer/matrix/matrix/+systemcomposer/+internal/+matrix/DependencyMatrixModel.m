classdef DependencyMatrixModel<systemcomposer.internal.matrix.MatrixModel

    properties(Access=private)
zcModel
    end


    methods

        function this=DependencyMatrixModel(model)

            this=this@systemcomposer.internal.matrix.MatrixModel(model);
        end


        function MatrixModelElement=toDependencyMatrixModel(this,matrixName,zcModel)

            this.MatrixName=matrixName;
            this.zcModel=zcModel;
            this.MatrixModelElement=systemcomposer.syntax.matrix.TreeTable.make(this.Model,this.MatrixName);

            metadata.rows=containers.Map;
            metadata.cols=containers.Map;
            metadata.isDeriveReferenceArch=false;
            this.generateMatrixRow(this.zcModel,this.MatrixModelElement,'',metadata);

            this.generateMatrixColumn(this.zcModel,this.MatrixModelElement,'',metadata);

            this.generatMatrixCell(zcModel,metadata);

            this.generatMatrixDisabledCell(metadata);

            MatrixModelElement=this.MatrixModelElement;
        end
    end


    methods(Access=private)

        function generatMatrixCell(this,elem,metadata)

            archElem=elem.Architecture;
            rowId=archElem.UUID;
            row='';

            if(metadata.rows.isKey(rowId))
                row=metadata.rows(rowId);
            end


            if(isa(elem,'systemcomposer.arch.BaseComponent')&&~isempty(elem.Ports))

                ports=elem.Ports;

                this.generatMatrixCellHelper(row,ports,metadata);

            elseif(~isempty(archElem.Ports))

                ports=archElem.Ports;
                this.generatMatrixCellHelper(row,ports,metadata);
            end


            blnIsReferenceModel=this.isReferenceModel(elem);
            if(~blnIsReferenceModel)

                components=elem.Architecture.Components;
                for indexComponent=1:numel(components)

                    component=components(indexComponent);
                    this.generatMatrixCell(component,metadata);
                end
            end
        end


        function generatMatrixCellHelper(this,row,ports,metadata)

            colId='';
            col='';

            for indexPorts=1:numel(ports)

                port=ports(indexPorts);
                connectors=port.Connectors;

                for indexConnector=1:numel(connectors)

                    connector=connectors(indexConnector);
                    isDependency=false;

                    if(port.Direction==systemcomposer.arch.PortDirection.Input...
                        &&isa(port,'systemcomposer.arch.ArchitecturePort'))

                        isDependency=true;

                    elseif(port.Direction==systemcomposer.arch.PortDirection.Output...
                        &&isa(port,'systemcomposer.arch.ComponentPort'))

                        isDependency=true;
                    end

                    if(isDependency&&~isempty(connector.DestinationPort)...
                        &&~isempty(connector.DestinationPort.Parent)...
                        &&isa(connector.DestinationPort.Parent,'systemcomposer.arch.Architecture'))

                        colId=connector.DestinationPort.Parent.UUID;

                    elseif(isDependency&&~isempty(connector.DestinationPort)...
                        &&~isempty(connector.DestinationPort.Parent)...
                        &&isa(connector.DestinationPort.Parent,'systemcomposer.arch.BaseComponent')...
                        &&~isempty(connector.DestinationPort.Parent.Architecture))

                        colId=connector.DestinationPort.Parent.Architecture.UUID;
                    end


                    if(~isempty(colId)&&metadata.cols.isKey(colId))
                        col=metadata.cols(colId);
                    end

                    if(~isempty(row)&&~isempty(col))

                        cell=row.createCell(col,'');
                        cell.p_CellWidget=systemcomposer.syntax.matrix.Label(this.Model);
                        cell.p_CellWidget.p_Tooltip="Row: "+row.p_Label+" | "+"Column: "+col.p_Label;
                        cell.p_CellWidget.p_IconClass='allocation_dot_16';
                    end

                end

            end
        end




        function generatMatrixDisabledCell(~,metadata)

            rows=metadata.rows.keys;

            for indexRow=1:numel(rows)

                rowId=string(rows(indexRow));
                row=metadata.rows(rowId);
                col=metadata.cols(rowId);

                if(strcmp(row.p_SemanticElementId,col.p_SemanticElementId))
                    cell=row.createCell(col,'');
                    cell.p_Disabled=true;
                end
            end
        end
    end
end

