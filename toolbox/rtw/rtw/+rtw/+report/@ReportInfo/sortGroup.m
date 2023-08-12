function [ extLists, sortedFileInfoList ] = sortGroup( obj, stat_fullNameList, categories, dirFiles )



buildDir = obj.BuildDirectory;

numTypes = length( categories );
extLists = cell( numTypes, 1 );
extLists_nopath = cell( numTypes, 1 );
htmlfiles = cell( numTypes, 1 );

for i = 1:numTypes
cat_num_id = [ categories{ i }, '_cat_num' ];
eval( [ cat_num_id, '=', num2str( i ), ';' ] );
end 

fileInfo = obj.getFileInfo;
fileNameList = cell( 1, length( fileInfo ) );



for i = 1:length( fileInfo )
file = fileInfo( i );
grp = file.Group;
fname = file.FileName;
path = file.Path;
fullname = fullfile( path, fname );
fileNameList{ i } = fname;
switch lower( grp )
case 'main'
extLists{ Main_cat_num } = [ extLists{ Main_cat_num }, { fullname } ];
case 'model'
extLists{ Model_cat_num } = [ extLists{ Model_cat_num }, { fullname } ];
case 'subsystem'
extLists{ Subsystem_cat_num } = [ extLists{ Subsystem_cat_num }, { fullname } ];
case 'data'
extLists{ Data_cat_num } = [ extLists{ Data_cat_num }, { fullname } ];
case 'utility'
extLists{ Utility_cat_num } = [ extLists{ Utility_cat_num }, { fullname } ];
case 'sharedutility'
extLists{ Shared_cat_num } = [ extLists{ Shared_cat_num }, { fullname } ];
case 'sharedlibraryutility'
extLists{ Reused_cat_num } = [ extLists{ Reused_cat_num }, { fullname } ];
case 'interface'
extLists{ Interface_cat_num } = [ extLists{ Interface_cat_num }, { fullname } ];
case lower( autosarcore.getRTEFilesReportGroupName )
extLists{ RTE_cat_num } = [ extLists{ RTE_cat_num }, { fullname } ];



case lower( autosarcore.getARAFilesReportGroupName )
extLists{ ARA_cat_num } = [ extLists{ ARA_cat_num }, { fullname } ];
case lower( rtw.pil.getSILPILFilesReportGroupName )
extLists{ SILPIL_cat_num } = [ extLists{ SILPIL_cat_num }, { fullname } ];
otherwise 
extLists{ Other_cat_num } = [ extLists{ Other_cat_num }, { fullname } ];
end 
end 
sharedList = extLists{ Shared_cat_num };
if ~isempty( sharedList )
genUtilsDir = fileparts( sharedList{ 1 } );
sharedUtilsHtmlDir = fullfile( genUtilsDir, 'html' );
end 




stat_fileNameList = cell( 1, length( stat_fullNameList ) );
for i = 1:length( stat_fullNameList )
[ ~, fname, fext ] = fileparts( stat_fullNameList{ i } );
stat_fileNameList{ i } = [ fname, fext ];
end 


[ ~, tmpIdx ] = setdiff( stat_fileNameList, fileNameList );
if ~isempty( tmpIdx )

fileNameList = [ fileNameList, stat_fileNameList( tmpIdx ) ];
extLists{ Static_cat_num } = stat_fullNameList( tmpIdx );
end 








dirFileNameList = {  };
pathList = {  };
for i = 1:length( dirFiles )
[ path, fname, fext ] = fileparts( dirFiles{ i } );
if obj.AddSource || ~( strcmp( fext, '.c' ) || strcmp( fext, '.cpp' ) )
dirFileNameList{ end  + 1 } = [ fname, fext ];
pathList{ end  + 1 } = path;
end 
end 


[ ~, tmpIdx ] = setdiff( dirFileNameList, fileNameList );
if ~isempty( tmpIdx )
fileNameAndPath = fullfile( pathList, dirFileNameList );

fileNameList = [ fileNameList, dirFileNameList( tmpIdx ) ];%#ok<NASGU>

extLists{ Other_cat_num } = [ extLists{ Other_cat_num }, fileNameAndPath( tmpIdx ) ];
for i = 1:length( tmpIdx )
filename = fileNameAndPath{ tmpIdx( i ) };
[ fpath, fname, fext ] = fileparts( filename );
if strcmpi( fext, '.h' )
ftype = 'header';
else 
ftype = 'source';
end 
aFileInfo = rtw.report.ReportInfo.newFileInfo( [ fname, fext ], 'other', ftype, fpath );
aFileInfo = obj.tokenPath( aFileInfo );
obj.FileInfo( end  + 1 ) = aFileInfo;
end 
end 


sortedFileInfoList.FileName = {  };
sortedFileInfoList.HtmlFileName = {  };
sortedFileInfoList.GroupNum = {  };
sortedFileInfoList.SourceFileIndex = [  ];
sortedFileInfoList.HeaderFileIndex = [  ];
sortedFileInfoList.OtherFileIndex = [  ];
for extNum = 1:numTypes


srcFileIdx = [  ];
hdrFileIdx = [  ];
otherFileIdx = [  ];
for i = 1:length( extLists{ extNum } )
file = extLists{ extNum }{ i };
[ ~, fname, ext ] = fileparts( file );
filename = [ fname, ext ];
extLists_nopath{ extNum } = [ extLists_nopath{ extNum }, { filename } ];


if extNum == Shared_cat_num
htmlfiles{ extNum } = [ htmlfiles{ extNum }, { fullfile( sharedUtilsHtmlDir, obj.getHTMLFileName( filename ) ) } ];
else 
htmlfiles{ extNum } = [ htmlfiles{ extNum }, { fullfile( buildDir, 'html', obj.getHTMLFileName( filename ) ) } ];
end 
end 

[ ~, idx ] = sort( extLists_nopath{ extNum } );

extLists{ extNum } = extLists{ extNum }( idx );
htmlfiles{ extNum } = htmlfiles{ extNum }( idx );
for i = 1:length( extLists{ extNum } )
file = extLists{ extNum }{ i };
[ ~, fname, ext ] = fileparts( file );
filename = [ fname, ext ];%#ok<NASGU>
if strcmpi( ext, '.c' ) || strcmpi( ext, '.cpp' )
srcFileIdx = [ srcFileIdx, i ];
elseif strcmpi( ext, '.h' ) || strcmpi( ext, '.hpp' )
hdrFileIdx = [ hdrFileIdx, i ];
else 
otherFileIdx = [ otherFileIdx, i ];
end 
end 

n = length( sortedFileInfoList.FileName );
sortedFileInfoList.SourceFileIndex = [ sortedFileInfoList.SourceFileIndex, srcFileIdx + n ];
sortedFileInfoList.HeaderFileIndex = [ sortedFileInfoList.HeaderFileIndex, hdrFileIdx + n ];
sortedFileInfoList.OtherFileIndex = [ sortedFileInfoList.OtherFileIndex, otherFileIdx + n ];
sortedFileInfoList.FileName = [ sortedFileInfoList.FileName, extLists{ extNum } ];
sortedFileInfoList.HtmlFileName = [ sortedFileInfoList.HtmlFileName, htmlfiles{ extNum } ];
grp = zeros( size( extLists{ extNum } ) );
grp( 1, 1:length( grp ) ) = extNum;
sortedFileInfoList.GroupNum = [ sortedFileInfoList.GroupNum, grp ];
end 
sortedFileInfoList.NumFiles = length( sortedFileInfoList.FileName );
sortedFileInfoList.NumUtils = length( extLists{ Utility_cat_num } ) + length( extLists{ Shared_cat_num } );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpz5e4dX.p.
% Please follow local copyright laws when handling this file.

