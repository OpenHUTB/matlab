function out = hasToolbar( varargin )
persistent bHasToolbar
if isempty( bHasToolbar )
bHasToolbar = true;
end 
if nargin == 1 && islogical( varargin{ 1 } )
bHasToolbar = varargin{ 1 };
end 
out = bHasToolbar;

if Simulink.report.ReportInfo.featureReportV2
out = false;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFlyVXZ.p.
% Please follow local copyright laws when handling this file.

