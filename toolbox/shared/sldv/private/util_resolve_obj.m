function[out,replacedParentInfo,objReplacementInfo,origSFBlockH]=util_resolve_obj(objH,parentH,atomicss_report,...
    blockReplacementApplied,varargin)











    keepRepInfo=false;
    analysisInfo=[];
    forceMapToExtractedModel=false;





    if nargin>=5
        if isa(varargin{1},'SlAvt.TestComponent')
            testcomp=varargin{1};
            analysisInfo=testcomp.analysisInfo;
        elseif isstruct(varargin{1})
            analysisInfo=varargin{1};
        end
    end
    if nargin>=6
        keepRepInfo=varargin{2};
    end
    if nargin>=7
        forceMapToExtractedModel=varargin{3};


        forceMapToExtractedModel=forceMapToExtractedModel&&...
        atomicss_report&&blockReplacementApplied;
    end

    replacedParentInfo=[];
    objReplacementInfo=[];
    origSFBlockH=[];

    if~(atomicss_report||blockReplacementApplied)
        out=objH;
    else
        if~isnumeric(objH)

            out=objH;
            return;
        elseif(floor(objH)==objH)

            try
                toBeMapped=~sf('Private','is_eml_script',objH);
            catch Mex %#ok<NASGU>
                toBeMapped=false;
            end
            if~toBeMapped

                out=objH;
                return;
            end
            blockH=find_equiv_handle(objH);
            if strcmp(get_param(bdroot(blockH),'BlockDiagramType'),'library')

                out=objH;
                return;
            end
            if strcmp(strtok(getfullname(blockH),'/'),strtok(getfullname(parentH),'/'))

                out=objH;
                return;
            end
            if isInsertedByExtraction(blockH,atomicss_report,analysisInfo)


                out=objH;
                return;
            end
            [origSFBlockH,replacedParentInfo]=util_resolve_obj(blockH,parentH,atomicss_report,...
            blockReplacementApplied,analysisInfo,keepRepInfo);
            if~isempty(replacedParentInfo)&&...
                ~(strcmp(get_param(origSFBlockH,'Type'),'block')&&...
                slprivate('is_stateflow_based_block',origSFBlockH))


                out=objH;
                return;
            else
                [~,type]=getSFObjPersistentId(objH);
                if strcmp(get_param(origSFBlockH,'type'),'block_diagram')&&...
                    (type=='D'||type=='E')
                    orMachID=sf('find','all','machine.name',get_param(bdroot(origSFBlockH),'Name'));
                    if type=='D'

                        dataName=sf('get',objH,'.name');
                        out=sf('find','all','data.parent',orMachID,'data.name',dataName);
                    else

                        eventName=sf('get',objH,'.name');
                        out=sf('find','all','event.parent',orMachID,'event.name',eventName);
                    end
                    if length(out)>1
                        out=out(1);
                    end
                else
                    origchartid=sf('Private','block2chart',origSFBlockH);
                    out=util_resolve_sf_id_from_orig_chart(objH,origchartid);
                end
            end
        else







            rootH=bdroot(objH);
            hasObserverPorts=~isempty(Simulink.observer.internal.getObserverPortsInsideObserverModel(rootH));
            if hasObserverPorts
                out=objH;
                return;
            end
            slType=get_param(objH,'type');
            if strcmp(slType,'block_diagram')
                out=bdroot(parentH);
            else
                if strcmp(get_param(bdroot(objH),'BlockDiagramType'),'library')

                    out=objH;
                    return;
                end
                if isInsertedByExtraction(objH,atomicss_report,analysisInfo)


                    out=objH;
                    return;
                end
                if atomicss_report
                    if blockReplacementApplied
                        replacedBlocksTable=analysisInfo.replacementInfo.replacementTable;
                        [replacedParentInfo,objH]=deriveReplacedParents(objH,replacedBlocksTable);
                        objName=get_param(objH,'Name');








                        if strncmp(objName,'__SLDVAddConversion',...
                            length('__SLDVAddConversion'))
                            out=objH;
                            return;
                        end
                        if replacedBlocksTable.isKey(objH)&&isempty(replacedParentInfo)


                            replacedBlockInfo=replacedBlocksTable(objH);
                            originalPathInAtomicSS=replacedBlockInfo.BeforeRepFullPath;
                            objH=get_param(originalPathInAtomicSS,'Handle');
                            objReplacementInfo=replacedBlockInfo;
                        else
                            if~isempty(replacedParentInfo)


                                if strcmp(replacedParentInfo.RepRuleInfo.BlockType,'ModelReference')&&...
                                    replacedParentInfo.RepRuleInfo.IsBuiltin
                                    if replacedBlocksTable.isKey(objH)
                                        replacedBlockInfo=replacedBlocksTable(objH);
                                        originalPathInAtomicSS=replacedBlockInfo.BeforeRepFullPath;
                                        RefMdlName=get_param(replacedParentInfo.BeforeRepFullPath,'ModelName');
                                        parentH=get_param(RefMdlName,'Handle');
                                    else
                                        objPath=getfullname(objH);
                                        relativePath=...
                                        objPath(length(replacedParentInfo.ReplacementFullPath)+1:end);
                                        RefMdlName=get_param(replacedParentInfo.BeforeRepFullPath,'ModelName');
                                        parentH=get_param(RefMdlName,'Handle');
                                        originalPathInAtomicSS=[RefMdlName,relativePath];
                                    end
                                    if~keepRepInfo
                                        replacedParentInfo=[];
                                    end
                                else
                                    originalPathInAtomicSS=replacedParentInfo.BeforeRepFullPath;
                                    rootModelH=get_param(bdroot(originalPathInAtomicSS),'Handle');
                                    if analysisInfo.extractedModelH~=rootModelH
                                        parentH=rootModelH;
                                    end
                                    replacedParentInfo.BlockOnRepMdl=objH;
                                end
                                objH=get_param(originalPathInAtomicSS,'Handle');
                            end
                        end
                    end
                    objPath=getfullname(objH);
                    blockType=get_param(objH,'BlockType');
                    if any(strcmp(blockType,{'Inport','Outport'}))&&~forceMapToExtractedModel



                        try
                            analyzedSubsystem=get_param(bdroot(objH),'DVExtractedSubsystem');
                        catch Mex %#ok<NASGU>
                            analyzedSubsystem='';
                        end
                        if~isempty(analyzedSubsystem)
                            objPath=[get_param(bdroot(objH),'Name'),'/',analyzedSubsystem];
                        end
                    end
                    [~,remPath]=strtok(objPath,'/');
                    if~isempty(analysisInfo)&&analysisInfo.analyzedAtomicSubchartWithParam


                        remPath=remPath(2:end);
                        [~,remPath]=strtok(remPath,'/');
                    end
                    if~forceMapToExtractedModel
                        originalPath=[getfullname(parentH),remPath];
                    else
                        originalPath=[getfullname(analysisInfo.extractedModelH),remPath];
                    end
                else
                    replacedBlocksTable=analysisInfo.replacementInfo.replacementTable;
                    if~replacedBlocksTable.isKey(objH)
                        [replacedParentInfo,objH]=deriveReplacedParents(objH,replacedBlocksTable);
                        objName=get_param(objH,'Name');








                        if strncmp(objName,'__SLDVAddConversion',...
                            length('__SLDVAddConversion'))
                            out=objH;
                            return;
                        end
                        if isempty(replacedParentInfo)
                            objPath=getfullname(objH);
                            [~,remPath]=strtok(objPath,'/');
                            originalPath=[getfullname(parentH),remPath];
                        else
                            if strcmp(replacedParentInfo.RepRuleInfo.BlockType,'ModelReference')&&...
                                replacedParentInfo.RepRuleInfo.IsBuiltin
                                objName=get_param(objH,'Name');
                                if strcmp(objName,'__SLDVFcnCallPass')
                                    out=objH;
                                    return;
                                end
                                objPath=getfullname(objH);
                                relativePath=...
                                objPath(length(replacedParentInfo.ReplacementFullPath)+1:end);
                                RefMdlName=get_param(replacedParentInfo.BeforeRepFullPath,'ModelName');
                                originalPath=[RefMdlName,relativePath];
                                if~keepRepInfo
                                    replacedParentInfo=[];
                                end
                            else
                                originalPath=replacedParentInfo.BeforeRepFullPath;
                                replacedParentInfo.BlockOnRepMdl=objH;
                            end
                        end
                    else
                        objReplacementInfo=replacedBlocksTable(objH);
                        originalPath=replacedBlocksTable(objH).BeforeRepFullPath;
                    end
                end
                if(getSimulinkBlockHandle(originalPath)==-1)
                    out=objH;
                else
                    out=get_param(originalPath,'Handle');
                end
            end
        end
    end
end

function out=isInsertedByExtraction(blockH,atomicss_report,analysisInfo)
    out=false;
    if isempty(analysisInfo)
        return;
    end
    isBDExtractedModel=analysisInfo.blockDiagramExtract;
    if isBDExtractedModel&&...
        any(strcmp(getfullname(blockH),...
        {
        [getfullname(analysisInfo.analyzedModelH),'/',getfullname(analysisInfo.designModelH)]
        [getfullname(analysisInfo.extractedModelH),'/',getfullname(analysisInfo.designModelH)]
        }...
        ))

        out=true;
        return;
    end
    if isBDExtractedModel||atomicss_report
        if slfeature('UnifiedHarnessExtract')>0||isBDExtractedModel



            tag=get_param(blockH,'Tag');
            sid=get_param(blockH,'SID');
            if strcmp(sid,'1')||strncmp(sid,'1:',2)
                out=false;
                return;
            end
            if~isempty(tag)&&contains(tag,{'_SLT_','__SLDVFcnCallPass'})
                out=true;
                return;
            end
            parent=get_param(blockH,'Parent');
            while~isempty(parent)&&strcmp(get_param(parent,'Type'),'block')
                tag=get_param(parent,'Tag');
                sid=get_param(parent,'SID');
                if strcmp(sid,'1')||strncmp(sid,'1:',2)
                    out=false;
                    return;
                end


                if~isempty(tag)&&contains(tag,{'_SLT_','__SLDVFcnCallPass'})
                    out=true;
                    return;
                end
                parent=get_param(parent,'Parent');
            end
        elseif strcmp(get_param(blockH,'BlockType'),'S-Function')
            parent=get_param(blockH,'Parent');
            out=(strcmp(get_param(parent,'type'),'block')&&...
            strcmp(get_param(parent,'BlockType'),'SubSystem')&&...
            any(strcmp(get_param(parent,'referenceBlock'),...
            {'sldvextractlib/Fcn Call Generator/fcn_gen',...
            'sldvextractSLlib/Fcn Call Generator/fcn_gen'})))||...
            (strcmp(get_param(parent,'type'),'block_diagram')&&strcmp(get_param(blockH,'BlockType'),'Inport'));
        elseif strcmp(get_param(blockH,'BlockType'),'SubSystem')&&...
            strcmp(get_param(get_param(blockH,'Parent'),'Type'),'block')
            parentH=get_param(blockH,'Parent');
            if strcmp(get_param(parentH,'BlockType'),'SubSystem')&&...
                strcmp(get_param(parentH,'MaskType'),'DVFcnCallSubsysForExtraction')
                out=true;
            end
        elseif strcmp(get_param(blockH,'Type'),'block')&&...
            strcmp(get_param(blockH,'BlockType'),'BusSelector')&&...
            strcmp(get_param(get_param(blockH,'Parent'),'Type'),'block_diagram')
            ports=get_param(blockH,'PortHandles');
            line=get_param(ports.Inport,'Line');
            out=strcmp(get_param(get_param(line,'SrcBlockHandle'),'Name'),...
            get_param(get_param(blockH,'Parent'),'DVExtractedSubsystem'));

        elseif strcmp(get_param(blockH,'Type'),'block')&&...
            strcmp(get_param(blockH,'BlockType'),'DataStoreWrite')&&...
            strcmp(get_param(get_param(blockH,'Parent'),'Type'),'block_diagram')

            ports=get_param(blockH,'PortHandles');
            line=get_param(ports.Inport,'Line');
            myName=get_param(blockH,'Name');
            phName=get_param(get_param(line,'SrcBlockHandle'),'Name');
            dsName=get_param(blockH,'dataStoreName');
            out=isNumSuffixedString(dsName,phName)&&...
            isNumSuffixedString(['dw_',dsName],myName);

        elseif strcmp(get_param(blockH,'Type'),'block')&&...
            strcmp(get_param(blockH,'BlockType'),'DataStoreRead')&&...
            strcmp(get_param(get_param(blockH,'Parent'),'Type'),'block_diagram')


            dsName=get_param(blockH,'DataStoreName');
            dsrName=get_param(blockH,'Name');
            ports=get_param(blockH,'PortHandles');
            line=get_param(ports.Outport,'Line');
            outportName=get_param(get_param(line,'DstBlockHandle'),'Name');
            out=isNumSuffixedString(dsName,outportName)&&...
            isNumSuffixedString(['dr_',dsName],dsrName);
        elseif strcmp(get_param(blockH,'Type'),'block')&&...
            strcmp(get_param(blockH,'BlockType'),'DataStoreMemory')


            parent=get_param(blockH,'Parent');
            out=strcmp(get_param(parent,'Type'),'block_diagram');
        end
    end
end

function[replacedParentInfo,blockH]=deriveReplacedParents(blockH,replacedBlocksTable)
    replacedParentInfo=checkReplacedParents(blockH,replacedBlocksTable);
    if isempty(replacedParentInfo)
        newBlockH=findActualPortHandle(blockH,replacedBlocksTable);
        if~isempty(newBlockH)
            newReplacedParentInfo=checkReplacedParents(newBlockH,replacedBlocksTable);
            if~isempty(newReplacedParentInfo)
                replacedParentInfo=newReplacedParentInfo;
                blockH=newBlockH;
            end
        end
    end
end

function replacedParentInfo=checkReplacedParents(blockH,replacedBlocksTable)
    replacedParentInfo=[];
    blockHToCheck=blockH;
    while true
        parent=get_param(blockHToCheck,'Parent');
        if strcmp(get_param(parent,'Type'),'block_diagram')
            break;
        else
            parentH=get_param(parent,'Handle');
            if replacedBlocksTable.isKey(parentH)
                replacedParentInfo=replacedBlocksTable(parentH);
                break;
            else
                blockHToCheck=parentH;
            end
        end
    end
end

function newBlockH=findActualPortHandle(blockH,replacedBlocksTable)
    newBlockH=[];
    if strcmp(get_param(blockH,'Type'),'block')&&...
        strcmp(get_param(get_param(blockH,'Parent'),'Type'),'block')
        isInport=strcmp(get_param(blockH,'BlockType'),'Inport');
        isOutport=strcmp(get_param(blockH,'BlockType'),'Outport');
        if isInport||isOutport
            portHs=get_param(blockH,'PortHandles');
            if isInport
                portH=portHs.Outport;
            else
                portH=portHs.Inport;
            end
            lineH=get_param(portH,'Line');
            if~isempty(lineH)&&lineH~=-1
                if isInport
                    srcdesPortH=get_param(lineH,'DstPortHandle');
                    if numel(srcdesPortH)>1

                        srcdesPortH=srcdesPortH(1);
                    end
                else
                    srcdesPortH=get_param(lineH,'SrcPortHandle');
                end
                if~isempty(srcdesPortH)&&srcdesPortH~=-1
                    parentH=get_param(get_param(srcdesPortH,'Parent'),'Handle');
                    if replacedBlocksTable.isKey(parentH)
                        replacedParentInfo=replacedBlocksTable(parentH);
                        if strcmp(replacedParentInfo.RepRuleInfo.BlockType,'ModelReference')&&...
                            replacedParentInfo.RepRuleInfo.IsBuiltin&&...
                            replacedParentInfo.RepRuleInfo.InlinedWithNewSubsys
                            [ssInBlkHs,ssOutBlkHs,ssTriggerBlkHs,ssEnableBlkHs]=Sldv.utils.getBlockHandlesForPortsInSubsys(parentH);
                            portIndex=str2double(get_param(blockH,'Port'));
                            if isOutport
                                newBlockH=get_param(ssOutBlkHs(portIndex),'Handle');
                            else
                                if isempty(ssTriggerBlkHs)&&isempty(ssEnableBlkHs)
                                    newBlockH=get_param(ssInBlkHs(portIndex),'Handle');
                                elseif isempty(ssTriggerBlkHs)&&~isempty(ssEnableBlkHs)
                                    if portIndex==1
                                        newBlockH=get_param(ssEnableBlkHs(portIndex),'Handle');
                                    else
                                        newBlockH=get_param(ssInBlkHs(portIndex-1),'Handle');
                                    end
                                elseif~isempty(ssTriggerBlkHs)&&isempty(ssEnableBlkHs)
                                    if portIndex==1
                                        newBlockH=get_param(ssTriggerBlkHs(portIndex),'Handle');
                                    else
                                        newBlockH=get_param(ssInBlkHs(portIndex-1),'Handle');
                                    end
                                else
                                    newBlockH=get_param(ssInBlkHs(portIndex-2),'Handle');
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function out=isNumSuffixedString(str1,str2)


    out=false;
    if strcmp(str1,str2)
        out=true;
    else
        mySuffix=str2(length(str1)+1:end);
        out=mySuffix(1)=='_'&&...
        all(isstrprop(mySuffix(2:end),'digit'));
    end
end
