

























function[numObsvFunc,ObsvFuncs,numCondFunc,CondFuncs,testcomp]=getBlockCustomizationFunctions(blockH,testcomp)

    numObsvFunc=0;
    ObsvFuncs={};
    numCondFunc=0;
    CondFuncs={};


    if isempty(testcomp.EmlCustomizations)
        obj=Sldv.EMLCustomizations(testcomp);%#ok<*NASGU>
    end

    customization=testcomp.EmlCustomizations;


    [blockType,subSystemType]=sldvprivate('get_sldv_blockType',blockH);
    if~isempty(subSystemType)
        blockType=subSystemType;
    end

    analysisMode=testcomp.activeSettings.Mode;


    getBlockConditionFunctions;





    if~strcmp(analysisMode,'TestGeneration')||...
        ~Sldv.utils.isPathBasedTestGeneration(testcomp.activeSettings)||...
        sldvprivate('areBlockInputsBusType',blockH)

        return;
    end


    if isKey(customization.ObservabilityBlockMap,blockH)
        ObsvFuncs=customization.ObservabilityBlockMap(blockH);
    elseif isKey(customization.ObservabilityTypeMap,blockType)&&~isInsideForEachSS(blockH)

        ObsvFuncs=customization.ObservabilityTypeMap(blockType);
    end

    if~isSupportedBlock(blockH)


        ObsvFuncs={};
    end

    numObsvFunc=length(ObsvFuncs);

    function getBlockConditionFunctions
        if isKey(customization.BlockConditionMap,[blockType,analysisMode])
            CondFuncs=customization.BlockConditionMap([blockType,analysisMode]);
            numCondFunc=length(CondFuncs);
        end
    end
end

function support=isSupportedBlock(blockH)





    blockType=get_param(blockH,'BlockType');
    support=true;
    switch blockType
    case 'Product'
        if(numInputs(blockH)==1)
            support=false;
        end
        multiplicationType=get_param(blockH,'Multiplication');
        if~strcmp(multiplicationType,'Element-wise(.*)')
            support=false;
        end
    case 'Sum'
        if(numInputs(blockH)==1)
            support=false;
        end
    case 'Gain'
        multiplicationType=get_param_block(blockH,'Multiplication');
        if~strcmp(multiplicationType,'Element-wise(K.*u)')
            support=false;
        end
    end

end

function numInp=numInputs(blockH)
    pHs=get_param(blockH,'PortHandles');

    numInp=length(pHs.Inport);
end

function out=isInsideForEachSS(blockH)
    out=false;
    try
        currParent=get_param(blockH,'Parent');
        while~isempty(currParent)
            parentH=get_param(currParent,'handle');
            ss=Simulink.SubsystemType(parentH);
            if ss.isForEachSubsystem()
                out=true;
                return;
            end
            currParent=get_param(parentH,'Parent');
        end
    catch Mex

    end
end
