function [ ret, compilerBaseName, compilerExeName ] = toolchainUsesKnownCompiler( tc, targetLang )



R36
tc( 1, 1 )
targetLang( 1, : )char{ mustBeMember( targetLang, { 'C', 'C++' } ) }
end 

buildCompiler = sprintf( '%s Compiler', targetLang );
buildTool = tc.getBuildTool( buildCompiler );
compilerName = buildTool.Command.getValue;
if ispc(  )
exeExt = '.exe';
else 
exeExt = '';
end 
compilerBaseName = regexprep( compilerName, '^.*\s', '' );

if endsWith( compilerBaseName, exeExt )
compilerExeName = compilerBaseName;
[ ~, compilerBaseName ] = fileparts( compilerExeName );
else 

compilerExeName = [ compilerBaseName, exeExt ];
end 

ret = polyspace.internal.sniffer.feature( 'useKnownCompilers' ) &&  ...
isKnownCompiler( compilerExeName, compilerBaseName );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpffR54y.p.
% Please follow local copyright laws when handling this file.

