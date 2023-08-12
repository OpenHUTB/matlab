function res = getHeaderInterface( self, options )




















R36
self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
options.FilterUnneededHeaders( 1, 1 )logical = false
options.FilterSystemHeaders( 1, 1 )logical = true
options.FilterMWIncludes( 1, 1 )logical = true
options.KeepOnlySLCompliant( 1, 1 )logical = true
options.KeepAllTypes( 1, 1 )logical = true
options.KeepAllVariables( 1, 1 )logical = true
options.GenIncludeDirective( 1, 1 )logical = false
end 


if options.FilterUnneededHeaders == false
res = self.getHeaderList( 'FilterSystemHeaders', options.FilterSystemHeaders, 'FilterMWIncludes', options.FilterMWIncludes );
return ;
end 


[ originalHeaders, headerGraph ] = self.getHeaderList( 'FilterSystemHeaders', options.FilterSystemHeaders, 'FilterMWIncludes', options.FilterMWIncludes );


fInfoList = self.CodeInsightInfo.Functions.toArray;
if ~isempty( fInfoList )
fList = [ fInfoList.Function ];

fInfoList = fInfoList( [ fList.IsCompilerGenerated ] == false );
end 
if ~isempty( fInfoList )

fInfoList = fInfoList( [ fInfoList.IsDefined ] == true & [ fInfoList.IsDeclaredInHeader ] == true );
end 

if ~isempty( fInfoList )
fInfoFcnList = [ fInfoList.Function ];
else 
fInfoFcnList = [  ];
end 

isLibFcn = arrayfun( @( x )polyspace.internal.codeinsight.utils.isLibFunction( x.Name ), fInfoFcnList );
fInfoList = fInfoList( ~isLibFcn );


if options.KeepOnlySLCompliant
assert( self.hasSLCCCompliantInfo, "Interface header file requires SLCC compliant info" );
isSLCCCompliant = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( fInfoList );
fInfoList = fInfoList( isSLCCCompliant );
end 

typeList = internal.cxxfe.ast.types.Type.empty(  );


if ~isempty( fInfoList )

fList = [ fInfoList.Function ];
if options.KeepAllTypes
for fIdx = 1:numel( fList )
paramList = fList( fIdx ).Params.toArray;
if ~isempty( paramList )
typeList = [ typeList, paramList.Type ];%#ok<AGROW>
end 
typeList = [ typeList, fList( fIdx ).Type.RetType ];%#ok<AGROW>
end 
end 
end 


if options.KeepAllVariables


vInfoList = self.CodeInsightInfo.Variables.toArray;

if ~isempty( vInfoList )
vInfoList = vInfoList( [ vInfoList.IsDefined ] == true & [ vInfoList.IsDeclaredInHeader ] == true );
end 
if ~isempty( vInfoList ) && options.KeepOnlySLCompliant
isSLCCCompliant = polyspace.internal.codeinsight.CodeInfo.isSLCCImportCompliant( vInfoList );
vInfoList = vInfoList( isSLCCCompliant );
end 

if options.KeepAllTypes
if ~isempty( vInfoList )
vVariableList = [ vInfoList.Variable ];
else 
vVariableList = [  ];
end 

if ~isempty( vVariableList )
typeList = [ typeList, [ vVariableList.Type ] ];
end 
end 
end 

includeFileList = string( [  ] );


if options.KeepAllTypes
[ ~, IA, ~ ] = unique( string( { typeList.UUID } ), 'stable' );
typeList = typeList( IA );
[ includeFileList, ~ ] = polyspace.internal.codeinsight.CodeInfo.getTypeIncludes( typeList );
end 


for f = fInfoList
for decl = f.DeclarationSourceRange.toArray
currFile = decl.Start.File;
if currFile.IsInclude
currFileInclude = currFile.WrittenName;
if ~ismember( currFileInclude, includeFileList )
includeFileList( end  + 1 ) = currFileInclude;%#ok<AGROW>
end 
break ;
end 
end 
end 


if options.KeepAllVariables
for v = vInfoList
for decl = v.DeclarationSourceRange.toArray
currFile = decl.Start.File;
if currFile.IsInclude
currFileInclude = currFile.WrittenName;
if ~ismember( currFileInclude, includeFileList )
includeFileList( end  + 1 ) = currFileInclude;%#ok<AGROW>
end 
break ;
end 
end 
end 
end 


filteredHeaders = polyspace.internal.codeinsight.CodeInfo.filterHeadersFromGraph( originalHeaders, includeFileList, headerGraph );
if options.GenIncludeDirective
res = "#include """ + filteredHeaders + """";
else 
res = filteredHeaders;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpU1kjVA.p.
% Please follow local copyright laws when handling this file.

