classdef Cell<internal.mtree.Type





    properties(Access=public)
        cellTypes(:,:)internal.mtree.Type=internal.mtree.Type.empty
    end

    methods(Access=public)

        function this=Cell(dimensions,typeArr)
            this=this@internal.mtree.Type(dimensions);



            if nargin>1
                assert(isequal(this.Dimensions,size(typeArr)),'Cell type dimensions must match size of input type array');
                assert(isa(typeArr,'internal.mtree.Type'),'Cell type array must use valid Type elements');
                this.cellTypes=typeArr;
            else
                this.cellTypes=repmat(internal.mtree.type.UnknownType,this.Dimensions);
            end
        end

        function name=getMLName(~)
            name='cell';
        end

        function type=toSlName(~)
            type='cell';
        end

        function doesit=supportsExampleValues(this)


            for i=1:numel(this.cellTypes)
                if~this.cellTypes(i).supportsExampleValues
                    doesit=false;
                    return
                end
            end
            doesit=true;
        end

    end

    methods(Access=protected)

        function exVal=getExampleValueScalar(~)%#ok<STOUT> 
            error('Use getExampleValue for Cell types, not getExampleValueScalar');
        end

        function exStr=getExampleValueStringScalar(~)%#ok<STOUT> 
            error('Use getExampleValueString for Cell types, not getExampleValueStringScalar');
        end

        function res=isTypeEqualScalar(this,other)

            if isa(other,'internal.mtree.type.Cell')
                if this.Dimensions~=other.Dimensions
                    res=false;
                else
                    res=true;
                    for i=1:numel(this.cellTypes)
                        typeThis=this.cellTypes(i);
                        typeOther=other.cellTypes(i);
                        res=res&&typeThis.eq(typeOther);
                    end
                end
            else
                res=false;
            end
        end

        function type=toScalarPIRType(~)%#ok<STOUT> 
            error('Cannot create scalar PIR type for cell base type');
        end
    end

    methods(Access=public)

        function setCellType(this,idx,type)
            this.cellTypes(idx)=type;
        end

        function type=getCellType(this,idx)
            type=this.cellTypes(idx);
        end

        function setDimensions(this,dimIn)

            setDimensions@internal.mtree.Type(this,dimIn);


            if~isequal(this.Dimensions,size(this.cellTypes))
                oldLen=numel(this.cellTypes);
                newLen=prod(this.Dimensions);

                if newLen<=oldLen


                    this.cellTypes=reshape(this.cellTypes(1:newLen),this.Dimensions);
                else


                    oldTypes=this.cellTypes;
                    this.cellTypes=repmat(internal.mtree.type.UnknownType,this.Dimensions);
                    this.cellTypes(1:oldLen)=oldTypes(:);
                end
            end
        end

        function exVal=getExampleValue(this)


            exVal=cell(this.Dimensions);

            for i=1:numel(exVal)
                if~isempty(this.cellTypes(i))
                    exVal{i}=getExampleValue(this.cellTypes(i));
                end
            end
        end

        function exStr=getExampleValueString(this)



            cellStr='reshape({';
            nCells=numel(this.cellTypes);

            for i=1:nCells-1
                cellStr=strcat(cellStr,this.cellTypes(i).getExampleValueString,',');
            end
            i=nCells;
            cellStr=strcat(cellStr,this.cellTypes(i).getExampleValueString);

            exStr=strcat(cellStr,'},',mat2str(this.Dimensions),')');
        end
    end
end


