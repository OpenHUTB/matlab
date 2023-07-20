function c=listFiles(action)










    persistent PWD_NAME;
    persistent PWD_DOCBOOK_FILES;

    if nargin>0&&strcmpi(action,'-clear')
        PWD_NAME='';
        c=[];

    elseif~strcmpi(pwd,PWD_NAME)||(nargin>0&&strcmpi(action,'-force'))
        PWD_NAME=pwd;
        c=[];

        try

            xmlExt=char(rptgen.internal.output.OutputFormat.getFormat('db').ExtensionDefault);
        catch
            xmlExt='xml';
        end

        pwdXmlFiles=dir(['*.',xmlExt]);

        for i=length(pwdXmlFiles):-1:1
            if strcmpi(pwdXmlFiles(i).name,'rptstylesheets.xml')||...
                strcmpi(pwdXmlFiles(i).name,'rptcomps2.xml')||...
                strcmpi(pwdXmlFiles(i).name,'rptcomps.xml')||...
                strcmpi(pwdXmlFiles(i).name,'demos.xml')||...
                strcmpi(pwdXmlFiles(i).name,'info.xml')

            else
                c=[c,RptgenML.LibraryFile(pwdXmlFiles(i).name,pwd)];
            end
        end
        PWD_DOCBOOK_FILES=c;


        t=timer(...
        'StartDelay',0.01,...
        'TimerFcn',@(t,evt)broadcastEvent(DAStudio.EventDispatcher,'ListChangedEvent',[]),...
        'StopFcn',@(t,evt)delete(t)...
        );
        start(t);
    else
        c=PWD_DOCBOOK_FILES;
    end
