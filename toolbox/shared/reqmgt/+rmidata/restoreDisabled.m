function[fromExt,toExt]=restoreDisabled(objH)
    srcSID=get_param(objH,'BlockCopiedFrom');
    if isempty(srcSID)
        fromExt=false;
    else
        srcMdl=strtok(srcSID,':');
        if rmidata.isExternal(srcMdl)
            fromExt=true;
        else
            fromExt=false;
        end
    end

    modelH=get_param(bdroot(objH),'Handle');
    toExt=rmidata.isExternal(modelH);

    if fromExt||toExt

        dstObj=get_param(objH,'Object');

        if fromExt
            srcH=Simulink.ID.getHandle(srcSID);
            srcObj=get_param(srcH,'Object');
            srcFullName=srcObj.getFullName();
            dstFullName=dstObj.getFullName();
        else
            srcObjSID='';
        end
        slObjs=find(dstObj,'-isa','Simulink.Block');
        for i=2:length(slObjs)
            slObj=slObjs(i);
            if isa(slObj,"Simulink.Reference")
                slObj=get_param(slObj.Handle,'object');
            end
            if fromExt
                try
                    srcObjSID=getSrcSidForObj(slObj,dstFullName,srcFullName);
                    if rmisl.inSubsystemReference(srcObjSID)

                        continue;
                    end
                catch Mex %#ok<NASGU>

                    continue;
                end
            end
            rmidata.copyDisabled(slObj.Handle,modelH,false,srcObjSID,slObj.isLinked);
        end
        if~(isa(dstObj,'Simulink.SubSystem')&&strcmp(dstObj.SFBlockType,'Chart'))
            sfFilter=rmisf.sfisa('isaFilter');
            sfObjs=find(dstObj,sfFilter(3:end));
            for i=1:length(sfObjs)
                sfObj=sfObjs(i);
                if isa(sfObj,'Stateflow.EMChart')
                    srcSID=get_param(sfObj.Path,'BlockCopiedFrom');
                    destSID=Simulink.ID.getSID(sfObj);
                    rmidata.duplicateMLFB(srcSID,destSID,true);
                    continue;
                end
                if fromExt
                    try
                        srcObjSID=getSrcSidForObj(sfObj,dstFullName,srcFullName);
                    catch Mex %#ok<NASGU>

                        continue;
                    end
                end
                rmidata.copyDisabled(sfObj.Id,modelH,true,srcObjSID,false);
            end
        end
    end
end


function srcSid=getSrcSidForObj(obj,dstFullName,srcFullName)
    dstObjFullName=obj.getFullName();
    srcObjFullName=strrep(dstObjFullName,dstFullName,srcFullName);
    srcSid=Simulink.ID.getSID(srcObjFullName);
end


