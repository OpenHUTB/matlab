classdef NsysTraceDataProcessor < handle

    properties
        data;
        diagnostics;
        computeTime;
        correlationIdToName;
    end

    properties ( SetAccess = immutable )
        labels;
        trace;
        excludeFirstRun;
    end

    methods
        function obj = NsysTraceDataProcessor( labels, trace, excludeFirstRun )
            obj.labels = labels;
            obj.trace = trace;
            obj.excludeFirstRun = excludeFirstRun;
            obj.initData(  );
            obj.process(  );
        end
    end

    methods ( Access = private )
        function process( obj )
            startIdx = obj.getStartIdx(  );
            for i = startIdx:numel( obj.trace )
                if isfield( obj.trace{ i }, 'CudaEvent' )
                    obj.addGpuEntry( obj.trace{ i } );
                elseif isfield( obj.trace{ i }, 'TraceProcessEvent' )
                    obj.addCpuEntry( obj.trace{ i } );
                elseif isfield( obj.trace{ i }, 'NvtxEvent' )
                    obj.addNvtxEntry( obj.trace{ i } );
                elseif isfield( obj.trace{ i }, 'DiagnosticEvent' )
                    obj.addDiagnostics( obj.trace{ i } );
                end
            end
        end

        function startIdx = getStartIdx( obj )
            if ~obj.excludeFirstRun
                startIdx = 1;
                return ;
            else
                for idx = 1:numel( obj.trace )
                    if ( obj.isEndOfOneRun( obj.trace{ idx } ) )
                        startIdx = idx + 1;
                        return ;
                    end
                end
                error( 'End of one run anchor not found.' );
            end
        end

        function initData( obj )
            defaultEntryStruct = struct( Start = {  }, Duration = {  }, Name = {  } );

            obj.data.Gpu.Memcpy = struct( Start = {  }, Duration = {  }, Name = {  }, Size = {  } );
            obj.data.Gpu.Kernel = struct( Start = {  },  ...
                Duration = {  },  ...
                Name = {  },  ...
                gridX = {  },  ...
                gridY = {  },  ...
                gridZ = {  },  ...
                blockX = {  },  ...
                blockY = {  },  ...
                blockZ = {  },  ...
                localMemoryTotal = {  },  ...
                StaticSMem = {  } );
            obj.data.Gpu.Memset = defaultEntryStruct;
            obj.data.Gpu.Sync = defaultEntryStruct;


            cpuEntryStruct = struct( Start = {  }, Duration = {  }, Name = {  }, CorrelationId = {  } );
            obj.data.Cpu.CUDA = cpuEntryStruct;
            obj.data.Cpu.cuBLAS = cpuEntryStruct;
            obj.data.Cpu.cuDNN = cpuEntryStruct;
            obj.data.Cpu.cuFFT = cpuEntryStruct;


            obj.data.Nvtx.Loop = defaultEntryStruct;
            obj.data.Nvtx.Functions = defaultEntryStruct;


            obj.diagnostics = struct( Source = {  }, Level = {  }, Text = {  } );


            obj.computeTime.gpuComputeTime = 0;
            obj.computeTime.cpuComputeTime = 0;


            obj.correlationIdToName = containers.Map( 'KeyType', 'int32', 'ValueType', 'char' );
        end

        function addGpuEntry( obj, trace )
            event = trace.CudaEvent;
            [ start, duration ] = obj.getStartAndDuration( event );
            obj.computeTime.gpuComputeTime = obj.computeTime.gpuComputeTime + duration;
            if isfield( event, 'memcpy' )
                obj.createMemcpyEntry( event, start, duration );
            elseif isfield( event, 'kernel' )
                obj.createKernelEntry( event, start, duration );
            elseif isfield( event, 'memset' )
                obj.createMemsetEntry( start, duration );
            elseif isfield( event, 'sync' )
                obj.createSyncEntry( start, duration );
            end
        end

        function createMemcpyEntry( obj, event, start, duration )
            entry = struct(  );
            memcpyEvent = event.memcpy;

            entry.Start = start;
            entry.Duration = duration;
            entry.Name = obj.getMemcpyName( memcpyEvent.srcKind, memcpyEvent.dstKind );
            entry.Size = str2double( memcpyEvent.sizebytes );
            obj.data.Gpu.Memcpy( end  + 1 ) = entry;

            obj.updateCorrelationIdToName( entry, event );
        end

        function entry = createKernelEntry( obj, event, start, duration )
            entry = struct(  );
            kernel = event.kernel;

            entry.Start = start;
            entry.Duration = duration;
            entry.Name = obj.labels.data{ str2double( kernel.shortName ) + 1 };
            entry.gridX = kernel.gridX;
            entry.gridY = kernel.gridY;
            entry.gridZ = kernel.gridZ;
            entry.blockX = kernel.blockX;
            entry.blockY = kernel.blockY;
            entry.blockZ = kernel.blockZ;
            entry.localMemoryTotal = kernel.localMemoryTotal;
            entry.StaticSMem = kernel.staticSharedMemory;
            obj.data.Gpu.Kernel( end  + 1 ) = entry;

            obj.updateCorrelationIdToName( entry, event );
        end

        function updateCorrelationIdToName( obj, entry, event )
            if isfield( event, 'correlationId' )
                obj.correlationIdToName( event.correlationId ) = entry.Name;
            end
        end

        function entry = createMemsetEntry( obj, start, duration )
            entry = struct(  );
            entry.Start = start;
            entry.Duration = duration;
            entry.Name = 'memset';
            obj.data.Gpu.Memset( end  + 1 ) = entry;
        end

        function entry = createSyncEntry( obj, start, duration )
            entry = struct(  );
            entry.Start = start;
            entry.Duration = duration;
            entry.Name = 'cudaDeviceSynchronize';
            obj.data.Gpu.Sync( end  + 1 ) = entry;
        end

        function addCpuEntry( obj, trace )
            event = trace.TraceProcessEvent;
            name = obj.removeVersion( obj.labels.data{ str2double( event.name ) + 1 } );
            [ start, duration ] = obj.getStartAndDuration( event );
            entry = struct(  );
            entry.Name = name;
            entry.Start = start;
            entry.Duration = duration;
            entry.CorrelationId = obj.getCorrelationId( event );

            if contains( name, 'cuda' )
                obj.data.Cpu.CUDA( end  + 1 ) = entry;
            elseif contains( name, 'cublas' )
                obj.data.Cpu.cuBLAS( end  + 1 ) = entry;
            elseif contains( name, 'cudnn' )
                obj.data.Cpu.cuDNN( end  + 1 ) = entry;
            elseif contains( name, 'fft' )
                obj.data.Cpu.cuFFT( end  + 1 ) = entry;
            end
        end

        function addDiagnostics( obj, trace )
            event = trace.DiagnosticEvent;
            entry = struct(  );
            entry.Source = event.Source;
            entry.Level = event.Level;
            entry.Text = event.Text;
            obj.diagnostics( end  + 1 ) = entry;
        end

        function addNvtxEntry( obj, trace )
            event = trace.NvtxEvent;
            entry = struct(  );
            entry.Duration = str2double( event.EndTimestamp ) - str2double( event.Timestamp );
            entry.Start = str2double( event.Timestamp );
            if strcmp( event.Text( 1:5 ), '#fcn#' )
                entry.Name = event.Text( 6:end  );
                obj.data.Nvtx.Functions( end  + 1 ) = entry;
            elseif strcmp( event.Text( 1:6 ), '#loop#' )
                entry.Name = event.Text( 6:end  );
                obj.data.Nvtx.Loop( end  + 1 ) = entry;
            end
        end
    end

    methods ( Access = private, Static = true )
        function result = isEndOfOneRun( trace )
            result = isfield( trace, 'NvtxEvent' ) && strcmp( trace.NvtxEvent.Text, '_mw_#exitPoint#' );
        end

        function [ start, duration ] = getStartAndDuration( event )
            start = str2double( event.startNs );
            duration = str2double( event.endNs ) - str2double( event.startNs );
        end

        function name = getMemcpyName( srcKind, dstKind )
            src = gpucoder.internal.profiling.NsysTraceDataProcessor.getMemcpyHostOrDevice( srcKind );
            dst = gpucoder.internal.profiling.NsysTraceDataProcessor.getMemcpyHostOrDevice( dstKind );
            name = [ 'cudaMemcpy (', src, ' to ', dst, ')' ];
        end

        function hostOrDevice = getMemcpyHostOrDevice( srcDstKind )



            switch srcDstKind
                case 0
                    hostOrDevice = 'Host';
                case 2
                    hostOrDevice = 'Device';
                otherwise
                    error( 'Unknown memcpy srd/dst kind.' );
            end
        end

        function newName = removeVersion( name )
            pattern = 'cuda[a-zA-Z0-9]+_v\d+';
            if ~isempty( regexp( name, pattern, 'once' ) )
                noVersionName = regexp( name, '_v\d+', 'split' );
                newName = noVersionName{ 1 };
            else
                newName = name;
            end
        end

        function correlationId = getCorrelationId( event )
            correlationId =  - 1;
            if isfield( event, 'correlationId' )
                correlationId = event.correlationId;
            end
        end
    end

    methods ( Static = true )
        function [ data, diagnostics, computeTime, correlationIdToName ] = getProcessedData( labels, trace, excludeFirstRun )
            arguments
                labels
                trace
                excludeFirstRun = false
            end
            processor = gpucoder.internal.profiling.NsysTraceDataProcessor( labels, trace, excludeFirstRun );
            data = processor.data;
            diagnostics = processor.diagnostics;
            computeTime = processor.computeTime;
            correlationIdToName = processor.correlationIdToName;
        end
    end


end

