classdef ViewInstance<handle




    properties(GetAccess=public,SetAccess=private)
        cefObj;
    end

    properties(Access=private)
        matlabClose;
        stmRendered;
    end

    methods(Access=private)
        function obj=ViewInstance
        end

        function cefCloseCallback(obj,~)
            obj.cefObj.delete;
            obj.cefObj=[];
            message.unsubscribe(obj.matlabClose);
            message.unsubscribe(obj.stmRendered);
        end

        function stmRenderedCallback(~,onShutdown)
            if onShutdown

                payloadStruct=struct('VirtualChannel','MatlabClosed','Payload',0);
                message.publish('/stm/messaging',payloadStruct);
            end
        end
    end

    methods(Access=public)
        function closeCef(obj)
            if~isempty(obj.cefObj)
                obj.cefCloseCallback();
            end
        end

        function exitCef(obj)
            obj.closeCef();



            delete(obj.cefObj);
            obj.cefObj=[];
        end
    end

    methods(Static)

        function singleObj=getInstance
            mlock;
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=stm.internal.ViewInstance;
            end
            singleObj=localObj;
        end



        function bringToFront(onShutdown)
            if nargin==0,onShutdown=false;end
            instance=stm.internal.ViewInstance.getInstance();

            if~isempty(instance.cefObj)
                instance.cefObj.bringToFront();
            else

                stm.internal.Connector.on();
                instance.launchCef(false,onShutdown);
            end
        end

        function onShutdown

            stm.internal.ViewInstance.bringToFront(true);
        end


        function getCefWindowSize()
            instance=stm.internal.ViewInstance.getInstance();

            position=zeros(1,4);
            if~isempty(instance.cefObj)
                position=instance.cefObj.Position;
            end

            stm.internal.getCefWindowSize(position(1),position(2),position(3),position(4));
        end

        function MATLABWindowExited(~,~)
            sltest.testmanager.close;
        end

        function ret=isCEFLaunched()
            instance=stm.internal.ViewInstance.getInstance();
            ret=~isempty(instance.cefObj);
        end
    end

    methods
        function cefObj=launchCef(obj,debug,onShutdown)
            if nargin<=2,onShutdown=false;end
            if isempty(obj.cefObj)||~obj.cefObj.isWindowValid
                obj.createCEFObject(debug,onShutdown);
            end

            obj.cefObj.show();
            stm.internal.ViewInstance.bringToFront();
            cefObj=obj.cefObj;
        end


        function fullUrl=launchStm(~,browser,debug,~)
            position='-position=150,150,1440,850';
            fullUrl=getSTMUrl(debug);

            chrome_options=[...
' --disk-cache-size=1'...
            ,' --media-cache-size=1 '...
            ];

            if ispc

                location1='C:\PROGRA~2\Google\Chrome\Application\chrome.exe';
                user=getenv('UserName');
                location2=['C:\Users\',user,'\AppData\Local\Google\Chrome\Application\chrome.exe'];
                chromeLocation='';
                if exist(location1,'file')
                    chromeLocation=location1;
                elseif exist(location2,'file')
                    chromeLocation=location2;
                end

                bin='';
                switch computer
                case{'PCWIN64'}
                    setenv('PATH',[getenv('PATH'),';',matlabroot,'\bin\win64']);
                    bin='win64';
                end
                cefPath=fullfile(matlabroot,'cefclient','bin',bin,'cefclient.exe');
                chrome.command=['!',chromeLocation,' ',fullUrl,' ',chrome_options,' &'];
                cef.command=sprintf('!%s %s -url=%s &',cefPath,position,fullUrl);
            elseif ismac
                chrome_options=[chrome_options,' --new-window'];
                chrome.command=[...
'!open -n -a /Applications/Google\ Chrome.app '...
                ,'--args '...
                ,fullUrl...
                ,chrome_options...
                ];
                cefPath=fullfile(matlabroot,'cefclient','bin','maci64','cefclient.app','Contents','MacOS','cefclient');
                cef.command=sprintf('!%s %s -url=%s',cefPath,position,fullUrl);
            elseif isunix




                cefPath=['!env LD_PRELOAD=/usr/lib/libfreetype.so ',fullfile(matlabroot,'cefclient','bin','glnxa64','cefclient')];
                chrome.command=sprintf('!bash -c "LD_LIBRARY_PATH="" /usr/bin/google-chrome %s" &',fullUrl);
                cef.command=sprintf('%s %s -url=%s &',cefPath,position,fullUrl);
            end

            switch browser
            case 'cef'
                eval(cef.command);
            case 'chrome'
                if ispc&&isempty(chromeLocation)
                    error(message('stm::general:CannotLocateSpecifiedBrowser',browser));
                else
                    eval(chrome.command);
                end
            case 'nobrowser'
                disp('');
            otherwise
                error(message('stm:general:InvalidBrowser',browser));
            end
        end

        function createCEFObject(obj,debug,onShutdown)



            fullUrl=getSTMUrl(debug);

            dialogPos=getCenterScreenSize();

            if debug
                cef=matlab.internal.webwindow(fullUrl,9222,dialogPos);
            else
                cef=matlab.internal.webwindow(fullUrl,matlab.internal.getDebugPort);
                cef.Position=dialogPos;
            end

            cef.Title=getString(message('stm:general:Title'));

            cef.MATLABWindowExitedCallback=@stm.internal.ViewInstance.MATLABWindowExited;
            obj.cefObj=cef;

            obj.matlabClose=message.subscribe('/stm/messaging/cefClose',@(arg)cefCloseCallback(obj,arg));
            obj.stmRendered=message.subscribe('/stm/messaging/stmrendered',@(arg)stmRenderedCallback(obj,onShutdown));
        end
    end
end

function dialogPos=getCenterScreenSize()
    screenSize=get(0,'ScreenSize');
    dialogW=3*screenSize(3)/4;
    dialogH=3*screenSize(4)/4;


    dialogPos(1)=(screenSize(3)-dialogW)/2;
    dialogPos(2)=(screenSize(4)-dialogH)/2;
    dialogPos(3)=dialogW;
    dialogPos(4)=dialogH;
end

function fullUrl=getSTMUrl(debug)
    if debug
        url='MainView_Debug.html';
    else
        url='MainView.html';
    end

    fullUrl=connector.getUrl(['/toolbox/stm/stm/',url]);


    fullUrl=[fullUrl,'&allowReleaseManagerGUI=',int2str(slfeature('CrossReleaseManagerGUI'))];
    fullUrl=[fullUrl,'&showAssessmentsCallback=',stm.internal.assessmentsFeature('ShowAssessmentsCallback')];
    fullUrl=[fullUrl,'&useReservedTimeVariable=',stm.internal.assessmentsFeature('useReservedTimeVariable')];
    fullUrl=[fullUrl,'&showScriptedTests=',int2str(slfeature('STMScriptedTest'))];
    fullUrl=[fullUrl,'&showTestSequenceScenario=',int2str(slfeature('STMTestSequenceScenario'))];
    fullUrl=[fullUrl,'&allowMRTAssessments=',stm.internal.assessmentsFeature('AllowMRTAssessments')];
    fullUrl=[fullUrl,'&convertToDesktop=',int2str(slfeature('STMConvertToDeskTop'))];
    fullUrl=[fullUrl,'&outputTriggering=',int2str(slfeature('STMOutputTriggering'))];
end
