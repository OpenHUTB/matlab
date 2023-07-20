function[algLoops,hUI]=getAlgebraicLoops(mdlH)



















    switch nargout
    case{0,1}
        algLoops=slprivate('getBDAlgebraicLoopsImpl',mdlH);
    case 2
        [algLoops,hUI]=slprivate('getBDAlgebraicLoopsImpl',mdlH);
    end

end

