function[left,right]=linediff(varargin)





    import comparisons.internal.html.removeCEFFormatting;

    out=comparisons_private('linediff',varargin{:});
    left=removeCEFFormatting(out{1});
    right=removeCEFFormatting(out{2});
end