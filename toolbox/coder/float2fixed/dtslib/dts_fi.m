%#codegen


function fival=dts_fi(varargin)
    coder.internal.prefer_const(varargin);
    coder.inline('always');
    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;

    if numel(varargin)>1
        args=cell(1,numel(varargin));
        args{1}=varargin{1};
        for ii=coder.unroll(2:numel(varargin))
            opt=varargin{ii-1};
            if coder.internal.isConst(isOptionRequiringDouble(opt))&&...
                coder.const(isOptionRequiringDouble(opt))&&...
                isnumeric(varargin{ii})
                args{ii}=double(varargin{ii});
            else
                args{ii}=varargin{ii};
            end
        end
        fival=dts_fi_impl(args{:});
    else
        fival=fi(varargin{:});
    end
end

function fival=dts_fi_impl(varargin)
    coder.internal.prefer_const(varargin);
    coder.inline('always');

    if nargin==1
        inval=varargin{1};
        if isa(inval,'single')



            fival1=fi(inval,'DataType','Fixed');
        else
            fival1=fi(varargin{:});
        end
    else
        fival1=fi(varargin{:});
    end

    if isdouble(fival1)

        fival=fi(fival1,'DataTypeOverride','Off','DataType','Single');
    else
        fival=fival1;
    end

    if isscaleddouble(fival)
        coder.internal.compileWarning('Coder:FXPCONV:DTS_ScaledDoubles');
    elseif isdouble(fival)
        coder.internal.compileWarning('Coder:FXPCONV:DTS_DoubleFi');
    end
end

function r=isOptionRequiringDouble(opt)
    coder.inline('always');
    coder.internal.prefer_const(opt);
    if ischar(opt)
        switch opt
        case{...
            'ProductBias',...
            'ProductFixedExponent',...
            'ProductFractionLength',...
            'ProductSlope',...
            'ProductSlopeAdjustmentFactor',...
            'ProductWordLength',...
            'SumBias',...
            'SumFixedExponent',...
            'SumFractionLength',...
            'SumSlope',...
            'SumSlopeAdjustmentFactor',...
            'SumWordLength',...
            }

            r=true;
        otherwise
            r=false;
        end
    else
        r=false;
    end
end


