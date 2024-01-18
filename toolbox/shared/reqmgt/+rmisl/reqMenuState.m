function out=reqMenuState(callbackInfo,isSys)
    if~any(strcmp(callbackInfo.model.BlockDiagramType,{'model','library','subsystem'}))
        out='Hidden';
        return;
    end

    objh=getObj(isSys,callbackInfo);

    if rmisl.isComponentHarness(callbackInfo.model.Name)
        if length(objh)~=1
            out='Disabled';
            return;
        end
        systemBD=Simulink.harness.internal.getHarnessOwnerBD(callbackInfo.model.Name);
        if~Simulink.harness.internal.isReqLinkingSupportedForExtHarness(systemBD)
            out='Disabled';
            return;
        end
        if~isempty(which('Simulink.harness.internal.sidmap.isHarnessAutoGenBlock'))...
            &&Simulink.harness.internal.sidmap.isHarnessAutoGenBlock(callbackInfo.model.Name,objh)
            out='Disabled';
            return;
        end
        if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(objh)
            try
                objh=rmisl.harnessToModelRemap(objh);
            catch Mex
                if strcmp(Mex.identifier,'Simulink:utility:invalidSID')

                    out='Disabled';
                    return;
                else
                    rethrow(Mex);
                end
            end
        end
    elseif objectIsOpenedInActiveHarness(callbackInfo.model.Name,objh)
        out='Disabled';
        return;
    end

    [installed,licensed]=rmi.isInstalled();
    if installed&&licensed
        if~isSys&&isempty(vectorSelection(callbackInfo.getSelection))
            out='Hidden';
        else
            out='Enabled';
        end
        return;
    end

    if length(objh)~=1
        out='Disabled';
    elseif rmi.objHasReqs(objh)
        out='Enabled';
    else
        out='Disabled';
    end

end


function objh=getObj(isSys,callbackInfo)
    if isSys
        objh=cbUiObject(callbackInfo);
    else
        objh=cbSelection(callbackInfo);
        if isempty(objh)
            objh=cbUiObject(callbackInfo);
        end
    end
end


function objh=cbSelection(callbackInfo)
    objh=callbackInfo.getSelection;
    if isempty(objh)
        objh=find(cbUiObject(callbackInfo),'-isa','Simulink.Line','-and','Selected','on');%#ok<*GTARG>
    end
end


function objh=cbUiObject(callbackInfo)
    objh=callbackInfo.uiObject;
    if isa(objh,'DAStudio.WSOAdapter')
        objh=objh.getVariable;
    end
end


function obj=vectorSelection(select)
    row=size(select,1);
    obj=[];
    for i=1:row
        [~,objH,errMsg]=rmi.resolveobj(select(i));
        if isempty(errMsg)&&~isempty(objH)
            obj(end+1)=objH;%#ok<AGROW>
        end
    end
end


function yesno=objectIsOpenedInActiveHarness(modelName,objh)
    modelH=get_param(modelName,'Handle');
    if Simulink.harness.internal.hasActiveHarness(modelH)
        harnessInfo=Simulink.harness.internal.getActiveHarness(modelH);
        if isempty(harnessInfo)
            yesno=false;
        else
            for i=1:length(objh)
                yesno=~isempty(Simulink.harness.internal.sidmap.getOwnerObjectSIDInHarness(objh(i)));
                if yesno
                    return;
                end
            end
        end
    else
        yesno=false;
    end
end

