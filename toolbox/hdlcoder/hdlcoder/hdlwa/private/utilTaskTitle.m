function title = utilTaskTitle( titleStr, taskLvlOne, taskLvlTwo, taskLvlThree )




if nargin < 3
title = sprintf( '%d. %s', taskLvlOne, titleStr );
elseif nargin < 4
title = sprintf( '%d.%d. %s', taskLvlOne, taskLvlTwo, titleStr );
else 
title = sprintf( '%d.%d.%d. %s', taskLvlOne, taskLvlTwo, taskLvlThree, titleStr );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpizRanp.p.
% Please follow local copyright laws when handling this file.

