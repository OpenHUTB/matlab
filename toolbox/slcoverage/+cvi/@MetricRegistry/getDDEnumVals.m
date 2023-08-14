function res=getDDEnumVals
    persistent ddEnumVals;

    if isempty(ddEnumVals)
        [prop,names]=cv('subproperty','modelcov.metric_enum');
        [r,c]=size(names{1});%#ok
        args=cell(2*r,1);
        args(1:2:2*r,1)=names{1};
        args(2:2:2*r,1)=num2cell(0:r-1');%#ok
        ddEnumVals=struct(args{:});
    end
    res=ddEnumVals;