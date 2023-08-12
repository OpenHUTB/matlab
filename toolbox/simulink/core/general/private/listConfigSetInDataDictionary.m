function csnames = listConfigSetInDataDictionary( toInsert )



csnames = [  ];
dd = Simulink.dd.current;

if ~dd.isOpen
return ;
end 

list = dd.evalin( 'whos', 'Configurations' );

if nargin == 0
toInsert = false;
end 

if toInsert
csnames = { '' };
end 

for i = 1:length( list )
if strcmp( list( i ).class, 'Simulink.ConfigSet' )
csnames{ end  + 1 } = list( i ).name;%#ok
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHq2T90.p.
% Please follow local copyright laws when handling this file.

