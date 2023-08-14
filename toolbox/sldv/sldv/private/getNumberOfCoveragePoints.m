function out=getNumberOfCoveragePoints(blockH)



    out=-1;
    try
        blockType=get_param(blockH,'BlockType');
        switch blockType
        case 'Switch'
            out=1;
        case 'MinMax'
            out=1;
        case 'Logic'
            out=1;
        case 'Saturate'
            out=2;
        case 'RelationalOperator'
            out=1;
        case 'MultiPortSwitch'
            out=1;
        case 'Abs'
            out=1;
        case 'DeadZone'
            out=2;
        case 'Relay'
            out=2;
        case 'RateLimiter'
            out=2;
        end
    catch Mex %#ok<NASGU>

    end
end
