function[tag,status]=hdlgetblocklibpath(block)













    persistent MATLABSystemCache;

    obj=get_param(block,'object');
    tag='';
    status=0;

    try
        switch(obj.blockType)
        case{'SubSystem','S-Function','M-S-Function'}
            if strcmpi(obj.BlockType,'SubSystem')&&...
                ~strcmpi('NONE',obj.SFBlockType)
                tag=getStateflowBlockType(block,obj);
            elseif strcmpi(obj.LinkStatus,'resolved')
                tag=obj.ReferenceBlock;
                if strcmp(tag,'slpidlib/PID Controller')
                    tag='simulink/Discrete/Discrete PID Controller';
                elseif strcmp(tag,['nesl_utility/Solver',char(10),'Configuration'])
                    tag='nesl_utility/SolverConfiguration';
                end
            elseif~isempty(obj.getParent)&&obj.getParent.isLibrary
                tag=obj.getFullName;
            elseif strcmp(obj.blockType,'SubSystem')
                maskType=get_param(block,'MaskType');
                if strcmpi(maskType,'VerificationSubsystem')
                    tag='sldvlib/Verification Subsystem';
                else
                    tag='built-in/SubSystem';
                end
            else
                status=1;
            end
        case 'MATLABSystem'




            if strcmpi(obj.LinkStatus,'resolved')
                tag=obj.ReferenceBlock;
            elseif obj.getParent.isLibrary
                tag=obj.getFullName;
            else
                if isempty(MATLABSystemCache)
                    MATLABSystemCache=hdlgetmatlabsystemmap;
                end
                key=get(obj,'System');
                if isKey(MATLABSystemCache,key)
                    tag=MATLABSystemCache(key);
                else
                    sysObjImplMap=lowersysobj.getSysObjImplMap;
                    if isKey(sysObjImplMap,key)


                        tag=key;
                    else
                        tag='built-in/MATLABSystem';
                    end
                end
            end
        case 'MessageViewer'
            tag=getStateflowBlockType(block,obj);
        case 'InportShadow'
            tag='built-in/Inport';
        case 'SimscapeBlock'
            tag=obj.ReferenceBlock;
        otherwise

            tag=['built-in/',obj.BlockType];
        end
    catch me %#ok<NASGU>
        status=1;
    end
end

function type=getStateflowBlockType(blockPath,obj)


    switch(obj.blockType)
    case{'MessageViewer'}
        type='sflib/Sequence Viewer';
    case{'SubSystem','S-Function','M-S-Function'}

        chartId=sfprivate('block2chart',blockPath);
        if Stateflow.STT.StateEventTableMan.isStateEventTableChart(chartId)

            if sfprivate('is_reactive_testing_table_chart',chartId)
                type='sltestlib/Test Sequence';
            else
                type='sflib/State Transition Table';
            end
        elseif(Stateflow.MALUtils.isMalChart(chartId))
            type='sflib/Chart';
        elseif sfprivate('is_sf_chart',chartId)
            type='sflib/Chart';
        elseif sfprivate('is_truth_table_chart',chartId)
            type='sflib/Truth Table';
        elseif sfprivate('is_eml_chart',chartId)
            type='eml_lib/MATLAB Function';
        else
            type='';
        end
    end

end
