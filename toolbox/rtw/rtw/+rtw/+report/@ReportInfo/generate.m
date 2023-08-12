function generate( obj, varargin )




cpp_feval_wrapper( 'locGenerate', obj, varargin{ : } );

end 

function locGenerate( obj, varargin )%#ok<DEFNU>

obj.checkoutLicense(  );


if exist( obj.CodeGenFolder, 'dir' )
obj.Summary.CodeGenFolder = obj.CodeGenFolder;
else 
obj.Summary.CodeGenFolder = obj.StartDir;
end 
reports = { 'CodeInterface', 'CoderAssumptions' };
for i = 1:length( reports )
rpt = obj.getPage( reports{ i } );
if ~isempty( rpt )
rpt.BuildDir = obj.BuildDirectory;
end 
end 

obj.emitHTML( varargin{ : } );




bInfoMatFileName = fullfile( obj.BuildDirectory, 'buildInfo.mat' );
if obj.Dirty && isfile( bInfoMatFileName )
obj.saveMat;
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpSr_fvr.p.
% Please follow local copyright laws when handling this file.

