function rangeVector=getMinMax(tensor)



















    mustBeNumericOrLogical(tensor);
    rangeVector=[min(tensor(:)),max(tensor(:))];
end