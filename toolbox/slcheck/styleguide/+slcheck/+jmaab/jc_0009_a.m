

classdef jc_0009_a<slcheck.subcheck
    methods
        function obj=jc_0009_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0009_a';
        end
        function result=run(this)
            result=false;
            obj=this.getEntity();
            violations=[];
            fl=this.getInputParamByName('Follow links');
            lum=this.getInputParamByName('Look under masks');

            if strcmp(get_param(obj,'Type'),'block')&&...
                strcmp(get_param(obj,'BlockType'),'SubSystem')
                violations=checkSubsystemSignalPropagation(obj,fl,lum);
            end


            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
    end
end

function violations=checkSubsystemSignalPropagation(obj,fl,lum)
    violations=[];
    ports=get_param(obj,'Ports');
    lh=get_param(obj,'LineHandles');
    for j=1:ports(2)
        if(lh.Outport(j)~=-1)
            allsinks=get_param(lh.Outport(j),'DstPortHandle');
            hiliteHandle=get_param(lh.Outport(j),'Handle');
            if(isempty(allsinks)~=0)||(isempty(find(allsinks==-1,1))~=0)
                lh_obj=get_param(lh.Outport(j),'Object');

                if~strcmp(get_param(obj,'LinkStatus'),'resolved')
                    [isBusCreator,lineLabel]=isLineSrcBusCreator(obj,j);
                else
                    isBusCreator=false;
                    lineLabel=[];
                end

                violations=[violations;createViolationObj(obj,lh_obj,...
                isBusCreator,lineLabel,hiliteHandle)];%#ok<AGROW>
            end
        end
    end

    inports=find_system(obj,'SearchDepth',1,'FollowLinks',fl,'LookUnderMasks',lum,'BlockType','Inport');
    for i=1:numel(inports)
        [isBusCreator,lineLabel]=isLineSrcBusCreator(inports{i});
        inportObj=get_param(inports{i},'Object');
        if(strcmp(get_param(inportObj.Parent,'BlockType'),'SubSystem')&&...
            strcmp(get_param(inportObj.Parent,'SFBlockType'),'Chart'))
            continue;
        end
        outport=inportObj.PortHandles.Outport;
        if~ishandle(outport)
            continue;
        end
        lineHdl=get_param(outport,'Line');
        lineObj=[];
        if~ishandle(lineHdl)
            continue;
        end
        lineObj=get_param(lineHdl,'Object');
        if(strcmp(get_param(lineObj.SrcBlockHandle,'BlockType'),'SubSystem')&&...
            strcmp(get_param(lineObj.SrcBlockHandle,'SFBlockType'),'Chart'))
            continue;
        end
        violations=[violations;createViolationObj(obj,lineObj,...
        isBusCreator,lineLabel,lineHdl)];%#ok<AGROW>
    end
end


function[bResult,lineLabel]=isLineSrcBusCreator(varargin)
    bResult=false;
    lineLabel=[];
    if nargin==2
        obj=varargin{1};
        portNo=varargin{2};

        allPorts=find_system(obj,'SearchDepth',1,'FindAll','on','Type','block','BlockType','Outport');
        if~isempty(allPorts)&&(portNo<=numel(allPorts))
            ports=get_param(allPorts(portNo),'LineHandles');

            if~ishandle(ports.Inport)
                return;
            end
            srcBlkHdl=get_param(ports.Inport,'SrcBlockHandle');

            if~ishandle(srcBlkHdl)
                return;
            end
            srcLineHdl=get_param(ports.Inport,'SrcPortHandle');
            lineLabel=get_param(srcLineHdl,'Name');
            if strcmp(get_param(srcBlkHdl,'BlockType'),'BusCreator')
                bResult=true;
            end
        end
    elseif nargin==1
        inputPort=varargin{1};
        inputPortObj=get_param(inputPort,'Object');
        portNo=inputPortObj.Port;
        obj=get_param(inputPortObj.Parent,'Object');
        inportsOfObj=obj.PortHandles.Inport;
        inportsOfObj=num2cell(inportsOfObj);
        inportsOfObj=inportsOfObj(cellfun(@(x)strcmp(num2str(get_param(x,'PortNumber')),portNo),inportsOfObj));
        inportsOfObj=inportsOfObj{1};
        lineHdl=get_param(inportsOfObj,'line');
        if~ishandle(lineHdl)
            return;
        end
        lineLabel=get_param(lineHdl,'Name');
        if ishandle(get_param(lineHdl,'SrcBlockHandle'))&&...
            strcmp(get_param(get_param(lineHdl,'SrcBlockHandle'),'BlockType'),'BusCreator')
            bResult=true;
        end
    end
end
function vObj=createViolationObj(obj,lh_obj,isBusCreator,lineLabel,hiliteHandle)
    vObj=[];

    if~isempty(lh_obj.Name)




        if~strcmp(lh_obj.signalPropagation,'off')||...
...
            ~(isBusCreator&&isempty(lineLabel)||...
            ~strcmpi(get_param(obj,'LinkStatus'),'none')...
            ||strcmp(get_param(obj,'RTWSystemCode'),'Reusable function'))
            vObj=ModelAdvisor.ResultDetail;
            vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_UnneccSigName_warn');
            vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_UnneccSigName_rec_action');
            ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
        end

    else






        propSignals=(lh_obj.ShowPropagatedSignals||...
        strcmp(get_param(bdroot,'ShowAllPropagatedSignalLabels'),'on'))&&...
        (~isempty(get_param(lh_obj.SrcPortHandle,'PropagatedSignals')));
        if strcmp(lh_obj.signalPropagation,'off')&&...
...
...
            ~strcmp(get_param(obj,'LinkStatus'),'resolved')&&...
...
...
            ~(strcmp(get_param(obj,'TreatAsAtomicUnit'),'on')&&...
...
            strcmp(get_param(obj,'RTWSystemCode'),'Reusable function'))&&...
...
...
            ~(isBusCreator&&isempty(lineLabel))



            if~propSignals
                vObj=ModelAdvisor.ResultDetail;
                vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_NoSigName_warn');
                vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_NoSigName_rec_action');
                ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
            end



        elseif~strcmp(lh_obj.signalPropagation,'off')&&...
            ~propSignals
            vObj=ModelAdvisor.ResultDetail;
            vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_SigPropagation_ON_warn');
            vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_SigPropagation_ON_rec_action');
            ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
        end







        if propSignals&&(~strcmpi(get_param(obj,'LinkStatus'),'none')...
            ||strcmp(get_param(obj,'RTWSystemCode'),'Reusable function')...
            ||(isempty(lineLabel)&&isBusCreator))
            vObj=ModelAdvisor.ResultDetail;
            vObj.Status=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_SigPropagation_exception');
            vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0009_a_SigPropagation_exception_rec_action');
            ModelAdvisor.ResultDetail.setData(vObj,'Signal',hiliteHandle);
        end
    end
end