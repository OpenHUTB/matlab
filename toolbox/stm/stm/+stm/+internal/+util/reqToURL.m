function[url,label,fPath]=reqToURL(req,ref,useMatlabConnector,linkType)











































    label=req.description;
    if length(label)>100
        label=[label(1:90),'...'];
    elseif isempty(label)
        label=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DocumentAtPosition',req.doc,req.id));
    end




    fPath='';


    if isempty(req.doc)
        warnNoBacktrace(message('Slvnv:rmiut:matlabConnectorOn:UnableToGenerate',label));
        url='';
        return;
    end


    if nargin<3||isempty(useMatlabConnector)
        useMatlabConnector=isSlLinktype(req.reqsys)||rmipref('ReportNavUseMatlab');
    end


    if nargin<4||isempty(linkType)
        if strcmp(req.reqsys,'other')
            linkType=rmi.linktype_mgr('resolveByFileExt',req.doc);
        else
            linkType=rmi.linktype_mgr('resolveByRegName',req.reqsys);
        end
        if isempty(linkType)





            [url,fPath]=fileUrl(req,ref);
            return;
        end
    end

    if useMatlabConnector


        if~isempty(ref)&&~ischar(ref)
            ref=get_param(ref,'Name');
        end
        navCmd=sprintf('rmi.navigate(''%s'',''%s'',''%s'',''%s'');',...
        req.reqsys,req.doc,req.id,ref);
        url=cmdToUrl(navCmd);
    else



        if isSlLinktype(req.reqsys)
            url=feval(linkType.CreateURLFcn,req.doc,ref,req.id);
        else
            switch linkType.Registration
            case 'linktype_rmi_url'
                url=req.doc;
                if~isempty(req.id)
                    id=req.id;
                    if id(1)=='@'
                        url=[url,'#',id(2:end)];
                    elseif id(1)=='#'
                        url=[url,id];
                    else
                        url=[url,'#',id];
                    end
                end
            otherwise
                if linkType.IsFile
                    [url,fPath]=fileUrl(req,ref);
                else
                    warnNoBacktrace(message('Slvnv:rmiut:matlabConnectorOn:UnableToGenerate',req.doc));
                    url=req.doc;
                end
            end
        end
    end
end


function yesno=isSlLinktype(reqsys)
    yesno=any(strcmp(reqsys,{...
    'linktype_rmi_simulink',...
    'linktype_rmi_data',...
    'linktype_rmi_matlab',...
    'linktype_rmi_mupad',...
    'linktype_rmi_doors',...
    'linktype_rmi_testmgr'}));
end

function[url,fPath]=fileUrl(req,ref)
    fPath=rmi.locateFile(req.doc,ref);
    url=pathToUrl(fPath);
    if length(req.id)>1&&req.id(1)=='@'
        url=[url,'#',req.id(2:end)];
    end
end


function url=pathToUrl(filePath)




    if strncmp(filePath,'/',1)
        filePath=strrep(filePath,'\','/');
        url=['file://',filePath];
    elseif strncmp(filePath,'\\',2)
        filePath=strrep(filePath,'\','/');
        url=['file:///',filePath];
    elseif~isempty(regexpi(filePath,'^[a-z]:'))
        filePath=strrep(filePath,'\','/');
        url=['file://',filePath];
    else
        filePath=strrep(filePath,'\',filesep);
        filePath=strrep(filePath,'/',filesep);
        fullPath=[pwd,filesep,filePath];
        filePath=rmiut.simplifypath(fullPath,filesep);
        url=pathToUrl(filePath);
        return;
    end


    url=strrep(url,'%','%25');
    url=strrep(url,'?','%3F');
    url=strrep(url,'#','%23');
    url=strrep(url,' ','%20');

end

function warnNoBacktrace(myMessage)
    s=warning('off','backtrace');
    warning(myMessage);
    warning(s.state,'backtrace');
end



function url=cmdToUrl(cmd)

    leftParenths=strfind(cmd,'(');
    firstLeftParenth=leftParenths(1);
    rightParenths=strfind(cmd,')');
    lastRightParenth=rightParenths(end);
    command=cmd(1:firstLeftParenth-1);
    args=cmd(firstLeftParenth+1:lastRightParenth-1);
    argsQuoted=strrep(args,'''','"');
    argsEscaped=strrep(argsQuoted,'\','\\');


    connector.ensureServiceOn;
    url=mls.internal.generateUrl(['/matlab/feval/',command],['arguments=[',argsEscaped,']']);
end

