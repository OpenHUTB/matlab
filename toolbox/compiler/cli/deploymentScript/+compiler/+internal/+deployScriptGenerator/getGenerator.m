function generator = getGenerator( target, adapter )



R36
target( 1, 1 ){ mustBeA( target, [ "compiler.internal.DeploymentTarget", "compiler.internal.PackageType" ] ) }
adapter( 1, 1 )compiler.internal.deployScriptDataAdapter.DataAdapter
end 

import compiler.internal.deployScriptGenerator.*
switch target



case compiler.internal.DeploymentTarget.StandaloneApplication
generator = StandaloneBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.WebAppArchive
generator = WebAppArchiveBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.ExcelAddin
generator = ExcelAddInBuildScriptGenerator( adapter );

case compiler.internal.PackageType.MCRInstaller
generator = MCRInstallerScriptGenerator( adapter );

case compiler.internal.PackageType.NoInstaller
generator = NoInstallerScriptGenerator( adapter );

otherwise 




if ~license( 'test', 'matlab_builder_for_java' )
error( message( 'Compiler:build:compatibility:sdkNotAvailable', '' ) )
end 

switch target
case compiler.internal.DeploymentTarget.COMComponent
generator = COMComponentBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.CppSharedLibrary
generator = CppSharedLibraryBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.CSharedLibrary
generator = CSharedLibraryBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.DotNETAssembly
generator = DotNETAssemblyBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.JavaPackage
generator = JavaPackageBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.ProductionServerArchive
generator = PSABuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.PythonPackage
generator = PythonPackageBuildScriptGenerator( adapter );

case compiler.internal.DeploymentTarget.ExcelClientForProductionServer
generator = ExcelClientForProductionServerBuildScriptGenerator( adapter );

case compiler.internal.PackageType.ExcelClientForProductionServer
generator = ExcelClientForProductionServerPackageScriptGenerator( adapter );

otherwise 
error( message( "Compiler:deploymentscript:invalidGeneratorTarget", target ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVEO4Q5.p.
% Please follow local copyright laws when handling this file.

