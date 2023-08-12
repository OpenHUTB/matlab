function out = DisplayInCodeTrace( varargin )
persistent featureOn
if isempty( featureOn )
featureOn = true;
end 
if nargin == 1 && islogical( varargin{ 1 } )
featureOn = varargin{ 1 };
end 
out = featureOn;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOqZu60.p.
% Please follow local copyright laws when handling this file.

