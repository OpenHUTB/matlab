function jmaab_jc_0644











    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0644');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0644_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0644';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:jmaab:jc_0644',@hCheckAlgo),'PostCompile','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0644_tip');
    rec.setLicense({styleguide_license});
    rec.Value=false;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');


    allBlks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',flv.Value,'LookUnderMasks',lum.Value,'type','block');

    if isempty(allBlks)
        return;
    end

    allBlks=mdlAdvObj.filterResultWithExclusion(allBlks);
    allBlks=filterBlocksAtomicSubsystem(allBlks,system,flv.Value,lum.Value);

    flaggedBlocks=false(1,length(allBlks));

    for k=1:length(allBlks)
        currBlock=allBlks{k};

        blockObj=get_param(currBlock,'Object');
        typ=blockObj.BlockType;


        if strcmp(typ,'DataTypeConversion')
            continue;
        end




        if strcmp(typ,'Outport')



            ph=get_param(currBlock,'PortHandles');
            signal_name=get_param(ph.Inport,'Name');
            block_pc=get_param(currBlock,'PortConnectivity');
            src_ph=get_param(block_pc.SrcBlock,'PortHandles');
            src_outports=src_ph.Outport;
            for j=1:length(src_outports)
                if strcmpi(get_param(src_outports(j),'Name'),signal_name)
                    flag=strcmp(get_param(src_outports(j),'MustResolveToSignalObject'),'on');
                    break;
                end
            end
            if flag&&checkBlockType(blockObj)
                flaggedBlocks(k)=true;
            end
        else

            portHandles=get_param(currBlock,'PortHandles');
            outports=portHandles.Outport;

            for j=1:length(outports)
                currOutport=outports(j);
                mrtso=get_param(currOutport,'MustResolveToSignalObject');
                if~strcmp(mrtso,'on')

                    continue;
                end
                if checkBlockType(blockObj)
                    flaggedBlocks(k)=true;
                end
            end
        end
    end

    FailingObjs=allBlks(flaggedBlocks);
end

function str=defaultExpectedOutDataTypeStr(blockType)

    switch blockType
    case{'Inport','Outport'}
        str='Inherit: auto';
    otherwise
        str='Inherit: Inherit via back propagation';
    end
end




function allBlks=filterBlocksAtomicSubsystem(allBlks,system,flv,lum)


    atomicSubSystems=find_system(system,'FollowLinks',flv,'LookUnderMasks',lum,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','SubSystem','TreatAsAtomicUnit','on');
    blocksInAtomicSubsystems=[];
    for k=1:length(atomicSubSystems)


        blks=find_system(atomicSubSystems{k},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',flv,'LookUnderMasks',lum,'type','block');
        blocksInAtomicSubsystems=[blocksInAtomicSubsystems;blks];%#okagrow    
    end
    allBlks=setdiff(allBlks,blocksInAtomicSubsystems);
end

function status=checkBlockType(blockObj)
    status=false;
    if isprop(blockObj,'OutDataTypeStr')
        outDataTypeStr=blockObj.OutDataTypeStr;
        status=true;

        if strcmp(outDataTypeStr,'double')||...
            strcmp(outDataTypeStr,'boolean')||...
            contains(outDataTypeStr,'fixdt','IgnoreCase',true)||...
            strcmp(outDataTypeStr,defaultExpectedOutDataTypeStr(blockObj.BlockType))||...
            startsWith(outDataTypeStr,'Bus:')
            status=false;
        end
    end
end