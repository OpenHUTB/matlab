function highlightPath(sldvData,pathidx,method)




    addonHs=[];

    if nargin==2
        method='';
    end


    if strcmp('clear',method)
        pathHilite(method)
        return;
    end


    pathObjData=sldvData.PathObjectives(pathidx);
    pathStatus=pathObjData.status;
    pathdata=pathObjData.path;
    pathstr=[];
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);

    if length(pathdata)==1
        pathstr=[];

        modelObjID=strcmp(pathdata.modelObj,{sldvData.ModelObjects.sid});
        if any(modelObjID)
            moObj=sldvData.ModelObjects(modelObjID);
            moHdl=Simulink.ID.getHandle(moObj.designSid);
        else
            moHdl=Simulink.ID.getHandle(pathData.modelObj);
        end

        port=pathdata.port;
        inpH=inP(moHdl,port);
        outpH=outP(moHdl);
        inpL=get_param(inpH,'Line');
        outpL=get_param(outpH,'Line');
        addonHs=[inpL,outpL,moHdl];
    else
        useReplacedModel=useReplacementModel(sldvData,pathdata);
        if useReplacedModel
            opened_model=find_system('type','block_diagram');
            [~,mdltohiliete]=fileparts(sldvData.ModelInformation.ReplacementModel);
            if~ismember(mdltohiliete,opened_model)||strcmp(get_param(mdltohiliete,'Open'),'off')
                open_system(mdltohiliete);
            end
        end
        for i=1:length(pathdata)

            if~useReplacedModel
                modelObjID=strcmp(pathdata(i).modelObj,{sldvData.ModelObjects.sid});
                if~isempty(find(modelObjID,1))
                    moObj=sldvData.ModelObjects(modelObjID);
                    moObjSid=moObj.designSid;
                else
                    moObjSid=pathdata(i).modelObj;
                end
            else
                moObjSid=pathdata(i).modelObj;
            end
            moHdl=Simulink.ID.getHandle(moObjSid);
            get_param(moHdl,'Name');
            port=pathdata(i).port;
            inpH=inP(moHdl,port);
            outpH=outP(moHdl);
            if(i==1)
                pathstr=outpH;

                inpL=get_param(inpH,'Line');
                addonHs=inpL;
            elseif i==length(pathdata)
                pathstr=[pathstr,inpH];%#ok<AGROW>



                if outpH
                    outpL=get_param(outpH,'Line');
                    addonHs=[addonHs,outpL];%#ok<AGROW>
                end
            else
                pathstr=[pathstr,inpH,outpH];%#ok<AGROW>
            end
        end
    end
    pathHilite(pathstr,addonHs,pathStatus,sldvData.AnalysisInformation.Options.Mode);
    delete(sess);
end


function pathHilite(ports,addLines,status,mode)







    persistent StyleG ActiveModel Fader;

    if(ischar(ports)&&strcmpi(ports,'clear'))
        if~isempty(StyleG)
            StyleG.clear();
            StyleG=[];
        end

        if~isempty(Fader)
            Fader.clear();
            Fader=[];
        end

        return;
    end

    if~isempty(ports)
        [hiliteItems,modelH]=find_hilite_items(ports);
    else
        hiliteItems=[];
        modelH=bdroot(addLines(3));
    end
    hiliteItems=[hiliteItems;addLines'];



    if ActiveModel==modelH
        if~isempty(StyleG)
            StyleG.clear();
            StyleG=[];
        end

        if~isempty(Fader)
            Fader.clear();
            Fader=[];
        end
    else
        if~isempty(StyleG)
            StyleG=[];
        end

        if~isempty(Fader)
            Fader=[];
        end

    end





    if isempty(StyleG)
        slicerUI=modelslicerprivate('slicerMapper','getUI',modelH);
        if(~isempty(slicerUI))
            msgbox('Path hilighting disabled while running Model Slicer');
            return;
        end

        ActiveModel=modelH;
        mgr=SliceStyle.Manager.Instance();
        fadeClassName=sprintf('BD_%i',mgr.getNextIndex());
        Fader=SliceStyle.StyleGroup(createSliceFadeStyle(),fadeClassName,modelH);


        StyleG=SliceStyle.StyleGroup(local_get_style(status,mode),'PathHilite',hiliteItems);
    else
        if(modelH~=ActiveModel)
            ActiveModel=modelH;
            Fader.setItems(ActiveModel);
        end

        StyleG.setItems(hiliteItems);
    end


end

function[handles,modelH]=find_hilite_items(ports)

    srcPorts=ports(1:2:end);
    destPorts=ports(2:2:end);
    if(numel(srcPorts)~=numel(destPorts))
        error('Should have an even number of ports');
    end

    blks=local_port_parent_blocks(ports);
    modelH=bdroot(blks(1));
    utils=SystemsEngineering.SEUtil;
    [segHs,vBlks,gSrc,gDst]=utils.getAllSegmentsInPath(srcPorts,destPorts);%#ok<ASGLU>
    allBlks=unique([blks;vBlks]);

    handles=[allBlks;segHs;slslicer.internal.SLGraphUtil.getAllSystems(allBlks)];

end



function style=local_get_style(status,mode)
    color=get_highligt_color(status,mode);
    style=diagram.style.Style;
    style.set('FillColor',[1,1,1,1],'simulink.Block');
    style.set('FillColor',[1,1,1,1],'simulink.Segment');
    style.set('TextColor',[0,0,0,1]);
    style.set('StrokeColor',[color,1],'simulink.Block');
    style.set('StrokeColor',[color,1],'simulink.Segment');

    stroke=MG2.Stroke;
    stroke.Color=[color,1];
    stroke.Width=0.75;
    style.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Block');
    style.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Segment');
    style.set('StrokeStyle','SolidLine','simulink.Block');
    style.set('StrokeStyle','SolidLine','simulink.Segment');
end

function style=createSliceFadeStyle()
    style=diagram.style.Style;
    style.set('FillColor',[0.8,0.8,0.8,1.0]);
    style.set('FillStyle','Solid');
    style.set('TextColor',[0.5,0.5,0.5,1.0]);
    style.set('StrokeColor',[0.6,0.6,0.6,1.0]);
    style.set('Shadow',[]);
end




function color=get_highligt_color(status,mode)
    red=[0.9,0,0];
    blue=[0,1,1];
    orange=[1,0.6,0];
    green=[0,0.8,0.3];
    color=blue;

    switch(status)
    case{'Valid',...
        'Valid within bound',...
        'Satisfied',...
        'Active Logic',...
        'Active Logic - needs simulation',...
        'Satisfied - No Test Case'}
        color=green;
    case{'Undecided',...
        'Undecided due to stubbing',...
        'Undecided due to nonlinearities',...
        'Undecided due to division by zero',...
        'Undecided due to array out of bounds',...
        'Produced error',...
        'Undecided due to approximations',...
        'Unsatisfiable under approximation',...
        'Valid under approximation',...
        'Satisfied - needs simulation',...
        'Undecided with testcase',...
        'Undecided with counterexample',...
        'Undecided due to runtime error'}
        color=orange;
    case{'Falsified',...
        'Falsified - No Counterexample',...
        'Unsatisfiable',...
        'Dead Logic',...
        'Dead Logic under approximation'}
        color=red;
    case 'Falsified - needs simulation'
        if strcmp(mode,'DesignErrorDetection')
            color=red;
        else
            color=orange;
        end
    end
end



function blks=local_port_parent_blocks(ports)
    cnt=numel(ports);
    blks=zeros(cnt,1);
    for idx=1:cnt
        blks(idx)=get_param(get_param(ports(idx),'Parent'),'Handle');
    end
    blks=unique(blks);
end

function portH=outP(blkH)
    ph=prtH(blkH);
    portH=ph.Outport;
end

function portH=inP(blkH,idx)
    ph=prtH(blkH);
    portH=ph.Inport(idx);
end

function ph=prtH(blkH)
    ph=get_param(blkH,'PortHandles');
end




function flag=useReplacementModel(sldvData,path)


    modelObjectIndices=[];
    for pathComponent=1:length(path)
        if(any(strcmp((path(pathComponent).modelObj),{sldvData.ModelObjects.sid})))
            modelObjectIndices(end+1)=find(strcmp((path(pathComponent).modelObj),...
            {sldvData.ModelObjects.sid}));%#ok<AGROW>
        else








        end
    end
    modelObjectsToBeConsidered=sldvData.ModelObjects(modelObjectIndices);


    if isempty([modelObjectsToBeConsidered.replacementSid])
        flag=false;
    else
        replacementSidsToConsider={modelObjectsToBeConsidered.replacementSid};

        replacementSidsToConsider=replacementSidsToConsider(~cellfun('isempty',replacementSidsToConsider));

        allReplacementInfoInTheModel=sldvData.AnalysisInformation.ReplacementInfo;
        allReplacementSidInModel={allReplacementInfoInTheModel.replacementSid};

        allReplacementInfoAppiledInThePath=allReplacementInfoInTheModel...
        (cellfun(@(repl_Sid)any(strcmp((repl_Sid),allReplacementSidInModel)),...
        unique(replacementSidsToConsider)));

        appliedReplacementRuleInformation=[allReplacementInfoAppiledInThePath.RepRuleInfo];







        flag=any(cellfun(@isempty,...
        regexp(appliedReplacementRuleInformation.RuleName,...
        'blkrep_rule_modelref_\w*normal',...
        'forceCellOutput')));

    end

end
