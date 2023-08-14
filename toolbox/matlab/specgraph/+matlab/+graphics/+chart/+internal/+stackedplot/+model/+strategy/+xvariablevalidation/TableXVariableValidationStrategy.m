classdef TableXVariableValidationStrategy<matlab.graphics.chart.internal.stackedplot.model.strategy.abstract.XVariableValidationStrategy




    methods
        function xVariable=validateXVariable(~,chartData,xVariable,chartClassName)
            if isempty(xVariable)
                return
            elseif isStringScalar(xVariable)&&xVariable==""
                xVariable='';
                return
            end




            t=chartData.SourceTable;
            if isnumeric(xVariable)
                [xVariable,ind]=validateNumericSubscript(t,xVariable,chartClassName);
            elseif ischar(xVariable)||isstring(xVariable)
                [xVariable,ind]=validateTextSubscript(t,xVariable);
            elseif islogical(xVariable)
                [xVariable,ind]=validateLogicalSubscript(t,xVariable,chartClassName);
            else
                error(message('MATLAB:stackedplot:XVariableInvalidType'));
            end


            if~canBeXVariable(t,ind)
                error(message('MATLAB:stackedplot:UnplottableXVariable'));
            end
        end
    end
end

function[xVariable,ind]=validateNumericSubscript(t,xVariable,chartClassName)

    classes="numeric";
    maxVarIndex=width(t);
    attributes={"scalar","integer","positive","<=",maxVarIndex};
    varName="XVariable";
    validateattributes(xVariable,classes,attributes,chartClassName,varName);
    ind=xVariable;
    xVariable=t.Properties.VariableNames{xVariable};
end

function[xVariable,ind]=validateTextSubscript(t,xVariable)

    if(ischar(xVariable)&&~isrow(xVariable))||(isstring(xVariable)&&~isscalar(xVariable))
        error(message('MATLAB:stackedplot:XVariableInvalidType'));
    end
    xVariable=char(xVariable);
    [lia,ind]=ismember(xVariable,t.Properties.VariableNames);
    if~lia
        error(message('MATLAB:stackedplot:InvalidXVariable'));
    end
end

function[xVariable,ind]=validateLogicalSubscript(t,xVariable,chartClassName)

    classes="logical";
    attributes="vector";
    varName="XVariable";
    validateattributes(xVariable,classes,attributes,chartClassName,varName);
    maxVarIndex=width(t);
    if length(xVariable)>maxVarIndex
        error(message('MATLAB:stackedplot:LogicalArraySize','XVariable',maxVarIndex));
    end

    if sum(xVariable)~=1
        error(message('MATLAB:stackedplot:InvalidLogicalXVariable'));
    end
    ind=find(xVariable);
    xVariable=t.Properties.VariableNames{xVariable};
end

function tf=canBeXVariable(t,ind)

    xvar=t.(ind);
    tf=(isnumeric(xvar)||isdatetime(xvar)||isduration(xvar)||islogical(xvar))&&iscolumn(xvar);
end
