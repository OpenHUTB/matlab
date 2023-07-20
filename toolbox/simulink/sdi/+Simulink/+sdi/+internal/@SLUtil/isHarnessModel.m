function out=isHarnessModel(harnessModel)




    out=false;

    tmp=Simulink.SimulationData.ModelCloseUtil;
    load_system(harnessModel);
    modelH=get_param(harnessModel,'handle');

    if isSldvGenHarness(modelH)
        out=true;
    else
        sigBlockH=sigbuild_handle(modelH);
        if~isempty(sigBlockH)
            sigBportHandles=get_param(sigBlockH,'PortHandles');
            try
                lineH=get_param(sigBportHandles.Outport(1),'Line');
                convBlock=get_param(get_param(lineH,'DstPortHandle'),'Parent');
                convBlockH=Sldv.utils.getObjH(convBlock);
            catch me %#ok<NASGU>
                convBlockH=[];
            end
            if~isempty(convBlockH)
                convPortHandles=get_param(convBlockH,'PortHandles');
                try
                    lineH=get_param(convPortHandles.Outport(1),'Line');
                    testUnitBlock=get_param(get_param(lineH,'DstPortHandle'),'Parent');
                    testUnitBlockH=getObjH(testUnitBlock);
                catch me %#ok<NASGU>
                    testUnitBlockH=[];
                end
                if~isempty(testUnitBlockH)
                    out=true;
                end
            end
        end
    end

    delete(tmp);
end


function[sigbH,errStr]=sigbuild_handle(modelH)
    errStr='';
    sigbH=find_system(modelH,...
    'SearchDepth',1,...
    'LoadFullyIfNeeded','off',...
    'FollowLinks','off',...
    'LookUnderMasks','all',...
    'BlockType','SubSystem',...
    'PreSaveFcn','sigbuilder_block(''preSave'');');
    if isempty(sigbH)||length(sigbH)~=1
        sigbH=[];
    end
end

function status=isSldvGenHarness(modelH)
    try
        get_param(modelH,'SldvGeneratedHarnessModel');
        status=true;
    catch me %#ok<NASGU>
        status=false;
    end
end

function[objH,errStr]=getObjH(obj,checkSFOptions)
    if nargin<2
        checkSFOptions=false;
    end

    errStr='';
    objH=[];
    if ischar(obj)
        [objH,errStr]=getHandle(obj);
    else
        if ishandle(obj)
            if checkSFOptions
                if isa(obj,'Stateflow.Chart')
                    [objH,errStr]=getHandle(obj.Path);
                elseif isa(obj,'Stateflow.AtomicSubchart')
                    objH=sf('get',obj.Id,'.simulink.blockHandle');
                elseif isa(obj,'double')
                    [objH,errStr]=getHandle(obj);
                end
            else
                [objH,errStr]=getHandle(obj);
            end
        else
            errStr='Invalid object';
        end
    end
end

function[objH,errStr]=getHandle(obj)
    errStr='';
    objH=[];
    try
        objH=get_param(obj,'Handle');
    catch Mex
        errStr=Mex.message;
    end
end