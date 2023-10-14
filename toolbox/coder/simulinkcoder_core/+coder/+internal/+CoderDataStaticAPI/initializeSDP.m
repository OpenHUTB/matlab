function container = initializeSDP( fileName, options )

arguments
    fileName
    options.PlatformName( 1, 1 )string = "Untitled Platform"
end


container = coder.internal.CoderDataStaticAPI.createServiceInterface( fileName );
platform = container.SoftwarePlatforms( 1 );
platform.Name = options.PlatformName;
platform.findEntry( 'DataReceiverService', 'ReceiverExample1' ).Name = 'ReceiverOutsideExe';
platform.findEntry( 'DataReceiverService', 'ReceiverExample2' ).Name = 'ReceiverDuringExe';
platform.findEntry( 'DataReceiverService', 'ReceiverExample3' ).Name = 'ReceiverDirectAccess';
platform.findEntry( 'DataSenderService', 'SenderExample1' ).Name = 'SenderOutsideExe';
platform.findEntry( 'DataSenderService', 'SenderExample2' ).Name = 'SenderDuringExe';
platform.findEntry( 'DataSenderService', 'SenderExample3' ).Name = 'SenderDirectAccess';
platform.findEntry( 'DataTransferService', 'DataTransferExample1' ).Name = 'DataTransferOutsideExe';
platform.findEntry( 'DataTransferService', 'DataTransferExample2' ).Name = 'DataTransferDuringExe';
platform.findEntry( 'TimerService', 'TimerServiceExample1' ).Name = 'TimerService';
platform.findEntry( 'PeriodicAperiodicFunction', 'PeriodicAperiodicExample1' ).Name = 'PeriodicAperiodic';
platform.findEntry( 'SubcomponentEntryFunction', 'SubcomponentEntryFunctionExample1' ).Name = 'SubcomponentEntryFunction';
platform.findEntry( 'SharedUtilityFunction', 'SharedUtilityExample1' ).Name = 'SharedUtility';
platform.findEntry( 'MemorySection', 'DataMemorySectionExample1' ).Name = 'DataMemorySection1';
platform.findEntry( 'FunctionMemorySection', 'FunctionMemorySectionExample1' ).Name = 'FunctionMemorySection1';
platform.findEntry( 'ParameterTuningInterface', 'ParameterTuningExample1' ).Name = 'ParameterTuningService';
platform.findEntry( 'ParameterArgumentTuningInterface', 'ParameterArgumentTuningExample1' ).Name = 'ParameterArgumentTuningService';
platform.findEntry( 'MeasurementInterface', 'MeasurementExample1' ).Name = 'MeasurementService';

loadSimulinkPackage = true;
reset = false;
coder.internal.CoderDataStaticAPI.Utils.initializeDict( container.CDefinitions, loadSimulinkPackage, reset );



