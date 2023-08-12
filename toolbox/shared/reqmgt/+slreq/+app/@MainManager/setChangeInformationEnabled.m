function setChangeInformationEnabled( this, toEnable, cViews )
R36
this
toEnable
cViews = this.getAllViewers;
end 

for i = 1:numel( cViews )
cViews{ i }.displayChangeInformation = toEnable;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7sUyr4.p.
% Please follow local copyright laws when handling this file.

