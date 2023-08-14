classdef ViewInstance<handle



    properties(Access=private)
        cefObj;
    end

    properties(GetAccess=public,SetAccess=private)
        isOpen=false;
        isHidden=false;
        cefLeft=0;
        cefBottom=0;
        cefWidth=0;
        cefHeight=0;
    end
    methods(Access=private)
        function obj=ViewInstance
        end

        function cefCloseCallback(obj,~)
            obj.cefObj.hide();
            obj.isHidden=true;
        end
    end

    methods(Access=public)
        function closeCef(obj)
            if~isempty(obj.cefObj)&&obj.cefObj.isWindowValid
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
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=sltest.assessments.internal.ViewInstance;
            end
            singleObj=localObj;
        end



        function bringToFront()
            instance=sltest.assessments.internal.ViewInstance.getInstance();

            if isempty(instance)||~isvalid(instance)
                return;
            end

            if~isempty(instance.cefObj)
                instance.cefObj.bringToFront();
            else

                connector.ensureServiceOn;
                instance.launchCef(false);
            end
            instance.isHidden=false;
        end

        function MATLABWindowExited(~,~)
            instance=sltest.assessments.internal.ViewInstance.getInstance();
            if isempty(instance)||~isvalid(instance)
                return;
            end
            instance.exitCef();
        end

        function ret=isCEFLaunched()
            instance=sltest.assessments.internal.ViewInstance.getInstance();

            if isempty(instance)||~isvalid(instance)
                ret=false;
            else
                if(~isempty(instance.cefObj))
                    ret=true;
                else
                    ret=false;
                end
            end
        end

        function url=getURL(debug)
            if debug
                url='index-proto-debug.html?debug=1';
            else
                url='index-proto.html';
            end
            url=connector.getUrl(['/toolbox/simulinktest/core/assessments_editor/assessments_editor_ui/',url]);
        end
    end

    methods
        function cefObj=launchCef(obj,debug)
            if isempty(obj.cefObj)
                obj.createCEFObject(debug);
            end

            try
                obj.cefObj.show();
                sltest.assessments.internal.ViewInstance.bringToFront();
            catch
                delete(obj.cefObj);
                obj.cefObj=[];
                obj.createCEFObject(debug);
                obj.cefObj.show();
                sltest.assessments.internal.ViewInstance.bringToFront();
            end
            cefObj=obj.cefObj;
        end


        function fullUrl=launchAssessmentEditor(obj,browser,debug,~)
            position='-position=150,150,1440,850';



            fullUrl=obj.getURL(debug);

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
                case{'PCWIN'}
                    setenv('PATH',[getenv('PATH'),';',matlabroot,'\bin\win32']);
                    bin='win32';
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
            else
                return;
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

        function createCEFObject(obj,debug)


            obj.isOpen=true;

            fullUrl=obj.getURL(debug);

            dialogPos=getCenterScreenSize();

            if debug
                cef=matlab.internal.webwindow(fullUrl,9222,dialogPos);
            else
                cef=matlab.internal.webwindow(fullUrl);
                cef.Position=dialogPos;
            end

            cef.Title='Simulink Test Assessments Editor';
            cef.MATLABWindowExitedCallback=@sltest.assessments.internal.ViewInstance.MATLABWindowExited;
            obj.cefObj=cef;
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