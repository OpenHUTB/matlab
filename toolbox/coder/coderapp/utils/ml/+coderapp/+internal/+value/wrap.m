function[wrapper,mfzModel]=wrap(mfzModel,value,displayStr,isHtml)



    narginchk(2,4);
    if isempty(mfzModel)
        mfzModel=mf.zero.Model();
    elseif~isa(mfzModel,'mf.zero.Model')
        error('mfzModel must be a mf.zero.Model instance');
    end

    if~iscell(value)&&~isscalar(value)&&~coder.internal.isScalarText(value)
        value=num2cell(value);
    end
    if iscell(value)
        if nargin>2
            if isempty(displayStr)
                displayStr=repmat({''},size(value));
            elseif isscalar(displayStr)
                displayStr=repmat(cellstr(displayStr),size(value));
            elseif~iscellstr(displayStr)||numel(displayStr)~=numel(value)%#ok<ISCLSTR>
                error('For non-scalars or cells, displayStr must be scalar text or a cellstr matching in length');
            end
        end
        if nargin>3
            if isempty(isHtml)
                isHtml=false(size(value));
            elseif islogical(isHtml)&&(isscalar(isHtml)||numel(isHtml)==numel(value))
                if isscalar(isHtml)
                    isHtml=repmat(isHtml,size(value));
                end
            else
                error('For non-scalars or cells, isHtml must be a scalar logical or a vector matching in length');
            end
        end
        wrapper=coderapp.internal.value.ArrayValue();
        for i=1:numel(value)
            wrapper.Value.add(doWrap(mfzModel,value{i},displayStr{i},isHtml(i)));
        end
    else
        isHtml=nargin>2&&~isempty(isHtml)&&isHtml;
        if nargin<2||isempty(displayStr)
            displayStr={''};
        else
            displayStr=cellstr(displayStr);
        end
        wrapper=doWrap(mfzModel,value,displayStr{1},isHtml(1));
    end
end


function wrapper=doWrap(mfzModel,value,displayStr,isHtml)
    if ischar(value)||isstring(value)
        wrapper=coderapp.internal.value.StringValue(mfzModel);
    elseif islogical(value)
        wrapper=coderapp.internal.value.BooleanValue(mfzModel);
    elseif isnumeric(value)&&isreal(value)&&~issparse(value)&&~isa(value,'gpuArray')
        if isinteger(value)
            wrapper=coderapp.internal.value.IntValue(mfzModel);
        else
            wrapper=coderapp.internal.value.DoubleValue(mfzModel);
        end
    else
        wrapper=coderapp.internval.value.MxArrayValue(mfzModel);
    end
    wrapper.Value=value;
    wrapper.DisplayValue=displayStr;
    wrapper.IsHtml=isHtml;
end