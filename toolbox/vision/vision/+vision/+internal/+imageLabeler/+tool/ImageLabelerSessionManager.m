classdef ImageLabelerSessionManager<vision.internal.uitools.SessionManager
    methods

        function this=ImageLabelerSessionManager()
            this=this@vision.internal.uitools.SessionManager();
            this.AppName=vision.getMessage('vision:labeler:ToolTitleIL');
            this.SessionField='imageLabelingSession';
            this.SessionClass='vision.internal.imageLabeler.tool.Session';
        end


        function session=loadSession(this,pathname,filename,hFig)
            session=[];

            try

                fullname=[pathname,filename];





                ws=warning('off','MATLAB:load:cannotInstantiateLoadedVariable');
                cl=onCleanup(@()warning(ws));

                temp=load(fullname,'-mat');

                if isValidSessionFile(this,temp)

                    session=temp.(this.SessionField);
                    if isempty(session.FileName)
                        session.FileName=fullname;
                    end

                    session.checkImagePaths(pathname,session.FileName);
                    session.FileName=fullname;
                else
                    errorMsg=getString(message(this.CustomErrorMsgId,...
                    fullname,this.AppName));
                    dlgTitle=getString(message('vision:uitools:LoadingSessionFailedTitle'));
                    vision.internal.labeler.handleAlert(hFig,'errorWithModal',errorMsg,dlgTitle);
                end

            catch loadSessionEx
                session=[];
                if strcmp(loadSessionEx.identifier,'MATLAB:load:notBinaryFile')
                    errorMsg=getString(message('vision:uitools:invalidSessionFile',...
                    fullname,this.AppName));
                else
                    errorMsg=loadSessionEx.message;
                end

                dlgTitle=getString(message('vision:uitools:LoadingSessionFailedTitle'));
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',errorMsg,dlgTitle);
            end
        end


        function success=saveSession(this,session,filename,hFig)

            session.FileName=filename;
            sessionVar=this.SessionField;
            assignSessionVar(sessionVar,session');

            try
                eval(sprintf('saveSessionData(%s);',sessionVar));
                save(filename,sessionVar);
                session.IsChanged=false;
                success=true;
            catch savingEx
                msg=savingEx.message;
                title=vision.getMessage('vision:uitools:SavingSessionFailedTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',msg,title);
                success=false;
            end
        end
    end
end


function assignSessionVar(sessionVar,session)


    assignin('caller',sessionVar,session');
end