function audioUpdateModel(h)
    if h.CheckFlags.BlockReplace
        ReplaceInfoNoCompile={...
        {'ReferenceBlock',sprintf('dspobslib/Parametric EQ Filter')},...
        'replaceParametricEQFilter';
        };

        ReplaceInfoNoCompile=...
        cell2struct(ReplaceInfoNoCompile,{'BlockDesc','ReplaceFcn'},2);
        replaceBlocks(h,ReplaceInfoNoCompile);
    end

