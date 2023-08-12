classdef PlotCache < handle






properties 
UIAxes
end 

properties ( Access = private )
LinesCaches = simulink.compiler.internal.LinesCache.empty(  );
end 

methods 
function obj = PlotCache( uiAxes )
R36
uiAxes( 1, 1 )matlab.ui.control.UIAxes
end 

obj.UIAxes = uiAxes;
end 

function linesCache = getLinesCacheForComponent( obj, component )
linesCache = [  ];

for cache = obj.LinesCaches
if isequal( cache.Component, component )
linesCache = cache;
return 
end 
end 
end 

function addLinesCache( obj, linesCache )
if obj.cacheExists( linesCache )
return 
end 
obj.LinesCaches( end  + 1 ) = linesCache;
end 

function clearAllLinesCaches( obj )
for idx = 1:numel( obj.LinesCaches )
obj.LinesCaches( idx ).clearAllLines(  );
end 
end 

function linesCaches = getAllLinesCaches( obj )
linesCaches = obj.LinesCaches;
end 
end 

methods ( Access = private )
function exists = cacheExists( obj, linesCacheToCheck )
exists = false;
for linesCache = obj.LinesCaches
if isequal( linesCache.Component, linesCacheToCheck.Component )
exists = true;
return 
end 
end 
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpqY730D.p.
% Please follow local copyright laws when handling this file.

