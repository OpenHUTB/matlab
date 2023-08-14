function[objH,refSid,isStale]=slGetSource(isSf,objH)














    isStale=false;
    refSid='';




    tFlags=slreq.internal.TempFlags.getInstance;
    isRedirectingLibObj=tFlags.get('IsRedirectingLibObj');
    if isRedirectingLibObj&&~isSf&&objH~=bdroot(objH)&&~strcmp(get_param(objH,'Type'),'annotation')...
        &&~strcmp(get_param(objH,'Type'),'port')&&isFromLibrary(objH)
        refPath=get_param(objH,'ReferenceBlock');
        if~isempty(refPath)
            try
                refSid=Simulink.ID.getSID(refPath);
                objH=get_param(refPath,'Handle');
            catch ME %#ok<NASGU>




                isStale=true;
            end
        end
    else

        refSid=rmisl.getRefSidFromObjSSRefInstance(objH,isSf);
        if~isempty(refSid)
            try
                objH=Simulink.ID.getHandle(refSid);
            catch ex %#ok<NASGU> 
                isStale=true;
            end
        elseif isSf

            if isa(objH,'double')
                slsfr=sfroot;
                sfObj=slsfr.idToHandle(objH);
            else
                sfObj=objH;
            end
            if isempty(sfObj)




                objH=[];
                isStale=true;
                return;
            end
            parentDiagram=strtok(Simulink.ID.getSID(sfObj),':');
            if~strcmp(parentDiagram,strtok(sfObj.Path,'/'))
                try
                    refSid=Simulink.ID.getStateflowSID(sfObj);
                catch ex %#ok<NASGU>
                    isStale=true;
                end
            end
        end
    end



end

function tf=isFromLibrary(objH)
    status=get_param(objH,'StaticLinkStatus');
    if strcmp(status,'implicit')
        tf=isParentResolved(objH);
    else
        tf=false;
    end
end


function out=isParentResolved(slH)

    parent=get_param(slH,'Parent');
    if strcmpi(get_param(parent,'type'),'block_diagram')
        out=false;
    else
        parentStatus=get_param(parent,'StaticLinkStatus');
        if any(strcmpi(parentStatus,{'resolved'}))
            out=true;
        else
            out=isParentResolved(parent);
        end
    end
end
