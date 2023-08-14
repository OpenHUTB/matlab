classdef VideoLabelerSessionManager<vision.internal.uitools.SessionManager
    methods

        function this=VideoLabelerSessionManager()
            this=this@vision.internal.uitools.SessionManager();






            if isa(this,'driving.internal.videoLabeler.tool.VideoLabelerSessionManager')
                this.AppName=vision.getMessage('vision:labeler:ToolTitleGTL');
                this.SessionField='groundTruthLabelingSession';
                this.SessionClass='driving.internal.videoLabeler.tool.Session';
            else
                this.AppName='Video Labeler';
                this.SessionField='videoLabelingSession';
                this.SessionClass='vision.internal.videoLabeler.tool.Session';
            end
        end


        function session=loadSession(this,pathname,filename,hFig)
            session=[];

            try

                fullname=[pathname,filename];
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


                resetIsPixelLabelChangedAll(session);
                success=true;
            catch savingEx
                errorMsg=savingEx.message;
                dlgTitle=vision.getMessage('vision:uitools:SavingSessionFailedTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithModal',errorMsg,dlgTitle);
                success=false;
            end
        end
    end
end


function assignSessionVar(sessionVar,session)


    assignin('caller',sessionVar,session');
end
