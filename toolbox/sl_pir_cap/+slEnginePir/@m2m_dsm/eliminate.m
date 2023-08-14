function errMsg=eliminate(this)









    errMsg=[];
    this.fPirCreator=slEnginePir.CloneDetectionCreator(Simulink.SLPIR.Event.PostCompBlock);
    this.fPirCreator.createGraphicalPir([{this.fOriMdl},this.fRefMdls]);
    mdls=[{this.fMdl},this.fRefMdls];

    for i=1:length(mdls)
        mdlName=mdls{i};
        if strcmp(get_param(mdlName,'Dirty'),'on')
            DAStudio.error('sl_pir_cpp:creator:DSMDirtyModel',mdlName);
        end
        if slIsFileChangedOnDisk(mdlName)
            DAStudio.error('sl_pir_cpp:creator:DSMModifiedModel',mdlName);
        end
    end


    nMdls=length(this.fRefMdls)+1;
    for mIdx=1:nMdls
        cellArrayBlockList={};
        if isempty(this.fFinalCandidateIndex{mIdx})
            continue;
        end
        if slfeature('GlobalDSMRwElim')>0
            globalBlockCellArray={};
            idx=1;
        end
        for i=1:length(this.fFinalCandidateIndex{mIdx})
            blockList=this.fByNameList{this.fFinalCandidateIndex{mIdx}(i)};
            cellArrayBlockList{i,1}={blockList};%#ok

            if slfeature('GlobalDSMRwElim')>0
                firstBlock=blockList(1);
                if~strcmp(get_param(firstBlock,'blocktype'),'DataStoreMemory')
                    globalBlockCellArray{idx,1}={blockList};%#ok<AGROW> 
                    idx=idx+1;
                else
                    if strcmp(get_param(firstBlock,'StateMustResolveToSignalObject'),'on')
                        globalBlockCellArray{idx,1}={blockList};%#ok<AGROW> 
                        idx=idx+1;
                    end
                end
            end
        end

        for i=1:length(this.fFinalCandidateIndex{mIdx})
            if find(this.fElementIndex{mIdx}==this.fFinalCandidateIndex{mIdx}(i))
                elem=true;
            else
                elem=false;
            end

            if find(this.fFcnCallEnableIteratorIndex{mIdx}==this.fFinalCandidateIndex{mIdx}(i))
                func=true;
            else
                func=false;
            end

            if elem
                if func
                    modeNum=1;
                else
                    modeNum=0;
                end
            else
                if func
                    modeNum=2;
                else
                    modeNum=3;
                end
            end
            dsmMode{i,1}={modeNum};%#ok<AGROW> 
        end

        for i=1:length(dsmMode)
            if dsmMode{i}{1}(1)<2
                if strcmp(get_param(cellArrayBlockList{i}{1}(1),'BlockType'),'DataStoreMemory')
                    outDataTypeStr=get_param(cellArrayBlockList{i}{1}(1),'OutDataTypeStr');
                    dataStoreName=get_param(cellArrayBlockList{i}{1}(1),'DataStoreName');
                    cPos=findstr(outDataTypeStr,':');
                    outDataTypeStr(1:cPos)=[];
                    while strcmp(outDataTypeStr(1),' ')
                        outDataTypeStr(1)=[];
                    end
                    elements=evalin('base',[outDataTypeStr,'.Elements']);
                    ithElementsNames={};
                    for j=1:length(elements)
                        ithElementsNames{j}=[dataStoreName,'.',elements(j).Name];%#ok<AGROW> 
                    end
                    elementsNames{i,1}=ithElementsNames;%#ok
                else
                    elementsNames{i,1}={};%#ok
                end
            else
                elementsNames{i,1}={};%#ok
            end
        end


        keySet=keys(this.fWrite2BusTypeMap);
        write2BusType={};
        for i=1:length(keySet)
            write2BusType{i,1}=keySet{1};%#ok<AGROW> 
            write2BusType{i,2}=this.fWrite2BusTypeMap(keySet{1});%#ok<AGROW> 
        end

        if slfeature('GlobalDSMRwElim')>0
            result=Simulink.SLPIR.ModelXform_DSM.DSMEliminate(cellArrayBlockList,mdls{mIdx},dsmMode,elementsNames,this.fPrefix,write2BusType,globalBlockCellArray);
        else
            result=Simulink.SLPIR.ModelXform_DSM.DSMEliminate(cellArrayBlockList,mdls{mIdx},dsmMode,elementsNames,this.fPrefix,write2BusType,{});
        end
        this.fXformCmd=vertcat(this.fXformCmd,result.Xform_Cmds);
    end

end


