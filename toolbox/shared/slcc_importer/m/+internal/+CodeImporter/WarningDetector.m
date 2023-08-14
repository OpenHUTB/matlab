classdef WarningDetector<handle
    properties(Dependent,SetAccess=private)



        DetectedWarnings;
    end

    properties(Transient,Access=private)
Logger
Logging
        LocalDetectedWarnings=matlab.internal.diagnostic.Warning.empty;
    end

    methods
        function detector=WarningDetector()

            import matlab.unittest.internal.constraints.WarningLogger;
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            detector.Logger=WarningLogger;
            detector.openWarningLog;
        end

        function warnings=get.DetectedWarnings(detector)



            detector.makeWarningsLocal();
            warnings=detector.LocalDetectedWarnings;
        end

    end

    methods(Hidden)
        function closeWarningLog(detector)
            detector.Logger.stop();
            detector.Logging=false;
        end

        function openWarningLog(detector)
            detector.Logger.start();
            detector.Logging=true;
        end
    end

    methods(Access=private)

        function makeWarningsLocal(detector)

            if detector.Logging
                c=onCleanup(@detector.openWarningLog);
            end
            detector.closeWarningLog();
            newWarnings=detector.Logger.Warnings;
            detector.resetLogger();
            detector.LocalDetectedWarnings=[detector.LocalDetectedWarnings,newWarnings];
        end

        function resetLogger(detector)
            import matlab.unittest.internal.constraints.WarningLogger;

            if detector.Logging
                c=onCleanup(@detector.openWarningLog);
            end
            detector.Logger=WarningLogger;
        end
    end
end