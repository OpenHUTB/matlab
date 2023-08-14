function result=openImpl(reporter,impl,varargin)




    if isempty(varargin)
        key=['y9JEeAHbI+AVQIqPi59EXm24/+HMm0Zr+mEKX65icQiUPp0vlrBNthH6yAiL'...
        ,'cUy7ZfyNwB2uso8Gs0UXGjAaHLpK8IyjhuN8fNQVrmqcdMkRIWHCBvmPoJ9e'...
        ,'NYQiDovpFpvjPmn0+jB9qBM1XqTfQ92ZBHyweqGaEpr2Htp6R1e2RLVpbVnS'...
        ,'QNC49HlpvMVEWie2n/W/nXsB57U0u8mg4rTpLtZqGA=='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end
