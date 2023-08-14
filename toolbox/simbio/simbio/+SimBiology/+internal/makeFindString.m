function s=makeFindString(opts,varargin)





































    s={};
    argidx=1;
    nqueryargs=numel(varargin);

    while argidx<=nqueryargs
        arg=varargin{argidx};
        if~ischar(arg)
            error(message('SimBiology:PrivateMakeFindString:NONCHAR_PROP'));
        end
        switch lower(arg)
        case 'and'
            localBinaryBoolIsValid(s,argidx,nqueryargs,varargin);
            s{end+1,1}='-and';%#ok<AGROW>
            argidx=argidx+1;
        case 'or'
            localBinaryBoolIsValid(s,argidx,nqueryargs,varargin);
            s{end+1,1}='-or';%#ok<AGROW>
            argidx=argidx+1;
        case 'xor'
            localBinaryBoolIsValid(s,argidx,nqueryargs,varargin);
            s{end+1,1}='-xor';%#ok<AGROW>
            argidx=argidx+1;
        case 'not'
            if(argidx+1>nqueryargs)
                error(message('SimBiology:PrivateMakeFindString:MISSING_BOOLEAN_OPERAND'));
            end
            s{end+1,1}='-not';%#ok<AGROW>
            argidx=argidx+1;
        case 'depth'
            if nqueryargs-argidx<1
                error(message('SimBiology:PrivateMakeFindString:MISSING_DEPTH'));
            end
            searchdepth=varargin{argidx+1};
            if~(isnumeric(searchdepth)&&searchdepth>=0&&...
                (isinf(searchdepth)||fix(searchdepth)==searchdepth))
                error(message('SimBiology:PrivateMakeFindString:BAD_DEPTH'));
            end
            s{end+1,1}='-depth';%#ok<AGROW>
            s{end+1,1}=searchdepth;%#ok<AGROW>
            argidx=argidx+2;

        case 'where'
            if nqueryargs-argidx<3
                error(message('SimBiology:PrivateMakeFindString:BAD_WHERE_CLAUSE'));
            end
            propertyNameOrCondition=varargin{argidx+1};
            if localIsValidPropertyNameCondition(propertyNameOrCondition)


                if nqueryargs-argidx<4
                    error(message('SimBiology:PrivateMakeFindString:BAD_WHERE_CLAUSE'));
                end
                s=localParsePropertyNameCondition(s,varargin{argidx+1:argidx+4});
                argidx=argidx+5;
            elseif localIsWildcard(propertyNameOrCondition)

                s=localParsePropertyNameCondition(s,'wildcard',varargin{argidx+1:argidx+3});
                argidx=argidx+4;
            else

                s=localParseValueCondition(s,varargin{argidx+1:argidx+3});
                argidx=argidx+4;
            end
        otherwise

            if nqueryargs-argidx<1
                error(message('SimBiology:PrivateMakeFindString:MISSING_VAL'));
            end
            val=varargin{argidx+1};
            if localIsWildcard(arg)

                s=localParsePropertyNameCondition(s,'wildcard',arg,'==',val);
                argidx=argidx+2;
                continue
            end
            s=localAddAndIfNeeded(s);
            if strcmpi(arg,'Type')

                val=lower(val);
            end
            if iscell(val)
                s{end+1,1}=localHandleCellArrayExpansion(arg,val,opts.expandCAVals);%#ok<AGROW>
            else
                s{end+1,1}={arg,val};%#ok<AGROW>
            end
            argidx=argidx+2;
        end
    end
end





function names=localGetAllPropertyNames

    pkg=meta.package.fromName('SimBiology');

    propertyList=vertcat(pkg.ClassList.PropertyList);

    visibleProperties=propertyList(~[propertyList.Hidden]);

    names=unique({visibleProperties.Name});
end









function s=localParsePropertyNameCondition(s,propCond,prop,valueCond,val)

    propFcn=localMakeFunction(propCond,prop);
    allProps=localGetAllPropertyNames;
    selectedIndex=arrayfun(propFcn,allProps);
    selectedProps=allProps(selectedIndex);

    if isempty(selectedProps)
        s=[localAddAndIfNeeded(s);{{'-function','',@(x)false}}];
        return
    end

    subclause=localParseValueCondition({},selectedProps{1},valueCond,val);
    for i=2:numel(selectedProps)
        subclause{end+1,1}='-or';%#ok<AGROW>
        subclause=localParseValueCondition(subclause,selectedProps{i},valueCond,val);
    end
    s=[localAddAndIfNeeded(s);{subclause}];
end








function s=localParseValueCondition(s,prop,cond,val)
    s=localAddAndIfNeeded(s);
    if~ischar(prop)||~ischar(cond)
        error(message('SimBiology:PrivateMakeFindString:BAD_WHERE_CLAUSE'));
    end
    if strcmpi(prop,'Type')&&strcmp(cond,'==')
        cond='==i';
    end
    s{end+1,1}={'-function',prop,localMakeFunction(cond,val)};
end









function s=localHandleCellArrayExpansion(prop,val,expandCellstr)


    if isempty(val)
        s={'-function','',@(x)false};
        return
    end


    if iscellstr(val)&&~expandCellstr %#ok<ISCLSTR>
        if isscalar(val)


            s={prop,val{1}};
        else


            s={'-function',prop,@(x)localComparePropertyToCellstr(x,val)};
        end
        return
    end

    s=cell(2*numel(val)-1,1);
    s{1}={prop,val{1}};
    for c=2:numel(val)
        s{2*c-2,1}='-or';
        s{2*c-1,1}={prop,val{c}};
    end
end




function s=localAddAndIfNeeded(s)
    operator_list={'-and','-or','-xor','-not'};
    if isempty(s)
        return
    elseif ischar(s{end})&&any(strcmp(s{end},operator_list))
        return
    else
        s{end+1,1}='-and';
    end
end







function tf=localIsValidPropertyNameCondition(arg)
    if~ischar(arg)
        error(message('SimBiology:PrivateMakeFindString:BAD_WHERE_CLAUSE'));
    end
    if any(strcmp(arg,{'==','~=','==i','~=i',...
        'regexp','regexpi','~regexp','~regexpi',...
        'wildcard','wildcardi','~wildcard','~wildcardi'}))
        tf=true;
    else
        tf=false;
    end
end








function f=localMakeFunction(cond,val)


    fun_helper_1_arg=@(condfun,v)@(x)condfun(x,v);

    switch cond

    case '>',localChkNumScal(val,cond);f=fun_helper_1_arg(@gt,val);
    case '<',localChkNumScal(val,cond);f=fun_helper_1_arg(@lt,val);
    case '>=',localChkNumScal(val,cond);f=fun_helper_1_arg(@ge,val);
    case '<=',localChkNumScal(val,cond);f=fun_helper_1_arg(@le,val);
    case 'between',localChkNumTwoVec(val,cond);f=fun_helper_1_arg(@local_between,val);
    case '~between',localChkNumTwoVec(val,cond);f=fun_helper_1_arg(@local_nbetween,val);


    case 'wildcard'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        val=localConvertWildcardCondToRegexpCond(val);
        f=fun_helper_1_arg(@local_regexp,val);
    case 'wildcardi'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        val=localConvertWildcardCondToRegexpCond(val);
        f=fun_helper_1_arg(@local_regexpi,val);
    case '~wildcard'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        val=localConvertWildcardCondToRegexpCond(val);
        f=fun_helper_1_arg(@local_regexp_not,val);
    case '~wildcardi'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        val=localConvertWildcardCondToRegexpCond(val);
        f=fun_helper_1_arg(@local_regexpi_not,val);
    case 'regexp'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        f=fun_helper_1_arg(@local_regexp,val);
    case 'regexpi'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        f=fun_helper_1_arg(@local_regexpi,val);
    case '~regexp'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        f=fun_helper_1_arg(@local_regexp_not,val);
    case '~regexpi'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        f=fun_helper_1_arg(@local_regexpi_not,val);
    case '==i'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        f=fun_helper_1_arg(@local_strcmpi,val);
    case '~=i'
        val=localChkStrOrCellStrAndConv2ColCellStr(val,cond);
        f=fun_helper_1_arg(@local_nstrcmpi,val);


    case 'equal_and_same_type'
        f=@(v)isequal(v,val)&&isa(v,class(val));
    case 'unequal_and_same_type'
        f=@(v)~isequal(v,val)&&isa(v,class(val));
    case '=='
        if ischar(val)
            f=fun_helper_1_arg(@local_strcmp,val);
        elseif iscellstr(val)%#ok<ISCLSTR>
            f=fun_helper_1_arg(@local_strcmp,val(:));
        elseif isnumeric(val)||islogical(val)||isstruct(val)||isa(val,'SimBiology.Object')
            f=fun_helper_1_arg(@isequal,val);
        else
            error(message('SimBiology:PrivateMakeFindString:BAD_VALUE_TYPE',cond));
        end
    case '~='
        if ischar(val)
            f=fun_helper_1_arg(@local_nstrcmp,val);
        elseif iscellstr(val)%#ok<ISCLSTR>
            f=fun_helper_1_arg(@local_nstrcmp,val(:));
        elseif isnumeric(val)||islogical(val)||isstruct(val)||isa(val,'SimBiology.Object')
            f=fun_helper_1_arg(@(x,y)~isequal(x,y),val);
        else
            error(message('SimBiology:PrivateMakeFindString:BAD_VALUE_TYPE',cond));
        end
    case 'contains',localChkHandleVec(val,cond);f=fun_helper_1_arg(@local_contains,val);
    case 'function',localChkFnHan(val,cond);f=val;
    otherwise
        error(message('SimBiology:PrivateMakeFindString:BAD_CONDITION',cond));
    end
end


function localChkNumScal(v,c)
    if~(isnumeric(v)&&isscalar(v))
        error(message('SimBiology:PrivateMakeFindString:BAD_VALUE_TYPE_SCALAR',c));
    end
end

function localChkNumTwoVec(v,c)
    if~(isnumeric(v)&&isvector(v)&&length(v)==2)
        error(message('SimBiology:PrivateMakeFindString:BAD_VALUE_TYPE_LENGTH2',c));
    end
end

function v=localChkStrOrCellStrAndConv2ColCellStr(v,c)
    if ischar(v)
    elseif iscellstr(v)%#ok<ISCLSTR>
        v=v(:);
    else
        error(message('SimBiology:PrivateMakeFindString:BAD_VALUE_TYPE_CELLSTR',c));
    end
end

function localChkHandleVec(v,c)
    if~isa(v,'SimBiology.Object')
        error(message('SimBiology:PrivateMakeFindString:BAD_VALUE_TYPE_OBJECT_ARRAY',c));
    end
end

function localChkFnHan(v,c)
    if~isa(v,'function_handle')
        error(message('SimBiology:PrivateMakeFindString:BAD_VALUE_TYPE_FUNCTION_HANDLE',c));
    end
end




function ret=local_between(value,bounds)
    ret=(bounds(1)<=value)&&(bounds(2)>=value);
end

function ret=local_nbetween(value,bounds)
    ret=~local_between(value,bounds);
end



function ret=local_contains(list,objarray)
    ret=any(ismember(objarray,list));
end

function tf=localIsWildcard(string)
    tf=any(string=='*'|string=='?');
end


function val=localConvertWildcardCondToRegexpCond(val)

    val=regexptranslate('wildcard',val);

    val=strcat('^',val,'$');
end

function ret=local_regexp(str,expression)
    found=regexp(str,expression,'once');
    if iscell(found)
        ret=any(cellfun(@(x)~isempty(x),found));
    else
        ret=~isempty(found);
    end
end

function ret=local_regexpi(str,expression)
    found=regexpi(str,expression,'once');
    if iscell(found)
        ret=any(cellfun(@(x)~isempty(x),found));
    else
        ret=~isempty(found);
    end
end

function ret=local_regexp_not(str,expression)
    ret=~local_regexp(str,expression);
end

function ret=local_regexpi_not(str,expression)
    ret=~local_regexpi(str,expression);
end

function ret=local_strcmp(str,expr)
    ret=any(strcmp(str,expr));
end

function ret=local_strcmpi(str,expr)
    ret=any(strcmpi(str,expr));
end

function ret=local_nstrcmp(str,expr)
    ret=~any(strcmp(str,expr));
end

function ret=local_nstrcmpi(str,expr)
    ret=~any(strcmpi(str,expr));
end

function localBinaryBoolIsValid(s,argidx,nqueryargs,makeFindStringVarargin)
    binary_operators={'and','or','xor','not'};

    if(isempty(s)||(argidx+1>nqueryargs))...
        ||(ischar(makeFindStringVarargin{argidx-1})&&any(strcmpi(makeFindStringVarargin{argidx-1},binary_operators)))
        error(message('SimBiology:PrivateMakeFindString:MISSING_BOOLEAN_OPERAND2'));
    end
end

function ret=localComparePropertyToCellstr(propValue,vals)

    if ischar(propValue)
        ret=any(strcmp(propValue,vals));
    else
        ret=false;
    end
end