classdef IndependentVariables<handle



    properties(SetAccess=private)
VariableNames
VariableValues
    end

    methods
        function obj=IndependentVariables(VarNamesMatrix,VarValuesMat)
            validateattributes(VarNamesMatrix,{'cell'},{'2d'},'','VariableNames')
            if~all(cellfun(@ischar,VarNamesMatrix))
                error(message('rf:rffile:shared:sandp2d:independentvariables:InvalidVarNames'))
            end

            validateattributes(VarValuesMat,{'cell'},{'2d'},'','VariableNames');
            if~all(cellfun(@isnumeric,VarValuesMat))
                error(message('rf:rffile:shared:sandp2d:independentvariables:InvalidVarValues'))
            end

            processVarData(obj,VarNamesMatrix,VarValuesMat)
        end
    end

    methods
        function set.VariableNames(obj,newVariableNames)
            validateattributes(newVariableNames,{'cell'},{'column'},'','VariableNames')
            obj.VariableNames=newVariableNames;
        end

        function set.VariableValues(obj,newVariableValues)
            validateattributes(newVariableValues,{'cell'},{'2d'},'','VariableValues')
            obj.VariableValues=newVariableValues;
        end
    end

    methods(Access=private,Hidden)
        function processVarData(obj,VarNamesMatrix,VarValuesMatrix)




            [numrowVarValues,numcolVarValues]=size(VarValuesMatrix);
            [numrowVarNames,numcolVarNames]=size(VarNamesMatrix);
            if~isequal(numrowVarNames,numrowVarValues)||~isequal(numcolVarValues,numcolVarNames)
                error(message('rf:rffile:shared:sandp2d:independentvariables:SizeErr'))
            end


            for ii=1:numrowVarNames
                if~isequal(numel(unique(lower(VarNamesMatrix(ii,:)))),1)
                    error(message('rf:rffile:shared:sandp2d:independentvariables:DiffNames'))
                end
            end


            if~isequal(numel(unique(lower(VarNamesMatrix(:,1)))),numel(VarNamesMatrix(:,1)))
                error(message('rf:rffile:shared:sandp2d:independentvariables:UniqueNames'))
            end

            numericVarValues=cell2mat(VarValuesMatrix);
            uniVarValues=cell(numrowVarValues,1);
            numuniqueVarValues=zeros(1,numrowVarValues);
            for ii=1:numrowVarValues
                uniVarValues{ii,:}=unique(numericVarValues(ii,:));

                if~isequal(uniVarValues{ii,:}(1),numericVarValues(ii,1))
                    uniVarValues{ii,:}=fliplr(uniVarValues{ii,:});
                end
                numuniqueVarValues(ii)=numel(uniVarValues{ii,:});
            end




            idealVarVals=zeros(numrowVarValues,prod(numuniqueVarValues));
            for ii=1:numrowVarValues
                tempidealVarvals=[];
                for jj=1:numuniqueVarValues(ii)
                    tempidealVarvals(:,((jj-1)*prod(numuniqueVarValues(ii+1:end)))+1:jj*prod(numuniqueVarValues(ii+1:end)))=repmat(uniVarValues{ii}(jj),[1,prod(numuniqueVarValues(ii+1:end))]);
                end
                if isequal(ii,1)
                    idealVarVals(ii,:)=tempidealVarvals;
                else
                    idealVarVals(ii,:)=repmat(tempidealVarvals,[1,prod([1,numuniqueVarValues(1:ii-1)])]);
                end
            end


            if~isequal(idealVarVals,numericVarValues)
                error(message('rf:rffile:shared:sandp2d:independentvariables:NonMonotonic'))
            end

            obj.VariableNames=lower(VarNamesMatrix(:,1));
            obj.VariableValues=uniVarValues;
        end
    end

    methods
        function out=getindex(obj,varargin)


            narginchk(2,Inf);
            if isequal(numel(varargin),1)
                if~isnumeric(varargin{1})||isnan(varargin{1})
                    error(message('rf:rffile:shared:sandp2d:independentvariables:NumericIndex'))
                end
                if~isempty(obj)&&(varargin{1})>prod(cellfun(@length,obj.VariableValues))
                    error(message('rf:rffile:shared:sandp2d:independentvariables:IndexExceeds'));
                end
                out=varargin{:};
            else
                if mod(numel(varargin),2)
                    error(message('rf:rffile:shared:sandp2d:independentvariables:OddNVInput'))
                end

                numVarNames=numel(obj.VariableNames);
                numVarValues=numel(obj.VariableValues);

                if~isequal(numel(varargin),numVarNames+numVarValues)
                    error(message('rf:rffile:shared:sandp2d:independentvariables:BadNVInput'))
                end


                namecntr=0;
                rowidx=zeros(1,numVarNames);
                for ii=1:2:numel(varargin)
                    for jj=1:numVarNames
                        if isequal(lower(varargin{ii}),lower(obj.VariableNames{jj}))
                            namecntr=namecntr+1;
                            rowidx(namecntr)=jj;
                        end
                    end
                end

                if any(rowidx==0)
                    error(message('rf:rffile:shared:sandp2d:independentvariables:InvalidNVInput'))
                end


                valcntr=0;
                idxInMat=cell(1,numVarNames);
                for ii=2:2:numel(varargin)
                    ridx=ii/2;
                    for jj=1:numel(obj.VariableValues{rowidx(ridx)})
                        if isequal(varargin{ii},obj.VariableValues{rowidx(ridx)}(jj))
                            valcntr=valcntr+1;
                            idxInMat{rowidx(ridx)}=jj;
                        end
                    end
                end

                if~all(isequal(namecntr,valcntr))
                    error(message('rf:rffile:shared:sandp2d:independentvariables:InvalidNVInput'))
                end

                reqsize=size(zeros(cellfun(@numel,obj.VariableValues).'));
                FLidxInMat=fliplr(idxInMat);








                out=sub2ind(fliplr(reqsize),FLidxInMat{:});
            end
        end
    end
end