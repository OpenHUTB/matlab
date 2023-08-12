function [ ph, pb ] = gcop( sys )



















cs = [  ];
ph = [  ];
pb = [  ];
if nargin < 1, 



cs = gcs;
if ~isempty( cs ), 
ph = get_param( cs, 'CurrentOutputPort' );
end 
else 
cs = sys;
ph = get_param( cs, 'CurrentOutputPort' );
end 

pb = get_param( ph, 'parent' );
pb = get_param( pb, 'handle' );



% Decoded using De-pcode utility v1.2 from file /tmp/tmp57cLTQ.p.
% Please follow local copyright laws when handling this file.

