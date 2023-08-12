function sanitizedSource = sanitize( source, opts )














R36
source( 1, 1 )comparisons.internal.FileSource
opts.TargetExt{ mustBeText } = string.empty(  )
opts.NeedsValidName logical{ mustBeNumericOrLogical } = false
end 

sanitizedSource = comparisons.internal.fileutil.sanitizeImpl(  ...
source, opts.TargetExt, opts.NeedsValidName );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpG9bgK7.p.
% Please follow local copyright laws when handling this file.

