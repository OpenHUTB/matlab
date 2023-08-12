function [ algLoops, hUI ] = getBDAlgebraicLoopsImpl( mdlH )



















needToThrowError = false;
caughtError = '';

try 
if ( ~strcmp( get_param( mdlH, 'Type' ), 'block_diagram' ) )

needToThrowError = true;
end 
catch caughtError
needToThrowError = true;
end 

if ( needToThrowError )
identifier = 'Simulink:utility:NeedsBlockDiagram';
me = MSLException( message( identifier ) );
if ( ~isempty( caughtError ) )
me = addCause( me, caughtError );
end 
throw( me );
end 


mdlOriginalArtAlgMsg = get_param( mdlH, 'ArtificialAlgebraicLoopMsg' );
mdlOriginalAlgMsg = get_param( mdlH, 'AlgebraicLoopMsg' );
mdlOriginalDirtyFlag = get_param( mdlH, 'Dirty' );


cs = getActiveConfigSet( mdlH );
isConfigSetRef = strcmp( cs.class, 'Simulink.ConfigSetRef' );



c = onCleanup( @(  )localModelCleanup(  ...
mdlH, mdlOriginalAlgMsg, mdlOriginalArtAlgMsg, mdlOriginalDirtyFlag, isConfigSetRef ) );

try 





localSetParam( mdlH, 'AlgebraicLoopMsg', 'none', isConfigSetRef );



if strcmp( mdlOriginalArtAlgMsg, 'error' )
localSetParam( mdlH, 'ArtificialAlgebraicLoopMsg', 'warning', isConfigSetRef );
end 
[ algLoops, hUI ] = Simulink.Structure.highlightalgLoop( get_param( mdlH, 'Name' ), true );
localSetParam( mdlH, 'AlgebraicLoopMsg', mdlOriginalAlgMsg, isConfigSetRef );
localSetParam( mdlH, 'ArtificialAlgebraicLoopMsg', mdlOriginalArtAlgMsg, isConfigSetRef );
localSetParam( mdlH, 'Dirty', mdlOriginalDirtyFlag, isConfigSetRef );
catch e
identifier = 'Simulink:utility:GetAlgebraicLoopFailed';
me = MSLException( message( identifier, get_param( mdlH, 'Name' ) ) );
me = addCause( me, e );
throw( me );
end 
end 



function localModelCleanup( mdlH, mdlOriginalAlgMsg, mdlOriginalArtAlgMsg,  ...
mdlOriginalDirtyFlag, isConfigSetRef )

localSetParam( mdlH, 'AlgebraicLoopMsg', mdlOriginalAlgMsg, isConfigSetRef );
localSetParam( mdlH, 'ArtificialAlgebraicLoopMsg', mdlOriginalArtAlgMsg, isConfigSetRef );
localSetParam( mdlH, 'Dirty', mdlOriginalDirtyFlag, isConfigSetRef );
end 


function localSetParam( mdlH, paramName, paramValue, isConfigSetRef )

if ( isConfigSetRef )
SLStudio.Utils.setConfigSetParam( mdlH, paramName, paramValue );
else 
set_param( mdlH, paramName, paramValue );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfIFRZf.p.
% Please follow local copyright laws when handling this file.

