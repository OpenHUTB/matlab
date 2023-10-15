classdef HarnessCreateCustomizer < handle


    properties ( SetAccess = private )
        Name( 1, 1 )string = "";
        PostCreateCallback( 1, 1 )string = "";
        SaveExternally( 1, 1 )logical = false;
        LogOutputs( 1, 1 )logical = false;
        Source( 1, 1 )string{ validateSources( Source ) } ...
            = string( Simulink.harness.internal.TestHarnessSourceTypes.INPORT.name );
        Sink( 1, 1 )string{ validateSinks( Sink ) } ...
            = string( Simulink.harness.internal.TestHarnessSinkTypes.OUTPORT.name );
        Description( 1, 1 )string = "";
        SeparateAssessment( 1, 1 )logical = false;
        SynchronizationMode( 1, 1 )string{ validateArgumentVal( 'SynchronizationMode', SynchronizationMode,  ...
            [ "SyncOnOpenAndClose", "SyncOnOpen", "SyncOnPushRebuildOnly" ] ) } ...
            = "SyncOnOpenAndClose";
        CreateWithoutCompile( 1, 1 )logical = false;
        RebuildOnOpen( 1, 1 )logical = false;
        RebuildModelData( 1, 1 )logical = false;
        HarnessPath( 1, 1 )string = "";
        PostRebuildCallback( 1, 1 )string = "";
        ScheduleInitTermReset( 1, 1 )logical = false;
        SchedulerBlock( 1, 1 )string{ validateArgumentVal( 'SchedulerBlock', SchedulerBlock,  ...
            [ "None", "Test Sequence", "MATLAB Function", "Schedule Editor", "Chart" ] ) } ...
            = "Test Sequence";
        AutoShapeInputs( 1, 1 )logical = false;
        CustomSourcePath( 1, 1 )string = "";
        CustomSinkPath( 1, 1 )string = "";
        VerificationMode( 1, 1 )string{ validateArgumentVal( 'VerificationMode', VerificationMode,  ...
            [ "Normal", "SIL", "PIL" ] ) } = "Normal";
    end

    properties ( SetAccess = private, Hidden = true )
        userDefinedProps = {  };
        activeCustomizationFile = "";
        slcFileDefaultsUpdatedbyAPI = false;
    end

    methods ( Hidden = true )
        function setDefaults( obj, harnessStruct )
            arguments
                obj
                harnessStruct( 1, 1 )struct
            end

            stack = dbstack( '-completenames', 2 );

            customizeVia_SLCFile = { stack.name } == "sl_customization";
            customizeVia_API = { stack.name } == "setHarnessCreateDefaults";
            matchingIndices = customizeVia_SLCFile | customizeVia_API;
            atleastOnePropertyUpdated = false;

            if ~isempty( stack ) && any( matchingIndices )
                if any( customizeVia_SLCFile )
                    obj.reset;
                    obj.activeCustomizationFile = stack( find( matchingIndices, 1 ) ).file;
                    disp( message( 'Simulink:Harness:BeginDefaultsRegistrationUsingSLCFile',  ...
                        obj.activeCustomizationFile ).getString )
                end

                fName = fieldnames( harnessStruct );
                objProps = properties( obj );
                for fCtr = 1:numel( fName )
                    propName = fName{ fCtr };
                    propIdx = strcmpi( objProps, propName );
                    if any( propIdx )



                        try
                            obj.( objProps{ propIdx } ) = harnessStruct.( propName );
                            atleastOnePropertyUpdated = true;



                            if ~ismember( propName, obj.userDefinedProps )
                                obj.userDefinedProps{ end  + 1 } = propName;
                            end
                        catch ME
                            Simulink.harness.internal.warn( ME )
                        end
                    elseif strcmpi( propName, "LogHarnessOutputs" )


                        try
                            obj.LogOutputs = harnessStruct.( propName );
                        catch ME
                            Simulink.harness.internal.warn( ME )
                        end
                    else
                        Simulink.harness.internal.warn( { 'Simulink:Harness:InvalidCustomizableProperty', propName } );
                    end
                end


                if ( atleastOnePropertyUpdated && any( customizeVia_API ) &&  ...
                        obj.activeCustomizationFile ~= "" )
                    disp( message( 'Simulink:Harness:HarnessCreateDefaultsUpdatedByAPI',  ...
                        obj.activeCustomizationFile ).getString )
                    if obj.slcFileDefaultsUpdatedbyAPI
                        disp( message( 'Simulink:Harness:HarnessCreateDefaultsPrevUpdateMessage' ).getString )
                    else
                        obj.slcFileDefaultsUpdatedbyAPI = true;
                    end
                end
            else
                Simulink.harness.internal.warn( 'Simulink:Harness:InvalidCallerForDefaultPropertySetter' );
            end
        end
    end

    methods ( Hidden = true )
        function reset( obj )

            tempObj = Simulink.harness.HarnessCreateCustomizer(  );
            props = properties( tempObj );
            for idx = 1:length( props )
                propName = props{ idx };
                obj.( propName ) = tempObj.( propName );
            end
            obj.userDefinedProps = {  };
            obj.activeCustomizationFile = "";
            obj.slcFileDefaultsUpdatedbyAPI = false;
        end
    end
end

function validateArgumentVal( param, input, inputList )

if ~any( strcmpi( input, inputList ) )
    DAStudio.error( 'Simulink:Harness:InvalidInputArgumentForHarnessDefaults',  ...
        param, strjoin( inputList, ''', ''' ), input );
end
end

function validateSources( input )
validSources = Simulink.harness.internal.getTestingSourcesList(  ...
    "IncludeSigBuilder", false );
validateArgumentVal( 'Source', input, validSources );
end

function validateSinks( input )
validSinks =  ...
    Simulink.harness.internal.getTestingSinksList( 'IncludeChartAndAssmt', 0 );
validateArgumentVal( 'Sink', input, validSinks );
end
