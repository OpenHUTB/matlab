function errorMex=getExportFcnInformation(obj)




    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    errorMex={};
    mdlBlkH=obj.BlockH;
    mdlBlkName=getfullname(mdlBlkH);
    portHandles=get_param(mdlBlkH,'porthandles');
    portGroupInfo=get_param(mdlBlkH,'PortGroupInfo');
    modelRefName=get_param(mdlBlkH,'ModelName');

    isMasked=~isempty(get_param(mdlBlkH,'MaskObject'));


    fcnCallSplitH=find_system(modelRefName,'FindAll','on',...
    'SearchDepth',1,'BlockType','FunctionCallSplit');


    rootFcnInports=slprivate('findFcnCallRootInport',modelRefName);

    obj.ExportFcnInformation(1).PortGroups=portGroupInfo.FcnCallPortGroups;
    initiatorBlks=[];
    multiSrc=[];

    for i=1:length(portGroupInfo.FcnCallPortGroups)
        pgInfo=portGroupInfo.FcnCallPortGroups(i);
        if~isempty(pgInfo.SimulinkFunction)&&isMasked
            errorMex{end+1}=MException('Sldv:xform:RepMdlRefBlkTreeNode:ExportFcnMaskedSlFcn',...
            getString(message('Sldv:Compatibility:ExportFcnMaskedSlFcn',mdlBlkName,pgInfo.SimulinkFunction)));
        end


        fcnIdx=pgInfo.GrFcnCallInputPort;
        if fcnIdx>=0
            fcnInportH=portHandles.Inport(fcnIdx+1);
            fcnPortObj=get_param(fcnInportH,'Object');
            actSrc=fcnPortObj.getActualSrc;
            srcPs=actSrc(:,1);
            parentHs=getParameterValue(srcPs,'ParentHandle');
            srcBlk=unique(parentHs);
            initiatorBlks=[initiatorBlks;srcBlk];%#ok<AGROW>




            srcWidths=getParameterValue(srcPs,'CompiledPortWidth');
            if any(srcWidths>1)
                multiSrc(end+1)=fcnIdx+1;%#ok<AGROW>
            end
        end
    end


    if length(unique(initiatorBlks))>1

        errorMex{end+1}=MException('Sldv:xform:RepMdlRefBlkTreeNode:ExportFcnMultipleSrc',...
        getString(message('Sldv:Compatibility:ExportFcnMultipleSrc',mdlBlkName)));
        return;
    end



    for i=1:length(fcnCallSplitH)
        fcnObj=get_param(fcnCallSplitH(i),'Object');
        srcInfo=fcnObj.getActualSrc;
        srcObj=get_param(get_param(srcInfo(1),'parent'),'Object');
        if isa(srcObj,'Simulink.RootInportFunctionCallGenerator')

            actSrcH=srcObj.getTrueOriginalBlock;
            if ismember(actSrcH,rootFcnInports)
                idx=str2double(get_param(actSrcH,'Port'));
                if ismember(idx,multiSrc)
                    obj.ExportFcnInformation(1).MultiDimFcnCallSrcSplit(end+1)=idx;
                end
            end
        end
    end
end

function paramValue=getParameterValue(src,paramName)



    paramValue=get_param(src,paramName);
    if iscell(paramValue)
        paramValue=cell2mat(paramValue);
    end
end
