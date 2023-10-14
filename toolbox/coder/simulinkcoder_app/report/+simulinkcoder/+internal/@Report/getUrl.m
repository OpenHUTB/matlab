function url = getUrl( obj, top, mdl, cid )

arguments
    obj
    top char
    mdl char = ''
    cid char = ''
end

path = '/toolbox/coder/simulinkcoder_app/report/web/';

if obj.debugMode
    url = connector.getUrl( [ path, 'index-debug.html' ] );
else
    url = connector.getUrl( [ path, 'index.html' ] );
end

if isempty( top )
    src = simulinkcoder.internal.util.getSource(  );
    top = src.modelName;
end

url = [ url, '&top=', top ];
if ~isempty( mdl )
    url = [ url, '&model=', mdl ];
end
if ~isempty( cid )
    url = [ url, '&cid=', cid ];
end


features = obj.features;
url = [ url, '&features=', jsonencode( features ) ];


