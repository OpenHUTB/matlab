function req=makeReq(srcName,id,label)




    req=rmi.createEmptyReqs(1);
    req.reqsys='linktype_rmi_matlab';


    if rmisl.isSidString(srcName)



        if rmisl.isComponentHarness(strtok(srcName,':'))
            srcName=rmiml.harnessToModelRemap(srcName);
        end
        req.doc=srcName;
    else
        mdir=fileparts(srcName);
        if isempty(mdir)
            req.doc=srcName;
        elseif strcmp(rmi.settings_mgr('get','linkSettings','modelPathStorage'),'none')
            if~isempty(which(srcName))
                req.doc=rmiut.pathToCmd(srcName);
            else
                req.doc=srcName;
            end
        else
            req.doc=srcName;
        end
    end


    if isa(id,'double')||any(id=='-')



        oldStatus=rmiml.getStatus(srcName);
        [~,id]=rmiml.ensureBookmark(srcName,id);
        if~any(oldStatus=='.')
            newStatus=rmiml.getStatus(srcName);
            if any(newStatus=='.')
                rmiml.notifyEditor(srcName,id);
            end
        end
    end
    req.id=['@',id];


    if nargin==3
        req.description=makeLabel(label);
    else
        text=rmiml.getText(srcName,id);
        req.description=makeLabel(text);
    end
end

function label=makeLabel(text)

    text=rmiut.filterChars(text,false);

    if length(text)>100
        label=[text(1:100),'...'];
    else
        label=text;
    end
end

