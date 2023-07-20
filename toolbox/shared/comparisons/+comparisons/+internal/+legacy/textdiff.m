function html=textdiff(varargin)





    import comparisons.internal.html.removeCEFFormatting;

    result=comparisons_private('textdiff',varargin{:});
    html=removeCEFFormatting(result);
end