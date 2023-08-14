function jmaab_jc_0171




    rec=Advisor.Utils...
    .getDefaultCheckObject...
    ('mathworks.jmaab.jc_0171',false,@hCheckAlgo,'PostCompile');


    rec.setInputParametersLayoutGrid([5,4]);
    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0171_a: ',DAStudio.message('ModelAdvisor:jmaab:jc_0171_a_subtitle')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=['jc_0171_b: ',DAStudio.message('ModelAdvisor:jmaab:jc_0171_b_subtitle')];
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name='Conditional Executed Subsystems';
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name='Variant Subsystems';
    inputParamList{end}.Type='bool';
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,4];
    inputParamList{end}.Visible=false;
    inputParamList{end}.Enable=true;
    inputParamList{end}.Value=true;

    rowSpan=inputParamList{end}.RowSpan+1;
    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=rowSpan;
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);

    rec.setLicense({styleguide_license});

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_jmaab_group,sg_maab_group});

end




function[resultData]=hCheckAlgo(system)

    resultData=[];
    entities_condiexecsubsys={};Variant_subsys={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    inputParams=mdladvObj.getInputParameters;

    duplicateFilter=[];

    subCheckAFlag=false;
    subCheckBFlag=false;

    if inputParams{1}.Value
        subCheckAFlag=true;
    end

    if inputParams{2}.Value
        subCheckBFlag=true;
    end



    entities=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',inputParams{5}.Value,...
    'LookUnderMasks',inputParams{6}.Value,...
    'regexp','on',...
    'BlockType','(From)|(SubSystem)|(ModelReference)');

    entities=mdladvObj.filterResultWithExclusion(entities);

    if isempty(entities)
        return;
    end


    if~inputParams{3}.Value


        condiexec_subsys=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{5}.Value,'LookUnderMasks',inputParams{6}.Value,'regexp','on','BlockType','(TriggerPort)|(EnablePort)|(ActionPort)');
        for i=1:length(condiexec_subsys)
            entities_condiexecsubsys{end+1}=get_param(condiexec_subsys{i},'Parent');
        end
    end

    if~inputParams{4}.Value


        Variant_subsys=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{5}.Value,'LookUnderMasks',inputParams{6}.Value,'BlockType','SubSystem','Variant','on');
    end

    for blkCount=1:length(entities)


        if subCheckBFlag

            if contains(entities{blkCount},entities_condiexecsubsys)||contains(entities{blkCount},Variant_subsys)
                subsystem=[];
            else
                subsystem=subCheckB(entities{blkCount});
            end

            if~isempty(subsystem)

                vObj=ModelAdvisor.ResultDetail;
                vObj.Title=DAStudio.message...
                ('ModelAdvisor:jmaab:jc_0171_b_subtitle');
                vObj.Status=DAStudio.message...
                ('ModelAdvisor:jmaab:jc_0171_b_warn');
                vObj.RecAction=DAStudio.message...
                ('ModelAdvisor:jmaab:jc_0171_b_rec_action');
                ModelAdvisor.ResultDetail.setData(vObj,'SID',subsystem);
                resultData=[resultData;vObj];

            end
        end


        if subCheckAFlag

            subSystemPair=subCheckA(entities{blkCount});

            if isempty(subSystemPair)
                continue;
            end

            for pairCount=1:size(subSystemPair,1)






                srcID=Simulink.ID.getSID(subSystemPair{pairCount,1});
                dstID=Simulink.ID.getSID(subSystemPair{pairCount,2});






                subSystemPairID=[dstID,srcID];


                if any(ismember(subSystemPairID,duplicateFilter))
                    continue;
                end

                duplicateFilter=[duplicateFilter,{subSystemPairID}];


                vObj=ModelAdvisor.ResultDetail;
                vObj.Title=DAStudio.message...
                ('ModelAdvisor:jmaab:jc_0171_a_subtitle');
                vObj.Status=DAStudio.message...
                ('ModelAdvisor:jmaab:jc_0171_a_warn');
                vObj.RecAction=DAStudio.message...
                ('ModelAdvisor:jmaab:jc_0171_a_rec_action');


                ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
                DAStudio.message('ModelAdvisor:jmaab:jc_0171_col1'),...
                subSystemPair{pairCount,1},...
                DAStudio.message('ModelAdvisor:jmaab:jc_0171_col2'),...
                subSystemPair{pairCount,2});

                resultData=[resultData;vObj];

            end
        end
    end

end



function vPair=subCheckA(blk)




    vPair=[];

    fromObj=get_param(blk,'Object');


    if~strcmp('From',fromObj.BlockType)
        return;
    end



    gotoBOjStruct=fromObj.GotoBlock;

    if isempty(gotoBOjStruct.handle)
        return;
    end

    gotoBObj=get_param(gotoBOjStruct.handle,'Object');






    if~strcmp('local',gotoBObj.TagVisibility)
        return;
    end


    gotoSrcObj=getGraphicalSrcObj(gotoBObj,'');


    fromDstObj=getGraphicalDstObj(fromObj);





    if(~isa(gotoSrcObj,'Simulink.SubSystem')&&...
        ~isa(gotoSrcObj,'Simulink.ModelReference'))||...
        isempty(gotoSrcObj)||...
        isempty(fromDstObj)

        return;

    end






    for dstCount=1:numel(fromDstObj)


        if~isa(fromDstObj{dstCount},'Simulink.SubSystem')&&...
            ~isa(fromDstObj{dstCount},'Simulink.ModelReference')
            return;
        end

        srcID=Simulink.ID.getSID(gotoSrcObj);




        for c2=1:numel(fromDstObj{dstCount}.PortHandles.Inport)

            inPortBlk=fromDstObj{dstCount}.PortHandles.Inport(c2);

            if isempty(inPortBlk)
                continue;
            end

            inPortBlkObj=get_param(inPortBlk,'Object');

            targetSrcObj=getGraphicalSrcObj(inPortBlkObj,'');



            if(~isa(targetSrcObj,'Simulink.SubSystem')&&...
                ~isa(targetSrcObj,'Simulink.ModelReference'))||...
                isempty(targetSrcObj)
                continue;
            end

            targeSrctID=Simulink.ID.getSID(targetSrcObj);





            if strcmp(targeSrctID,srcID)
                return;
            end


        end

    end



    vPair=[vPair;[{gotoSrcObj},{fromDstObj{dstCount}}]];

end


function vObj=subCheckB(blk)


    vObj=[];

    subsystemObj=get_param(blk,'Object');


    if~strcmp('SubSystem',subsystemObj.BlockType)
        return;
    end


    if~subsystemObj.IsSubsystemVirtual
        return;
    end


    inport=find_system(subsystemObj.handle,'SearchDepth','1',...
    'FollowLinks','on',...
    'LookUnderMasks','on',...
    'BlockType','Inport');


    if isempty(inport)
        return;
    end




    for inCount=1:length(inport)


        inBlk=get_param(inport(inCount),'Object');
        targetBlk=inBlk.getGraphicalDst();


        if isempty(targetBlk)
            continue;
        end

        for tarBlkCount=1:length(targetBlk)




            parentBlk=get_param(targetBlk(tarBlkCount),'Parent');




            try
                parentBlk=get_param(parentBlk,'Object');
            catch ME
                if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                    continue;
                else
                    rethrow(ME);
                end
            end





            if strcmp(parentBlk.BlockType,'Outport')||...
                strcmp(parentBlk.BlockType,'Terminator')
                vObj=subsystemObj;
                return;
            end


            if~strcmp(parentBlk.BlockType,'Goto')
                continue;
            end


            dstBlks=traverseGotoBlock(parentBlk);

            for blkCount=1:numel(dstBlks)

                blk=get_param(dstBlks(blkCount),'Object');
                blk=get_param(blk.Parent,'Object');



                if strcmp(blk.BlockType,'Outport')||...
                    strcmp(blk.BlockType,'Terminator')
                    vObj=subsystemObj;
                    return;
                end

            end
        end
    end
end

function dstBlks=traverseGotoBlock(gotoBlock)
    dstBlks=[];
    fromBlk=gotoBlock.FromBlocks;

    if isempty(fromBlk)
        return;
    end


    fromBlk=get_param([fromBlk.handle],'Object');



    if~iscell(fromBlk)
        fromBlk={fromBlk};
    end

    dstBlks=cell2mat(cellfun(@(x)x.getGraphicalDst,fromBlk,'UniformOutput',false));

    maxBlock=numel(dstBlks);

    for blkCount=1:maxBlock

        currBlk=get_param(dstBlks(blkCount),'Object');




        try
            currBlk=get_param(currBlk.Parent,'Object');
        catch ME
            if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                continue;
            else
                rethrow(ME);
            end
        end


        if~strcmp('Goto',currBlk.BlockType)
            continue;
        end

        newBlock=traverseGotoBlock(currBlk);

        if numel(newBlock)>1
            dstBlks(blkCount)=newBlock(1);
            dstBlks=[stBlks,newBlock];
        else
            dstBlks(blkCount)=newBlock;
        end

    end

end
function srcPortHandles=getSrcPorts(obj)
    srcPortHandles=[];
    if isa(obj,'Simulink.Port')
        if ishandle(obj.Line)
            lineObj=get_param(obj.Line,'Object');
            if ishandle(lineObj.SrcPortHandle)
                srcPortHandles=lineObj.SrcPortHandle;
            end
        end
        return;
    else

        inports=obj.PortHandles.Inport;

        for i=1:numel(inports)
            inportObj=get_param(inports(i),'Object');

            if ishandle(inportObj.Line)
                lineObj=get_param(inportObj.Line,'Object');
                if ishandle(lineObj)
                    srcPortHandles=[srcPortHandles;lineObj.SrcPortHandle];
                end
            end
        end
    end
end
function srcObj=getGraphicalSrcObj(obj,nameList)












    srcObj=[];
    if isempty(obj)
        return
    end

    srcPort=getSrcPorts(obj);
    if isempty(srcPort)||(-1==srcPort)
        return;
    end
    portNumber=get_param(srcPort,'PortNumber');
    srcObj=get_param(get_param(srcPort,'Parent'),'Object');




    if isa(srcObj,'Simulink.BusSelector')||...
        isa(srcObj,'Simulink.Demux')

        srcPort=getSrcPorts(srcObj);
        if isempty(srcPort)
            return;
        end
        srcObj=get_param(get_param(srcPort,'Parent'),'Object');





        if~isa(srcObj,'Simulink.BusCreator')&&...
            ~isa(srcObj,'Simulink.Mux')

            return;

        end
        srcPort=getSrcPorts(srcObj);
        if numel(srcPort)<portNumber
            return;
        end
        srcObj=get_param(get_param(srcPort(portNumber),'Parent'),'Object');

    end


    if(isa(srcObj,'Simulink.Memory')||...
        isa(srcObj,'Simulink.Delay')||...
        isa(srcObj,'Simulink.UnitDelay')||...
        isa(srcObj,'Simulink.BusSelector')||...
        isa(srcObj,'Simulink.Demux'))&&...
        ~any(strcmp(nameList,Simulink.ID.getSID(srcObj)))






        nameList=[nameList,{Simulink.ID.getSID(srcObj)}];
        srcObj=getGraphicalSrcObj(srcObj,nameList);
    else
        return;
    end
end


function dstObjs=getGraphicalDstObj(obj)











    if isempty(obj)
        dstObjs={};
        return
    end




    if isa(obj,'Simulink.From')
        dstPort=obj.getGraphicalDst();





        try
            parentBlk=get_param(dstPort,'Parent');
        catch ME
            if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                return;
            else
                rethrow(ME);
            end
        end


        dstObjs=get_param(parentBlk,'Object');
    else
        dstObjs={obj};
    end


    maxCount=numel(dstObjs);

    if maxCount==1
        dstObjs={dstObjs};
    end

    for objCount=1:maxCount

        dstObj=dstObjs{objCount};



        if dstObj.isSynthesized
            orgBlock=dstObj.getOriginalBlock;
            if~isempty(orgBlock)
                dstObj=get_param(orgBlock,'Object');
            end
        end






        if~isa(dstObj,'Simulink.BusCreator')&&...
            ~isa(dstObj,'Simulink.Mux')
            dstObjs{objCount}=dstObj;
            continue;

        end

        dstPort=dstObj.getGraphicalDst();





        try
            parentBlk=get_param(dstPort,'Parent');
        catch ME
            if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')
                continue;
            else
                rethrow(ME);
            end
        end


        dstObj=get_param(parentBlk,'Object');


        if~iscell(dstObj(1))
            dstObj={dstObj};
        end



        for dstCount=1:numel(dstObj)





            if~isa(dstObj{dstCount},'Simulink.BusSelector')&&...
                ~isa(dstObj{dstCount},'Simulink.Demux')

                dstObjs{objCount}=dstObj{dstCount};

                continue;

            end

            dstPorts=dstObj{dstCount}.PortHandles.Outport;

            for pCount=1:numel(dstPorts)
                dstPort=get_param(dstPorts(pCount),'Object');

                dstPort=get_param...
                (get_param(dstPort.getGraphicalDst(),'Parent'),'Object');

                if isa(dstPort,'Simulink.Memory')||...
                    isa(dstPort,'Simulink.Delay')||...
                    isa(dstPort,'Simulink.UnitDelay')||...
                    isa(dstPort,'Simulink.BusCreator')||...
                    isa(dstPort,'Simulink.Mux')

                    dstPort=getGraphicalDstObj(dstPort);

                end







                if numel(dstPort)>1
                    dstObjs{objCount}=dstPortj{1};
                    dstObjs=[dstObjs,dstPort{2:end}];
                else
                    dstObjs{objCount}=dstPort;
                end

            end
        end
    end
end
