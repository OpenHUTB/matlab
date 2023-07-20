

classdef ImportDialog<handle
    properties(GetAccess=public,SetAccess=private)
        IS_DEBUG=false;
        url='';
        port='';
        window=[];
        textFieldValue='';
        dataPlacement='';
        selectedData=containers.Map;
    end

    properties(Access=private)
        htmlBaseDir='/toolbox/shared/sigbldr_import';
        htmlRelease='index.html';
        htmlDebug='index-debug.html';
        channelBaseDir='/sigbldr_import';
        cancelButtonChannel='/cancelButton';
        helpButtonChannel='/helpButton';
        textFieldChannel='/textField';
        browseButtonChannel='/browseButton';
        comboBoxChannel='/comboBox';
        confirmButtonChannel='/confirmButton';
        applyButtonChannel='/applyButton';
        okButtonChannel='/okButton';
        dataTreeChannel='/dataTree';
        stopChannel='/stopMessageService';
        glassPaneChannel='/glassPane';
        eventListeners=[];
    end

    events
        cancelButtonClicked;
        helpButtonClicked;
        textFieldEdited;
        browseButtonClicked;
        comboBoxSelected;
        confirmButtonClicked;
        applyButtonClicked;
        okButtonClicked;
    end

    methods(Access=public)
        function obj=ImportDialog(varargin)

            parseInputArguments(obj,varargin{:});


            try
                connector.ensureServiceOn;
            catch e
                throwAsCaller(e);
            end
            connector.newNonce;


            htmlName=obj.htmlRelease;
            if(obj.IS_DEBUG)
                htmlName=obj.htmlDebug;
            end
            obj.url=connector.getUrl([obj.htmlBaseDir,'/',htmlName]);


            obj.port=matlab.internal.getDebugPort();


            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.cancelButtonChannel],@obj.cancelButtonCallback)];
            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.helpButtonChannel],@obj.helpButtonCallback)];
            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.textFieldChannel],@obj.textFieldCallback)];
            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.browseButtonChannel],@obj.browseButtonCallback)];
            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.comboBoxChannel],@obj.comboBoxCallback)];
            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.confirmButtonChannel],@obj.confirmButtonCallback)];
            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.applyButtonChannel],@obj.applyButtonCallback)];
            obj.eventListeners=[obj.eventListeners,message.subscribe([obj.channelBaseDir,obj.okButtonChannel],@obj.okButtonCallback)];
        end

        function show(obj)
            if isempty(obj.window)

                obj.window=matlab.internal.webwindow(obj.url,obj.port);


                obj.window.Title=DAStudio.message('shared_sigbldr_import:messages:dialogTitle');
                obj.window.CustomWindowClosingCallback=@(evt,src)cancelButtonCallback(obj);
                obj.window.setWindowAsModal(true);


                set(0,'units','pixels');
                screenSize=get(0,'ScreenSize');
                resX=screenSize(3);
                resY=screenSize(4);
                width=min(700,resX);
                height=min(500,resY);
                cornerX=(resX-width)*0.25;
                cornerY=(resY-height)*0.75;
                obj.window.Position=[cornerX,cornerY,width,height];


                minWidth=min(600,width);
                minHeight=min(400,height);
                obj.window.setMinSize([minWidth,minHeight]);
            end

            if~obj.window.isVisible()

                obj.window.show();
                obj.bringToFront();
            end
        end

        function dispose(obj)

            for i=1:length(obj.eventListeners)
                message.unsubscribe(obj.eventListeners(i));
            end
            obj.eventListeners=[];


            message.publish([obj.channelBaseDir,obj.stopChannel],true);


            obj.url='';
            obj.port='';
            obj.textFieldValue='';
            obj.dataPlacement='';
            delete(obj.window);
            delete(obj);
        end

        function bringToFront(obj)
            if~isempty(obj.window)
                obj.window.bringToFront();
            end
        end

        function setTextField(obj,text)

            obj.textFieldValue=text;
            message.publish([obj.channelBaseDir,obj.textFieldChannel],text);
        end

        function setDataTree(obj,groupData)

            data=cell(size(groupData));
            for idx=1:length(groupData)
                elt=struct;
                elt.Group=groupData(idx).Name;
                elt.Signals={groupData(idx).Signals.Name};
                data{idx}=elt;
            end


            message.publish([obj.channelBaseDir,obj.dataTreeChannel],data);
        end

        function enableOkandApplyButtons(obj)

            obj.enableOkButton();
            obj.enableApplyButton();
        end

        function disableOkandApplyButtons(obj)

            obj.disableOkButton();
            obj.disableApplyButton();
        end

        function enableOkButton(obj)
            message.publish([obj.channelBaseDir,obj.okButtonChannel],true);
        end

        function disableOkButton(obj)
            message.publish([obj.channelBaseDir,obj.okButtonChannel],false);
        end

        function enableApplyButton(obj)
            message.publish([obj.channelBaseDir,obj.applyButtonChannel],true);
        end

        function disableApplyButton(obj)
            message.publish([obj.channelBaseDir,obj.applyButtonChannel],false);
        end

        function enableGlassPane(obj)
            message.publish([obj.channelBaseDir,obj.glassPaneChannel],true);
        end

        function disableGlassPane(obj)
            message.publish([obj.channelBaseDir,obj.glassPaneChannel],false);
        end
    end

    methods(Access=private)
        function parseInputArguments(obj,varargin)
            parser=inputParser;
            addParameter(parser,'Debug',false,@obj.validateDebugParam);
            parse(parser,varargin{:});
            obj.IS_DEBUG=parser.Results.Debug;
        end

        function validateDebugParam(~,val)
            if~isempty(val)&&~islogical(val)
                error(DAStudio.message('shared_sigbldr_import:messages:errorParamDebug'));
            end
        end

        function cancelButtonCallback(obj,~)
            notify(obj,'cancelButtonClicked');
        end

        function helpButtonCallback(obj,~)
            notify(obj,'helpButtonClicked');
        end

        function textFieldCallback(obj,data)
            obj.textFieldValue=data;
            notify(obj,'textFieldEdited');
        end

        function browseButtonCallback(obj,~)
            notify(obj,'browseButtonClicked');
        end

        function comboBoxCallback(obj,data)
            obj.dataPlacement=data;
            notify(obj,'comboBoxSelected');
        end

        function confirmButtonCallback(obj,data)
            obj.selectedData=data;
            notify(obj,'confirmButtonClicked');
        end

        function applyButtonCallback(obj,~)
            notify(obj,'applyButtonClicked');
        end

        function okButtonCallback(obj,~)
            notify(obj,'okButtonClicked');
        end
    end
end

