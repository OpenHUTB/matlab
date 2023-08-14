

classdef HelpController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
UpdateSelectionComplete
    end

    properties(Constant)
        ControllerID="HelpController";
    end


    methods
        function this=HelpController()


            this.Subscriptions=[
            struct('messageID',"showhelp",'callback',@this.cb_showHelp);
            ];
        end
    end


    methods(Hidden)
        function cb_showHelp(~,args)

            switch args.data
            case "importFileHelp"
                helpHandle="edffileanalyzer_importFile";
            case "edfFileAnalyzerAppHelp"
                helpHandle="edffileanalyzer_app";
            otherwise
                helpHandle="edffileanalyzer_app";
            end

            mapRoot=fullfile(docroot,"/signal/","signal.map");
            helpview(mapRoot,helpHandle);
        end
    end
end