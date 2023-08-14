function res=getText(this)





    try
        res={};
        for idx=1:numel(this.m_handlesForReport)
            cp=this.m_handlesForReport{idx};
            formatter='';
            switch lower(class(cp))
            case 'sldv.point'
                formatter='MSG_SL_TESTPOINT';
            case 'sldv.interval'
                formatter='MSG_SL_TESTINTERVAL';
            end
            res{end+1}={util_mxarray_print(cp),formatter};%#ok<AGROW>
        end
    catch Mex
        Mex.message;
    end
end

function str=util_mxarray_print(in)






    if iscell(in)&&(length(in)==1)
        in=in{1};
    end

    if iscell(in)
        str='{ ';
        for i=1:length(in)
            str_item=print_item(in{i});
            str=[str,str_item,' '];%#ok<AGROW>
        end
        str=[str,'}'];
    else
        str=print_item(in);
    end
end

function str=print_item(in)
    if isempty(in)
        str='[]';
    elseif isa(in,'Sldv.Point')
        if isscalar(in.value)
            str=sldvshareprivate('util_num2str',in.value);
        else
            str=['Point(',sldvshareprivate('util_matrix2str',in.value),')'];
        end
    elseif isa(in,'Sldv.Interval')
        if in.lowIncluded
            lowB='[';
        else
            lowB='(';
        end
        if in.highIncluded
            highB=']';
        else
            highB=')';
        end
        if isscalar(in.low)
            strLow=sldvshareprivate('util_num2str',in.low);
            strHigh=sldvshareprivate('util_num2str',in.high);
            str=[lowB,strLow,', ',strHigh,highB];
        else
            strLow=sldvshareprivate('util_matrix2str',in.low);
            strHigh=sldvshareprivate('util_matrix2str',in.high);
            if in.lowIncluded&&in.highIncluded
                strB='';
            else
                strB=[', ''',lowB,highB,''''];
            end
            str=['Interval(',strLow,', ',strHigh,strB,')'];
        end
    else
        error(message('Sldv:UtilPrint:BadValue'));
    end
end

