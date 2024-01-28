classdef MatrixModel<handle

    properties(Access=protected)
Model
MatrixModelElement
zcModelRow
zcModelCol
MatrixName
    end


    methods

        function this=MatrixModel(model)
            this.Model=model;
        end
    end


    methods(Access=protected)

        function generateMatrixRow(this,elem,matrix,parentRow,metadata)
            blnIsReferenceModel=this.isReferenceModel(elem);
            if(blnIsReferenceModel)
                id=elem.UUID;
                label=elem.Name;
                iconClass='architectureReference_16';
            elseif(isa(elem,'systemcomposer.arch.Model'))
                id=elem.Architecture.UUID;
                label=elem.Architecture.Name;
                iconClass='composition_model_16';
            elseif(isa(elem,'systemcomposer.arch.BaseComponent'))
                id=elem.Architecture.UUID;
                label=elem.Architecture.Name;
                iconClass='component_16';
            end

            if(isempty(parentRow))
                row=matrix.createRow(label);
            else
                row=parentRow.createSubRow(label);
            end
            row.p_SemanticElementId=id;
            row.p_Tooltip=label;
            row.p_IconClass=iconClass;

            metadata.rows(id)=row;
            if(metadata.isDeriveReferenceArch...
                ||(~metadata.isDeriveReferenceArch&&~blnIsReferenceModel))

                components=elem.Architecture.Components;
                for indexComponent=1:numel(components)

                    component=components(indexComponent);
                    this.generateMatrixRow(component,matrix,row,metadata);
                end
            end
        end


        function generateMatrixColumn(this,elem,matrix,parentCol,metadata)
            blnIsReferenceModel=this.isReferenceModel(elem);
            if(blnIsReferenceModel)
                id=elem.UUID;
                label=elem.Name;
                iconClass='architectureReference_16';
            elseif(isa(elem,'systemcomposer.arch.Model'))
                id=elem.Architecture.UUID;
                label=elem.Architecture.Name;
                iconClass='composition_model_16';
            elseif(isa(elem,'systemcomposer.arch.BaseComponent'))
                id=elem.Architecture.UUID;
                label=elem.Architecture.Name;
                iconClass='component_16';
            end

            if(isempty(parentCol))
                col=matrix.createColumn(label,'');
            else
                col=parentCol.createSubColumn(label,'');
            end
            col.p_SemanticElementId=id;
            col.p_Tooltip=label;
            col.p_IconClass=iconClass;

            metadata.cols(id)=col;

            if(metadata.isDeriveReferenceArch...
                ||(~metadata.isDeriveReferenceArch&&~blnIsReferenceModel))

                components=elem.Architecture.Components;
                for indexComponent=1:numel(components)

                    component=components(indexComponent);
                    this.generateMatrixColumn(component,matrix,col,metadata);
                end
            end
        end


        function bln=isReferenceModel(~,archElem)
            bln=ismethod(archElem,'isReference')&&archElem.isReference();
        end

    end
end

