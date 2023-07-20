function att=v1convert_att(h,att,varargin)




    if isfield(att,'isShowVariableValue')

        att.isVariableTable=logical(1);
        att.isFunctionTable=logical(0);
        att.VariableTableTitle=att.TableTitle;
        att.VariableTableTitleType='manual';
    else

        att.isVariableTable=logical(0);
        att.isFunctionTable=logical(1);
        att.FunctionTableTitle=att.TableTitle;
        att.FunctionTableTitleType='manual';
    end

    att=rmfield(att,'TableTitle');