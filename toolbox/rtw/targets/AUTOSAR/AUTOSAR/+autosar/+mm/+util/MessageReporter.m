classdef MessageReporter<handle
    properties(Hidden=true,GetAccess=public,SetAccess=private)
        useNagCtrlr;
    end


    properties(Hidden=true,Access=public)
        DisplayInfoMsgs=false;
    end


    methods(Access=public)

        function self=MessageReporter(nag)
            if nargin<1
                nag=false;
            end
            self.useNagController(nag);
        end


        function useNagController(self,nag)
            self.useNagCtrlr=nag;
        end


        function clear(~,~)
        end


        function ret=flush(self,msgs,overrideHeadMsgId)
            exception=MSLException('RTW:fcnClass:finish',...
            DAStudio.message('RTW:fcnClass:finish','Multiple causes'));

            if nargin>=2&&~isempty(overrideHeadMsgId)

                exception=MSLException([],message(overrideHeadMsgId));
            end

            ret=true;
            msgCount=numel(msgs);
            if self.useNagCtrlr
                for ii=1:msgCount

                    msg=msgs(ii);
                    if strcmp(msg.type,'Info')&&~self.DisplayInfoMsgs
                        continue
                    end

                    if strcmpi(msg.type,'Error')
                        sldiagviewer.reportError(nag.msg.details,'Component',msg.component,'Category',self.tweakMessage(msg.identifier));
                    elseif strcmpi(msg.type,'Info')
                        sldiagviewer.reportInfo(nag.msg.details,'Component',msg.component,'Category',self.tweakMessage(msg.identifier));
                    else
                        sldiagviewer.reportWarning(nag.msg.details,'Component',msg.component,'Category',self.tweakMessage(msg.identifier));
                    end
                    if strcmp(msg.type,'Error')
                        ret=false;
                    end
                end

                optTitle='AUTOSAR Target Diagnostic Viewer';
                dv=find_dv();
                dv.setTitle(optTitle);
            else
                for ii=1:msgCount
                    msg=msgs(ii);
                    msgId=strrep(msg.identifier,'_',':');
                    msgId=strrep(msgId,' ',':');

                    switch msg.type
                    case 'Error'

                        if isa(msg.details,'message')
                            exception=exception.addCause(MSLException([],msg.details));

                        elseif isa(msg.details,'MException')
                            exception=exception.addCause(msg.details);
                        else
                            exception=exception.addCause(MException(msgId,strrep(msg.details,'\','\\')));
                        end
                    case 'Warning'
                        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>
                        warning(msgId,'%s',msg.details);
                    case 'Info'
                        if self.DisplayInfoMsgs
                            autosar.mm.util.MessageReporter.print(msg.details);
                        end
                    otherwise
                        assert(false,sprintf('Unrecognized message type "%s".',msg.type));
                    end
                end

                switch length(exception.cause)
                case 0

                case 1
                    exception.cause{1}.throw();
                otherwise
                    exception.throw();
                end
            end
        end
    end


    methods(Access=private)

        function msg=tweakMessage(~,msg)
            strs=regexp(msg,' ','split');
            if numel(strs)>1
                msg=[strs{1},' ',strs{2}];
            else
                msg=strs{1};
            end
        end
    end


    methods(Static)

        function show(msgs,nag)
            if nargin<2
                nag=true;
            end
            msgReport=autosar.mm.util.MessageReporter(nag);
            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            msgReport.clear();
            msgStream.clear();
            msgStream.setReporter(msgReport);
            msgStream.setMessages(msgs);
            msgStream.flush();
        end
    end


    methods(Static,Access=public)

        function hyperlinkFile(filename,line)
            matlab.desktop.editor.openAndGoToLine(filename,line);
        end


        function hyperlinkUri(~)
        end


        function select(~)
        end


        function createWarning(msgID,varargin)
            cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>
            MSLDiagnostic(msgID,varargin{:}).reportAsWarning;
        end


        function print(msg)
            matlab.internal.display.printWrapped(msg);
            drawnow;
        end


        function throwException(exceptionObj)
            assert(isa(exceptionObj,'MException'),'Expected an exception object');
            if~autosar.utils.Debug.showStackTrace()
                throwAsCaller(exceptionObj);
            else
                rethrow(exceptionObj);
            end
        end


        function cleanupObj=suppressWarningTrace()

            cleanupObj=[];
            if~autosar.utils.Debug.showStackTrace()
                backtrace_status=warning('query','backtrace');
                if strcmp(backtrace_status.state,'on')
                    cleanupObj=onCleanup(@()warning(backtrace_status));
                    warning('backtrace','off');
                end
            end
        end

    end
end


