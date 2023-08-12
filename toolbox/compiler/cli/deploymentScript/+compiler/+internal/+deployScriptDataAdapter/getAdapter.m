function adapter = getAdapter( buildTarget, dataSource )




R36
buildTarget( 1, 1 )compiler.internal.DeploymentTarget
dataSource( 1, 1 )compiler.internal.deployScriptData.Data
end 


import compiler.internal.deployScriptDataAdapter.*
switch buildTarget


case compiler.internal.DeploymentTarget.StandaloneApplication
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = StandaloneApplicationProjectDataAdapter( dataSource );
else 
adapter = StandaloneApplicationPRJDataAdapter( dataSource );
end 

case compiler.internal.DeploymentTarget.WebAppArchive
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = WebAppArchiveProjectDataAdapter( dataSource );
else 
adapter = WebAppArchivePRJDataAdapter( dataSource );
end 

case compiler.internal.DeploymentTarget.ExcelAddin
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = ExcelAddInProjectDataAdapter( dataSource );
else 
adapter = ExcelAddInPRJDataAdapter( dataSource );
end 
otherwise 





if ~license( 'test', 'matlab_builder_for_java' )
error( message( 'Compiler:build:compatibility:sdkNotAvailable', '' ) )
end 

switch buildTarget

case compiler.internal.DeploymentTarget.COMComponent
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = COMComponentProjectDataAdapter( dataSource );
else 
adapter = COMComponentPRJDataAdapter( dataSource );
end 
case compiler.internal.DeploymentTarget.CppSharedLibrary
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = CppSharedLibraryProjectDataAdapter( dataSource );
else 
adapter = CppSharedLibraryPRJDataAdapter( dataSource );
end 
case compiler.internal.DeploymentTarget.CSharedLibrary
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = CSharedLibraryProjectDataAdapter( dataSource );
else 
adapter = CSharedLibraryPRJDataAdapter( dataSource );
end 
case compiler.internal.DeploymentTarget.DotNETAssembly
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = DotNETAssemblyProjectDataAdapter( dataSource );
else 
adapter = DotNETAssemblyPRJDataAdapter( dataSource );
end 
case compiler.internal.DeploymentTarget.JavaPackage
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = JavaPackageProjectDataAdapter( dataSource );
else 
adapter = JavaPackagePRJDataAdapter( dataSource );
end 
case compiler.internal.DeploymentTarget.ProductionServerArchive
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = PSAProjectDataAdapter( dataSource );
else 
adapter = PSAPRJDataAdapter( dataSource );
end 
case compiler.internal.DeploymentTarget.PythonPackage
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = PythonPackageProjectDataAdapter( dataSource );
else 
adapter = PythonPackagePRJDataAdapter( dataSource );
end 
case compiler.internal.DeploymentTarget.ExcelClientForProductionServer
if ( isa( dataSource, "compiler.internal.deployScriptData.ProjectData" ) )
adapter = ExcelClientForProductionServerBuildProjectDataAdapter( dataSource );
else 
adapter = ExcelClientForProductionServerBuildPRJDataAdapter( dataSource );
end 
otherwise 

end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdyc6vO.p.
% Please follow local copyright laws when handling this file.

