function oVal = mfeatures( action, featureName, varargin )











mlock
persistent featureBank;
if isempty( featureBank )
featureBank.TestCheckSimPrm = 0;
end 

if strcmp( action, 'Set' )
eval( [ 'featureBank.', featureName, '= varargin{1};' ] );
end 

oVal = eval( [ 'featureBank.', featureName ] );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqH1rU6.p.
% Please follow local copyright laws when handling this file.

