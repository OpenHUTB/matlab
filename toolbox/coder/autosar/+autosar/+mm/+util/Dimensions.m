



classdef Dimensions<handle





    properties(Access=private)

        DimCell;



        SymbolDefinitions;
    end

    methods(Access=public)
        function this=Dimensions(dims,symbolDefs)










            if 1<nargin
                this.SymbolDefinitions=symbolDefs;
            else
                this.SymbolDefinitions=containers.Map();
            end

            if nargin<1
                this.DimCell={};
            else
                this.DimCell=this.populateDimensions(dims);
            end
        end

        function dimList=populateDimensions(this,dims)







            if isa(dims,'autosar.mm.util.Dimensions')
                dimList=dims.getDimCell();
            elseif ischar(dims)||isStringScalar(dims)
                dimList={autosar.mm.util.FormulaExpression(dims,this.SymbolDefinitions)};
            elseif iscell(dims)
                dimList=...
                cellfun(@(expr)autosar.mm.util.FormulaExpression(expr,this.SymbolDefinitions),dims,'UniformOutput',false);
            elseif ismatrix(dims)
                assert(isnumeric(dims),'Dimension array expected to be numeric.');
                dimList=this.populateDimensions(num2cell(dims));
            elseif isa(dims,'M3I.SequenceOfString')
                dimList=cell(dims.size(),1);
                for ii=1:dims.size()
                    dimList{ii}=autosar.mm.util.FormulaExpression.createFromARXML(dims.at(ii),this.SymbolDefinitions);
                end
            elseif isa(dims,'M3I.SequenceOfInteger')
                dimList=cell(dims.size(),1);
                for ii=1:dims.size()
                    dimList{ii}=autosar.mm.util.FormulaExpression(dims.at(ii),this.SymbolDefinitions);
                end
            else
                dimList={autosar.mm.util.FormulaExpression(dims,this.SymbolDefinitions)};
            end
        end

        function dimcell=getDimCell(this)
            dimcell=this.DimCell;
        end

        function ret=containsSymbols(this)


            ret=any(cellfun(@(x)x.containsSymbols(),this.DimCell));
        end

        function[expr,expressions]=toString(this)


            expressions=[];
            if 1<length(this.DimCell)
                if this.containsSymbols
                    separator=', ';
                else
                    separator=' ';
                end

                expressions=cellfun(@(x)x.expression(),this.DimCell,'UniformOutput',false);
                expr=['[',strjoin(expressions,separator),']'];
            else
                expr=this.DimCell{1}.expression();
            end
        end

        function expr=evaluated(this)





            expr=ones(1,length(this.DimCell));
            for ii=1:length(this.DimCell)
                expr(ii)=this.DimCell{ii}.evaluated();
            end
        end

        function[dims,expressions]=dataObjStyle(this)





















            expressions=[];
            if 1<length(this.evaluated())
                if this.containsSymbols()
                    [dims,expressions]=this.toString();
                    if~isempty(expressions)
                        for ii=1:numel(expressions)
                            expressions{ii}=['[',expressions{ii},', 1]'];
                        end
                    end
                else
                    dims=this.evaluated();
                end
            else
                if this.containsSymbols()
                    dims=['[',this.DimCell{1}.expression(),', 1]'];
                else
                    dims=[this.DimCell{1}.evaluated(),1];
                end
            end
        end

        function append(this,dims)
            newDims=this.populateDimensions(dims);
            this.DimCell=[this.DimCell,newDims];
        end

        function setSymbolDefinitionsMap(this,symbolDefs)



            this.SymbolDefinitions=symbolDefs;
        end
    end
end



