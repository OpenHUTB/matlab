function out=get(this,objH,varargin)

    if length(varargin)==1&&ischar(varargin{1})

        mdlName=objH;
        modelH=get_param(mdlName,'Handle');
        id=varargin{1};
        theObj=Simulink.ID.getHandle([mdlName,id]);
        isSf=isa(theObj,'Stateflow.Object');
        if isSf
            objH=theObj.Id;
            isSigBuilder=false;
        else
            objH=theObj;
            isSigBuilder=rmisl.is_signal_builder_block(objH);
        end
    else
        [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(objH,true);
        [mdlName,id]=rmidata.getRmiKeys(objH,isSf);
        if isempty(mdlName)
            out=[];
            return;
        end
    end

    isStale=false;
    if~rmisl.isHarnessIdString(mdlName)
        if~isSf&&objH~=modelH&&~strcmp(get_param(objH,'Type'),'annotation')&&rmisl.inLibrary(objH,false)
            refPath=get_param(objH,'ReferenceBlock');
            if~isempty(refPath)
                try
                    refH=get_param(refPath,'Handle');
                    out=rmi.getReqs(refH,varargin{:});
                    return;
                catch
                    isStale=true;
                end
            end
        elseif isSf
            [isInLib,libSid]=rmisf.isLibObject(objH,mdlName);
            if isInLib
                [libName,id]=strtok(libSid,':');
                modelH=get_param(libName,'Handle');
            end
        end
    end

    if~isKey(this.statusMap,modelH)
        out=[];
        return;
    end
    if~isempty(varargin)&&~ischar(varargin{1})
        out=this.repository.getData(modelH,sprintf('%s.%d',id,varargin{1}));
    elseif isSigBuilder
        [~,~,allReqs]=this.getSubGroups(objH);
        out=allReqs;
    else
        out=this.repository.getData(modelH,id);
    end
    if~isempty(out)
        if any(strncmp({out.doc},'$ModelName$',length('$ModelName$')))
            out=rmisl.intraLinksResolve(out,modelH);
        end
        if isStale
            for i=1:length(out)
                out(i).description=[out(i).description,' (Stale)'];
            end
        end
    end
end
