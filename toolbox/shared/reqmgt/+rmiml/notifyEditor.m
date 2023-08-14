function notifyEditor(srcName,id,lines)




    if rmisl.isSidString(srcName)
        srcName=mfunctionEditorKey(srcName);

        usingJS=feature('openMLFBInSimulink');
    else
        usingJS=rmiml.enable();
    end



    if usingJS
        messageData.src=srcName;
        messageData.id=id;
        if nargin==3
            messageData.lines=lines;
        end
        message.publish(['/VNV/REQ_',srcName],messageData);
    else
        com.mathworks.toolbox.simulink.slvnv.RmiDataLink.fireUpdateEvent(srcName,id);
    end
end

function srcName=mfunctionEditorKey(srcName)



    mdlName=strtok(srcName,':');
    if rmisl.isComponentHarness(mdlName)
        return;
    end
    harnessInfo=rmisl.componentHarnessMgr('active',mdlName);
    if~isempty(harnessInfo)
        if rmisl.isHarnessIdString(srcName)

            srcName=rmisl.harnessIdToEditorName(srcName);
            return;
        end
        obj=Simulink.ID.getHandle(srcName);
        if isa(obj,'double')
            obj=get_param(obj,'Object');
        end
        sidInHarness=rmisl.componentHarnessMgr('sid',obj);
        if~isempty(sidInHarness)
            srcName=sidInHarness;
        end
    end
end
