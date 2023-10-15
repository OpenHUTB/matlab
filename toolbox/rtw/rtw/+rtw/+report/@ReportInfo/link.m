function link( obj, model, fromMat )

arguments
    obj
    model
    fromMat = true
end

currentTarget = strtok( get_param( model, 'SystemTargetFile' ), '.' );
if ( ~isempty( obj.Target ) && ~strcmp( obj.Target, currentTarget ) ) &&  ...
        ~locIsXILSubsystemBuild( obj, model ) && ~locIsSFcnSubsystemBuild( obj )
    DAStudio.error( 'RTW:report:TargetMismatch', currentTarget, obj.Target );
end
if fromMat
    rtw.report.ReportInfo.setInstance( model, obj );
end




function out = locIsXILSubsystemBuild( obj, model )
out = false;
if ~isempty( obj.SourceSubsystem )
    try
        isBdLoaded = bdIsLoaded( bdroot( obj.TemporaryModelFullSSName ) );
    catch


        isBdLoaded = false;
    end
    if isBdLoaded
        srcMdl = bdroot( obj.TemporaryModelFullSSName );
    else
        srcMdl = model;
    end
    out = ( strcmp( get_param( srcMdl, 'CreateSILPILBlock' ), 'SIL' ) ||  ...
        strcmp( get_param( srcMdl, 'CreateSILPILBlock' ), 'PIL' ) );
end


function out = locIsSFcnSubsystemBuild( obj )
out = false;
if ~isempty( obj.SourceSubsystem )
    out = strcmp( obj.Target, 'rtwsfcn' );
end



