function varargout = slmessages( in )
















featureNames = {  };


switch slfeature( 'MessageLogging' )
case 0
prev = 0;
otherwise 
prev = 1;
end 


if nargin < 1
varargout{ 1 } = prev;
return ;
end 

switch in
case { 'on', 1, '1' }


for idx = 1:length( featureNames )
slfeature( featureNames{ idx }, 1 );
end 


case { 'off', 0, '0' }


bdclose( 'messageslib' );


for idx = 1:length( featureNames )
slfeature( featureNames{ idx }, 0 );
end 

otherwise 
error( 'Invalid input argument' );
end 


if nargout == 1
varargout{ 1 } = prev;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpqa0WmC.p.
% Please follow local copyright laws when handling this file.

