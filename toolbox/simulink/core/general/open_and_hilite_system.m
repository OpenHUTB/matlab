function open_and_hilite_system( sys, hilite, varargin )











































if ( ischar( sys ) )


parentSys = regexprep( sys, '/.*', '' );
open_system( parentSys );

end 

if ( nargin > 1 )
hilite_system( sys, hilite, varargin{ : } );
else 
hilite_system( sys );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpaQs7k_.p.
% Please follow local copyright laws when handling this file.

