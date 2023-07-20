
function[srcP,dstP,blks]=getSegBetweenVirtAndDFG(slcri,allMaps)





















    srcP=[];
    dstP=[];
    blks=[];

    if nargin<3
        allMaps2=containers.Map(allMaps.keys,cell(size(allMaps.keys)));
    end

    if strcmpi(slcri.direction,'either')
        return;
    end


    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    virtualStarts=slcri.getVirtualStarts;
    blks=virtualStarts(:);




    for index=1:length(virtualStarts)
        vStartH=virtualStarts(index);
        dfgStarts1=allMaps(vStartH);
        dfgStarts2=allMaps2(vStartH);
        dfgStarts=[dfgStarts1;dfgStarts2];
        vStartO=get(vStartH,'Object');






        dfgPorts=zeros(size(dfgStarts));
        for tvIndex=1:length(dfgPorts)
            if strcmpi(get(dfgStarts(tvIndex),'type'),'port')
                dfgPorts(tvIndex)=dfgStarts(tvIndex);
            else
                bo=get(dfgStarts(tvIndex),'Object');
                allportHandles=get(dfgStarts(tvIndex),'PortHandles');
                blks=[blks;dfgStarts(tvIndex)];%#ok<AGROW>
                if isa(bo,'Simulink.Inport')||isa(bo,'Simulink.Ground')


                    assert(length(allportHandles.Outport)==1);
                    dfgPorts(tvIndex)=allportHandles.Outport;
                elseif isa(bo,'Simulink.Outport')||isa(bo,'Simulink.Terminator')
                    assert(length(allportHandles.Inport)==1);
                    dfgPorts(tvIndex)=allportHandles.Inport;
                end
            end
        end















        srcPorts=[];
        dstPorts=[];


        if isa(vStartO,'Simulink.Inport')&&strcmpi(slcri.direction,'back')
            vStartPorts=slslicer.internal.virtual.getBoundarySrcForInport(vStartO,slcri.modelSlicer);
            [srcPorts,dstPorts]=meshgrid(dfgPorts,vStartPorts);
            srcPorts=srcPorts(:);
            dstPorts=dstPorts(:);
        end


        if isa(vStartO,'Simulink.Outport')&&strcmpi(slcri.direction,'forward')
            vStartPorts=slslicer.internal.virtual.getBoundaryDstForOutport(vStartO,slcri.modelSlicer);
            [srcPorts,dstPorts]=meshgrid(vStartPorts,dfgPorts);
            srcPorts=srcPorts(:);
            dstPorts=dstPorts(:);
        end


        if isa(vStartO,'Simulink.Inport')&&strcmpi(slcri.direction,'forward')
            vStartPortHandles=vStartO.PortHandles;
            assert(length(vStartPortHandles.Outport)==1);
            vStartPort=vStartPortHandles.Outport;
            srcPorts=repmat(vStartPort,size(dfgPorts));
            dstPorts=dfgPorts;
        end


        if isa(vStartO,'Simulink.Outport')&&strcmpi(slcri.direction,'back')
            vStartPortHandles=vStartO.PortHandles;
            assert(length(vStartPortHandles.Inport)==1);
            vStartPort=vStartPortHandles.Inport;
            dstPorts=repmat(vStartPort,size(dfgPorts));
            srcPorts=dfgPorts;




            [mdlBlkPorts,mdlBlks]=findMdlBlkSrcs(dfgPorts);
            util=slslicer.internal.SLCompGraphUtil;
            for i=1:length(mdlBlkPorts)

                newDst=util.findSrcPortsForOutport(mdlBlkPorts(i));

                newSrc=util.findSrcPortsInChildren(mdlBlks(i),mdlBlkPorts(i));
                newDst=repmat(newDst,size(newSrc));
                srcPorts=[srcPorts;newSrc];%#ok<AGROW>
                dstPorts=[dstPorts;newDst];%#ok<AGROW>
            end
        end


        if isa(vStartO,'Simulink.Port')&&strcmpi(slcri.direction,'back')


            srcInportToActualSrcMap=slcri.seedHandler.getSrcInportToActualSrcMap(vStartH);



            keys=srcInportToActualSrcMap.keys;


            for i=1:length(keys)
                srcInport=keys{i};
                actualSources=srcInportToActualSrcMap(keys{i});


                for j=1:length(actualSources)
                    srcPorts=[srcPorts;actualSources(j)];
                    dstPorts=[dstPorts;srcInport];
                end
            end
        end


        if isa(vStartO,'Simulink.Port')&&strcmpi(slcri.direction,'forward')
            userVirtStartToActDst=slcri.seedHandler.getVirtualToDFGMap(slcri);

            actDst=userVirtStartToActDst(vStartH);



            for i=1:length(actDst)
                srcPorts=[srcPorts;vStartH];
                dstPorts=[dstPorts;actDst(i)];
            end
        end

        if~isempty(srcPorts)&&~isempty(dstPorts)
            [gSrc,gDst]=slslicer.internal.getAllSegmentsInPath(srcPorts,dstPorts);

            srcP=[srcP;gSrc];%#ok<AGROW>
            dstP=[dstP;gDst];%#ok<AGROW>
        end
    end
end

function[mdlBlkPorts,mdlBlks]=findMdlBlkSrcs(dfgPorts)
    ownersH=get_param(dfgPorts,'ParentHandle');
    if iscell(ownersH)
        ownersH=[ownersH{:}];
    end
    idx=arrayfun(@(b)Simulink.SubsystemType.isModelBlock(b),ownersH);
    mdlBlkPorts=dfgPorts(idx);
    mdlBlks=ownersH(idx);
end
