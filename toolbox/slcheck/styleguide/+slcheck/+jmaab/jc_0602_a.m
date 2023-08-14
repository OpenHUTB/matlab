classdef jc_0602_a<slcheck.subcheck




    methods
        function obj=jc_0602_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0602_a';
        end

        function result=run(this)

            result=false;
            line=get_param(this.getEntity(),'object');

            if isempty(line)||~ishandle(line.SrcPortHandle)
                return;
            end


            if strcmp(get_param(line.SrcPortHandle,'ShowPropagatedSignals'),'off')
                sHchy=get_param(line.SrcPortHandle,'SignalHierarchy');
                if~isempty(sHchy)
                    lineName=getfield(sHchy,'SignalName');
                else
                    lineName='';
                end
            else
                lineName=get_param(line.SrcPortHandle,'PropagatedSignals');
            end

            if isempty(lineName)
                return;
            end


            in_consistencyTag=this.getInputParamByName(...
            DAStudio.message('ModelAdvisor:jmaab:jc_0602_in_consistency_tag'));
            out_consistencyTag=this.getInputParamByName(...
            DAStudio.message('ModelAdvisor:jmaab:jc_0602_out_consistency_tag'));


            bPrefix=strcmp(this.getInputParamByName(...
            DAStudio.message('ModelAdvisor:jmaab:jc_0602_consistent_naming')),...
            DAStudio.message('ModelAdvisor:jmaab:jc_0602_prefix'));


            srcFailures=analyzeSource(line,lineName,bPrefix,in_consistencyTag);


            destFailures=analyzeDestination(line,lineName,bPrefix,in_consistencyTag,out_consistencyTag);


            if~isempty(destFailures)||~isempty(srcFailures)
                this.setResult([srcFailures;destFailures]);
            end
        end
    end
end





function failures=analyzeSource(line,lineName,bPrefix,consistencyTag)


    failures={};
    elementName='';

    if isempty(line.SrcBlockHandle)||(line.SrcBlockHandle==-1)
        return;
    end


    src=get_param(line.SrcBlockHandle,'object');


    persistent listOfBlocks
    if isempty(listOfBlocks)
        listOfBlocks={'SubSystem','Inport','From'};
    end

    if~ismember(src.BlockType,listOfBlocks)
        return;
    end

    if strcmp(src.BlockType,'SubSystem')
        if~isValidSubsystem(src)
            return;
        end



        srcPort=get_param(line.SrcPortHandle,'PortNumber');
        element=getPortBlock(srcPort,src,'Outport');

        if~isempty(element)
            elementName=element.Name;
        end
    else
        elementName=getElementName(src);
        element=src.Handle;
    end


    if~isConsistentNaming(elementName,lineName,bPrefix,consistencyTag)
        failures=formatResult(element,...
        DAStudio.message('ModelAdvisor:jmaab:jc_0602_signal_name_mismatch',lineName));
    end
end


function failures=analyzeDestination(line,lineName,bPrefix,in_consistencyTag,out_consistencyTag)


    failures={};
    outportBlocks=[];
    inportBlocks=containers.Map;


    destBlks=line.DstBlockHandle;
    destPorts=line.DstPortHandle;


    for idx=1:length(destBlks)
        if~ishandle(destBlks(idx))
            continue;
        end


        current=destBlks(idx);
        dest=get_param(current,'object');

        switch dest.BlockType
        case 'SubSystem'


            [res,inportBlocks]=analyzeSubsystem(current,destBlks,destPorts(idx),inportBlocks,lineName,bPrefix,in_consistencyTag);
            failures=[failures;res];%#ok<AGROW>
        case 'Outport'

            outportBlocks=[outportBlocks,dest];%#ok<AGROW>
        case 'Goto'
            if~strcmp(dest.GotoTag,lineName)
                failures=[failures;formatResult(dest.Handle,...
                DAStudio.message('ModelAdvisor:jmaab:jc_0602_signal_name_mismatch',lineName))];%#ok<AGROW>
            end
        otherwise

        end
    end


    failures=[failures;checkSubsystemPorts(inportBlocks,lineName,bPrefix,in_consistencyTag)];
    failures=[failures;checkPortBlocks(outportBlocks,line,lineName,bPrefix,out_consistencyTag)];

end


function[failures,inportBlocks]=analyzeSubsystem(current,destBlks,destPort,inportBlocks,lineName,bPrefix,consistencyTag)

    failures=[];
    dest=get_param(current,'object');

    if~isValidSubsystem(dest)
        return;
    end

    ssName=getfullname(current);
    element=getPortBlock(get_param(destPort,'PortNumber'),dest,'Inport');


    if isempty(element)
        return;
    end






    if length(destBlks(ismember(destBlks,current)))>1
        if inportBlocks.isKey(ssName)
            inportBlocks(ssName)=[inportBlocks(ssName),element];
        else
            inportBlocks(ssName)=element;
        end
        return;
    end




    if~isConsistentNaming(element.Name,lineName,bPrefix,consistencyTag)
        failures=formatResult(element,...
        DAStudio.message('ModelAdvisor:jmaab:jc_0602_signal_name_mismatch',lineName));
    end
end


function failure=checkSubsystemPorts(ssPorts,lineName,bPrefix,consistencyTag)

    failure=[];
    keys=ssPorts.keys;

    if isempty(keys)
        return;
    end


    for i=1:length(keys)
        value=ssPorts(keys{i});

        res=arrayfun(@(x)isConsistentNaming(x.Name,lineName,bPrefix,consistencyTag),value);

        failure=[failure;arrayfun(@(x)formatResult(x,...
        DAStudio.message('ModelAdvisor:jmaab:jc_0602_inconsistency_message')),...
        value(~res))'];%#ok<AGROW>
    end
end


function failure=checkPortBlocks(portBlocks,line,lineName,bPrefix,consistencyTag)

    failure=[];

    if isempty(portBlocks)
        return;
    end

    len=length(portBlocks);

    if len==1



        if isPassThrough(line)
            if~isConsistentNaming(portBlocks.Name,lineName,bPrefix,consistencyTag)
                failure=formatResult(portBlocks,DAStudio.message('ModelAdvisor:jmaab:jc_0602_inconsistency_message'));
            end
        elseif~strcmp(portBlocks.Name,lineName)
            failure=formatResult(portBlocks,DAStudio.message('ModelAdvisor:jmaab:jc_0602_signal_name_mismatch',lineName));
        else

        end
    elseif len>1

        res=arrayfun(@(x)isConsistentNaming(x.Name,lineName,bPrefix,consistencyTag),portBlocks);
        failure=arrayfun(@(x)formatResult(x,...
        DAStudio.message('ModelAdvisor:jmaab:jc_0602_inconsistency_message')),portBlocks(~res))';
    end
end


function res=isPassThrough(line)
    res=false;


    if~isempty(line.SrcBlockHandle)&&...
        strcmp(get_param(line.SrcBlockHandle,'BlockType'),'Inport')
        res=true;
    end
end


function res=isConsistentNaming(dataName,lineName,bPrefix,consistencyTag)
    if bPrefix
        if strcmp(dataName,lineName)
            res=1;
        else



            res=regexp(dataName,['^',consistencyTag,lineName,'\d*$']);
        end
    else
        if strcmp(dataName,lineName)
            res=1;
        else




            res=regexp(dataName,['^',lineName,'\d*',consistencyTag,'$']);
        end
    end
    res=~isempty(res);
end


function result=formatResult(block,message)
    if isfield(block,'Handle')
        block=block.Handle;
    end


    message=strrep(message,'<','');
    message=strrep(message,'>','');

    result=ModelAdvisor.ResultDetail;
    ModelAdvisor.ResultDetail.setData(result,'SID',block,'Expression',message);
end


function portBlock=getPortBlock(port,subsys,portType)
    portBlock=[];

    if Stateflow.SLUtils.isStateflowBlock(subsys.Handle)

        portBlock=Advisor.Utils.Stateflow.sfFindSys(...
        getfullname(subsys.Handle),...
        'on','all',...
        {'-isa','Stateflow.Data','scope',strrep(portType,'or','u'),'Port',port});

        if isempty(portBlock)
            return;
        end

        portBlock=portBlock{1};
    else

        portBlks=find_system(getfullname(subsys.Handle),'FindAll','on','LookUnderMasks','on','SearchDepth',1,'BlockType',portType);

        if isempty(portBlks)
            return;
        end


        portBlock=get_param(portBlks(port),'object');

    end
end


function name=getElementName(src)
    switch src.BlockType
    case{'Goto','From'}
        name=src.GotoTag;
    otherwise
        name=src.Name;
    end
end


function status=isValidSubsystem(ss)

    status=true;




    ssOutports=length(ss.PortHandles.Outport);
    ssOutportBlk=length(find_system(ss.Handle,'FindAll','on','LookUnderMasks','on','SearchDepth',1,'BlockType','Outport'));
    isConditionalSS=~isempty(find_system(ss.Handle,'SearchDepth',1,...
    'regexp','on',...
    'LookUnderMasks','all',...
    'BlockType','(EnablePort|TriggerPort|ActionPort|ResetPort)'));


    isTruthTable=false;
    chartId=sfprivate('block2chart',ss.Handle);
    if(chartId>0)
        r=slroot();
        chartObj=r.idToHandle(chartId);
        isTruthTable=isa(chartObj,'Stateflow.TruthTableChart');
    end

    if isConditionalSS||...
        (~isempty(ss.ReferenceBlock)||...
        ~isempty(ss.ReferencedSubsystem)||...
        strcmp(ss.RTWSystemCode,'Reusable function'))||...
isTruthTable
        status=false;
    end

    if status&&(ssOutports~=ssOutportBlk)



        return;
    end


end

