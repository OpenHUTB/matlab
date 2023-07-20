

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
            case "importSignalHelp"
                helpHandle="waveletsignaldenoiser_importSignal";
            case "waveletSignalDenoiserHelpButton"
                helpHandle="waveletsignaldenoiser_app";
            otherwise
                helpHandle="waveletsignaldenoiser_app";
            end

            mapRoot=fullfile(docroot,"/wavelet/","wavelet.map");
            helpview(mapRoot,helpHandle);
        end
    end
end