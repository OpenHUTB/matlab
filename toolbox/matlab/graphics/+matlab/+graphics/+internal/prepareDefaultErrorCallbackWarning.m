function[id,msg]=prepareDefaultErrorCallbackWarning(evt)



    k=evt.Error;
    a=k.Cause;

    if(~isempty(a)&&strcmp(a.ID,'MATLAB:handle_graphics:exceptions:Property'))
        [id,msg]=preparePropertyWarning(k,a);
    else
        [id,msg]=perpareOtherWarning(evt,k);
    end
end

function[id,msg]=preparePropertyWarning(k,a)
    if(isprop(k,'Object'))
        objectType=class(k.Object);
        simpleObjectType=simpleName(objectType);
        id=a.ID;
        if(isprop(a,'Properties'))
            m=size(a.Properties,2);
            causeMsg=' ';
            c=a.Cause;
            if(~isempty(c))
                causeMsg=c.Message;
                id=c.ID;
            end
            if(m==1)
                s=getPropertyText(objectType,a.Properties{1});
                msg=sprintf('%s',getString(message('MATLAB:defaulterrorcallback:ErrorInProperty',simpleObjectType,s,causeMsg)));
            else
                mssg1='';
                for i=1:m
                    s=getPropertyText(objectType,a.Properties{i});
                    mssg1=sprintf('%s%s',mssg1,s);
                end
                mssg=mssg1;
                msg=sprintf('%s',getString(message('MATLAB:defaulterrorcallback:ErrorInMultipleProperties',simpleObjectType,mssg,causeMsg)));
            end
        else
            msg=sprintf('%s',getString(message('MATLAB:defaulterrorcallback:ErrorInProperty',simpleObjectType,' ',' ')));
        end
    else
        id=k.ID;
        msg=k.Message;
    end
end

function[id,msg]=perpareOtherWarning(evt,k)

    if(~isempty(k))
        while(~isempty(k))

            if(strcmp(k.ID,'MATLAB:handle_graphics:exceptions:SceneNode'))
                obj=getvisibileobject(k.Object);
                sn=simpleName(class(obj));
                k.Message=sprintf('%s\n',getString(message('MATLAB:defaulterrorcallback:ErrorUpdating',sn)));
            end
            k=k.Cause;

        end
        msg=prepareWarningMsg(evt.Error.Message,evt.Error.Cause);
        id=evt.Error.ID;
    end

end

function dstmsg=prepareWarningMsg(srcmsg,cause)

    if isempty(cause)
        dstmsg=srcmsg;
    else
        tmpmsg=[srcmsg,'\n ',cause.Message,'\n'];
        dstmsg=prepareWarningMsg(tmpmsg,cause.Cause);

    end
end

function smplname=simpleName(fullName)
    [token,remain]=strtok(fullName,'.');
    while(~isempty(remain))
        [token,remain]=strtok(remain,'.');
    end
    smplname=token;
end

function s=getPropertyText(objectType,propname)
    try
        hasHelp=matlab.internal.doc.reference.propertyHasHelp(objectType,propname);
        if hasHelp
            s=sprintf(' <a href="matlab:matlab.internal.doc.reference.showPropertyHelp(''%s'',''%s'');")">%s</a>',objectType,propname,propname);
        else
            docpage=getPropertyRefPage(objectType,propname);
            if~isempty(docpage)
                s=sprintf(' <a href="matlab:helpview(''%s'');">%s</a>',docpage,propname);
            else
                s=sprintf(' %s',propname);
            end
        end
    catch
        s=sprintf(' %s',propname);
    end
end

function docpage=getPropertyRefPage(objectType,propname)


    simpleclass=regexp(objectType,'[^.]+$','match','once');
    docpage=fullfile(docroot,'matlab','ref',sprintf('%s_props.html',simpleclass));
    docpage=strrep(docpage,'\','/');
    if exist(docpage,'file')
        docpage=sprintf('%s#%s',docpage,propname);
    else
        docpage=[];
    end
end

function obj=getvisibileobject(errorobj)
    obj=errorobj;
    while(0~=obj.Internal&&0==isempty(obj.Parent))
        obj=obj.Parent;
    end
end
