classdef ProjectAnalyzer < dependencies.internal.attribute.AttributeAnalyzer




properties ( Constant )
InProject = i_createAttribute( "InProject" );
InUnreferencedProjectProblem = i_createProblem( "NotInProject", "MATLAB:dependency:project:InUnreferencedProjectProblem" );
NotInProject = i_createAttribute( "NotInProject" );
NotInProjectProblem = i_createProblem( "NotInProject", "MATLAB:dependency:project:NotInProjectProblem" );
UnderProjectRoot = i_createAttribute( "UnderProjectRoot" );
OutsideProjectRootProblem = i_createProblem( "OutsideProjectRoot", "MATLAB:dependency:project:OutsideProjectRootProblem" );
end 

properties ( SetAccess = immutable )
Project
end 

properties ( Constant, Access = private )
CacheUpdateInterval( 1, 1 )duration = seconds( 10 );
end 

properties ( Access = private )
UpdateTime( 1, 1 )datetime = NaT
ReferenceCache( 1, : )string = string.empty
end 

methods 
function this = ProjectAnalyzer( project )
R36
project( 1, 1 ){ mustBeA( project, [ "matlab.project.Project",  ...
"matlab.internal.project.api.Project" ] ) }
end 
this.Project = project;
end 

function problems = analyze( this, node, ~ )
import dependencies.internal.attribute.project.ProjectAnalyzer;

if ~node.Resolved || ~node.isFile
problems = ProjectAnalyzer.NotInProject;
return ;
end 

file = node.Location{ 1 };

[ underProjectRoot, projectRoot ] = matlab.internal.project.util.isUnderProjectRoot( file );
if ~underProjectRoot
problems = ProjectAnalyzer.NotInProject;
if ~i_isCacheFile( file )
problems( end  + 1 ) = ProjectAnalyzer.OutsideProjectRootProblem;
end 
return ;
end 

isUnderCurrentProject = projectRoot == this.Project.RootFolder;

if matlab.internal.project.util.isFileInProject( file, projectRoot );
problems = ProjectAnalyzer.InProject;
if ~isUnderCurrentProject && this.Project.isLoaded(  )
this.updateReferenceCache(  );
if ~ismember( projectRoot, this.ReferenceCache )
problems( end  + 1 ) = ProjectAnalyzer.InUnreferencedProjectProblem;
end 
end 
elseif i_isCacheFile( file )
problems = ProjectAnalyzer.NotInProject;
else 
problems = ProjectAnalyzer.NotInProjectProblem;
end 

if isUnderCurrentProject
problems( end  + 1 ) = ProjectAnalyzer.UnderProjectRoot;
end 
end 
end 

methods ( Access = private )
function updateReferenceCache( this )
currentTime = datetime( 'now' );
if isnat( this.UpdateTime ) || currentTime > this.UpdateTime + this.CacheUpdateInterval
this.ReferenceCache = string( [ this.Project.listAllProjectReferences.File ] );
this.UpdateTime = currentTime;
end 
end 
end 
end 

function problem = i_createAttribute( id )
import dependencies.internal.attribute.Attribute;
import dependencies.internal.attribute.AttributeIdentity;
import dependencies.internal.attribute.Severity;
identity = AttributeIdentity( id, "", Severity.Information );
problem = Attribute( identity );
end 

function problem = i_createProblem( id, resource )
import dependencies.internal.attribute.Attribute;
import dependencies.internal.attribute.AttributeIdentity;
import dependencies.internal.attribute.Severity;
identity = AttributeIdentity( id, string( message( resource ) ), Severity.Warning );
problem = Attribute( identity );
end 

function isCache = i_isCacheFile( file )
[ ~, ~, ext ] = fileparts( file );
isCache = strcmp( ext, ".slxc" );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9hpKIW.p.
% Please follow local copyright laws when handling this file.

