classdef MultiTableXVariableValidationStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XVariableValidationStrategy




    methods
        function xVariable=validateXVariable(~,chartData,xVariable,~)
            if isempty(xVariable)
                return
            elseif isStringScalar(xVariable)&&xVariable==""
                xVariable='';
                return
            end



            if ischar(xVariable)||isstring(xVariable)||iscellstr(xVariable)
                [xVariable,ind]=validateTextSubscript(chartData.SourceTable,xVariable);
            else
                error(message('MATLAB:stackedplot:XVariableInvalidTypeMultiTable'));
            end


            if~canBeXVariable(chartData.SourceTable,ind)
                error(message('MATLAB:stackedplot:UnplottableXVariable'));
            end
            if~allXVariablesSameType(chartData.SourceTable,ind)
                error(message('MATLAB:stackedplot:XVariableIncompatibleTypes'));
            end
        end
    end
end

function[xVariable,ind]=validateTextSubscript(tbls,xVariable)

    if~(ischar(xVariable)&&isrow(xVariable)||isstring(xVariable)||iscellstr(xVariable)&&all(cellfun(@isrow,xVariable)))
        error(message('MATLAB:stackedplot:XVariableInvalidTypeMultiTable'));
    end
    isScalarXVariable=true;
    if~ischar(xVariable)
        if isscalar(xVariable)
            xVariable=char(xVariable);
        else
            xVariable=cellstr(xVariable);
            isScalarXVariable=false;
        end
    end
    ind=zeros(1,length(tbls));
    if isScalarXVariable
        for i=1:length(tbls)
            [lia,ind(i)]=ismember(xVariable,tbls{i}.Properties.VariableNames);
            if~lia
                error(message('MATLAB:stackedplot:InvalidXVariableMultiTable',xVariable,i));
            end
        end
    else
        validateattributes(xVariable,["string","cell"],"vector",'',"XVariable");
        xVariable=reshape(xVariable,1,[]);
        if length(tbls)~=length(xVariable)
            error(message('MATLAB:stackedplot:InvalidXVariableLengthMultiTable',length(xVariable),length(tbls)));
        end
        for i=1:length(tbls)
            [lia,ind(i)]=ismember(xVariable{i},tbls{i}.Properties.VariableNames);
            if~lia
                error(message('MATLAB:stackedplot:InvalidXVariableMultiTable',xVariable{i},i));
            end
        end
        uniqueXVariable=unique(xVariable);
        if isscalar(uniqueXVariable)
            xVariable=uniqueXVariable;
        end
        if~ischar(xVariable)&&isscalar(xVariable)
            xVariable=char(xVariable);
        end
    end
end

function tf=canBeXVariable(tbls,ind)

    tf=true;
    for i=1:length(tbls)
        xvar=tbls{i}.(ind(i));
        tf=(isnumeric(xvar)||isdatetime(xvar)||isduration(xvar)||islogical(xvar))&&iscolumn(xvar);
        if~tf
            return
        end
    end
end

function tf=allXVariablesSameType(tbls,ind)

    tf=true;
    if isempty(tbls)
        return
    end
    xvar=tbls{1}.(ind(1));
    x1numeric=isnumeric(xvar);
    typeT1=class(xvar);
    for i=2:length(tbls)
        xvar=tbls{i}.(ind(i));
        tf=(x1numeric&&isnumeric(xvar))||isequal(typeT1,class(xvar));
        if~tf
            return
        end
    end
end
