function result = slxcinfo( varargin )









try 
[ varargin{ : } ] = convertStringsToChars( varargin{ : } );
p = inputParser(  );
p.addRequired( 'slxcFile', @Simulink.packagedmodel.validateSLXCFile );
p.parse( varargin{ : } );

slxcFile = Simulink.packagedmodel.getSLXCFileOnPath( p.Results.slxcFile );
inspectorType = Simulink.packagedmodel.inspect.ContentInspectorType.QUERY;
inspector = Simulink.packagedmodel.inspect.getInspector( inspectorType, slxcFile );
result = inspector.populate(  );
catch ME
throw( ME );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDddRvT.p.
% Please follow local copyright laws when handling this file.

