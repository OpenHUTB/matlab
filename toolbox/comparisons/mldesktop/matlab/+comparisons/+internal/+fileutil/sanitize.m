function sanitizedSource = sanitize( source, opts )
    arguments
        source( 1, 1 )comparisons.internal.FileSource
        opts.TargetExt{ mustBeText } = string.empty(  )
        opts.NeedsValidName logical{ mustBeNumericOrLogical } = false
    end
    
    sanitizedSource = comparisons.internal.fileutil.sanitizeImpl(  ...
        source, opts.TargetExt, opts.NeedsValidName);
end



