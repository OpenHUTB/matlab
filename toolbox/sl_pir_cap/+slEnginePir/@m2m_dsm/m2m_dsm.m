



classdef m2m_dsm<slEnginePir.model2model
    properties(Access='public')
        fExcludedClass;
        fByNameList;
        fTopMdlHandle;
        fFcnCallEnableIteratorIndex;
        fCondTerminatedIndex;
        fElementIndex;
        fWrite2BusTypeMap;
        fGlobalIndex;
        fVariantIndex;
        fMultiInOutIndex;
        fPartialArrayIndex;
        fStateflowIndex;
        fMultirateIndex;
        fNonCandidateIndex;
        fNonCandidateReason;
        fLibBehaveDifferentIndex;
        fCandidateIndex;
        fLibCandIdx;
        fHiddenSubsysIdx={};
        fEliminatedIndex;
        fFinalCandidateIndex;
        fDefaultCandIndex;
        fXformCmd;
        fUserSpecifiedSortedOrder;
        fDeactivatedLibBlks;
        fCopyLib;
        fCopyLibRef;
        fUI=false;
    end

    properties(Hidden)
        cleanup_dsm;
    end

    methods(Access='public')
        function this=m2m_dsm(aOriSys,isUserSpecifiedSortedOrder)
            p=pir;
            p.destroyPirCtx(aOriSys);


            taskbasedsortingfv=slfeature('TaskBasedSorting',0);

            this@slEnginePir.model2model(aOriSys);
            if nargin==2
                this.fUserSpecifiedSortedOrder=isUserSpecifiedSortedOrder;
            else
                this.fUserSpecifiedSortedOrder=0;
            end

            this.fTopMdlHandle=get_param(bdroot(aOriSys),'handle');
            this.fExcludedClass=[];
            this.fCandidateInfo=struct('Class',{},'HasThis',{},'MaskParamType',{},'MemberFcns',{},'GetFcns',{},'SetFcns',{},'Objects',{},'MemberVars',{},'ConstVars',{});
            this.fWrite2BusTypeMap=containers.Map('KeyType','double','ValueType','char');

            this.fLibCandIdx=cell(size(this.fLibMdls));


            this.cleanup_dsm=onCleanup(@()CleanupFunction(this,taskbasedsortingfv));
        end

        errMsg=identify(this);
        errMsg=eliminate(this,listForTest,mode);
        errMsg=modelgen(this);
        errMsg=performXformation(this);
        this=setCandidatesIndex(this,wishList);
        this=setPrefix(this,prefixStr);
        this=includeCandidateIndex(this,candidateIndex);
        this=excludeCandidateIndex(this,candidateIndex);
        initializeModelGen(this);
        brokenLinks=deactivateLibBlkwithCandidate(this);
        errMsg=generateMdls(this);
        xformSpecificInit(this);
        xformSpecificPostProc(this);
        setBlockPosition(this,blkPath,refPath,gap,ori);
        replaceByTerminator(this,newWritePath,newNtwPath,drivingPortStr,termStr);
        replaceByConstant(this,newRead,newNtwPath,newMemory);
        addBusSelector(this,newFullPath,elementName);
        addBusCreator(this,newFullPath,numIn,dataTypeStr);
        addLine(this,oldNtwPath,srcPortStr,dstPortStr,isSrcParentSubsys,isDstParentSubsys);
        muteDebugPrints(this);
        dispMsg(this,aMsg);
        result=hasSelectedCandidates(this);
        result=hasIdentifiedCandidates(this);
    end

    methods(Access='private')

        function CleanupFunction(m2mObj,taskbasedsortingfv)

            slfeature('TaskBasedSorting',taskbasedsortingfv)
        end
    end
end


function mdlName=initGenModels(mdl)

    mdlName=mdl;



    [listMdlRef,~]=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'IncludeProtectedModels',false,'IncludeCommented','off','IgnoreVariantErrors',1);

    for i=1:length(listMdlRef)
        refMdlName=listMdlRef{i};
        if strcmp(refMdlName,mdl)
            save_system(refMdlName);
            outMdlFile=['gen_',refMdlName];
            save_system(refMdlName,outMdlFile);
            Simulink.BlockDiagram.deleteContents(outMdlFile);
            open_system(refMdlName);
            continue
        end
        if isempty(find_system(refMdlName,'flat'))
            load_system(refMdlName);
        end
        shadow=find_system(refMdlName,'SearchDepth',1,'BlockType','InportShadow');
        delete_block(shadow);
        Simulink.BlockDiagram.deleteContents(refMdlName);

        outMdlFile=['gen_',refMdlName];
        save_system(refMdlName,outMdlFile);

        load_system(refMdlName);
    end


end









function newFileName=preprocessForBosch(sys)

    topMdlHandle=get_param(bdroot(sys),'handle');
    fileName=getfullname(topMdlHandle);
    fileFolder=fileparts(get_param(topMdlHandle,'filename'));
    newFileName=['prep_',fileName];
    fileFullName=[fileFolder,filesep,newFileName];
    newFileFullName=save_system(topMdlHandle,fileFullName);

    topMdlHandle=get_param(bdroot(newFileName),'handle');


    disp('Masked subsystems with only data store read plus outport or data store write plus inport are replaced by data store read or data store write blocks.');
    numOfReplacement=replaceMaskedRWBlocks(topMdlHandle);
    disp('**************************')
    disp([num2str(numOfReplacement),' such masked subsystems are replaced.']);


end

function numOfReplacement=replaceMaskedRWBlocks(topMdlHandle)





    replaceCandidate=find_system(topMdlHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'findall','on','lookundermasks','all','followlinks','on','BlockType','SubSystem');

    numOfReplacement=0;

    for i=1:length(replaceCandidate)
        set_param(replaceCandidate(i),'LinkStatus','none');


        childrenList=find_system(replaceCandidate(i),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'findall','on','lookundermasks','all','followlinks','on','type','block');
        if(length(childrenList)==3)
            foundSubSystem=false;
            foundDataStoreRead=false;
            foundDataStoreWrite=false;
            foundOutport=false;
            foundInport=false;
            for j=1:3
                blockType=get_param(childrenList(j),'blocktype');
                switch blockType
                case 'SubSystem'
                    foundSubSystem=true;
                case 'DataStoreRead'
                    foundDataStoreRead=true;
                    newBlock=childrenList(j);
                case 'DataStoreWrite'
                    foundDataStoreWrite=true;
                    newBlock=childrenList(j);
                case 'Outport'
                    foundOutport=true;
                case 'Inport'
                    foundInport=true;
                end
            end
            if(foundSubSystem&&...
                ((foundOutport&&foundDataStoreRead)||(foundInport&&foundDataStoreWrite)))
                replaceDSMask(replaceCandidate(i),newBlock);
                numOfReplacement=numOfReplacement+1;
            end
        end
    end
end


function replaceDSMask(old,new)




    copy=add_block(new,[get_param(old,'parent'),'/',get_param(new,'name')],'MakeNameUnique','on');
    oldPos=get_param(old,'Position');
    set_param(copy,'Position',oldPos);
    set_param(copy,'Tag',get_param(old,'Tag'));
    set_param(copy,'Priority',get_param(old,'Priority'));


    connectivity=get_param(old,'PortConnectivity');
    portHandle=get_param(old,'PortHandles');



    if strcmp(get_param(new,'BlockType'),'DataStoreRead')
        n=length(connectivity.DstBlock);
        srcPort=portHandle.Outport;
        copy_portHandles=get_param(copy,'porthandles');
        copy_srcPort=copy_portHandles.Outport;
        for i=1:n
            if(connectivity.DstBlock(i)==-1)
                break
            end
            dstPortHandles=get_param(connectivity.DstBlock(i),'porthandles');
            dstPort=dstPortHandles.Inport(connectivity.DstPort(i)+1);
            delete_line(get_param(old,'parent'),srcPort,dstPort);
            add_line(get_param(old,'parent'),copy_srcPort,dstPort,'autorouting','smart');
        end
    elseif strcmp(get_param(new,'BlockType'),'DataStoreWrite')
        n=length(connectivity.SrcBlock);
        dstPort=portHandle.Inport;
        copy_portHandles=get_param(copy,'porthandles');
        copy_dstPort=copy_portHandles.Inport;
        for i=1:n
            if(connectivity.SrcBlock(i)==-1)
                break
            end
            srcPortHandles=get_param(connectivity.SrcBlock(i),'porthandles');
            srcPort=srcPortHandles.Outport(connectivity.SrcPort(i)+1);
            delete_line(get_param(old,'parent'),srcPort,dstPort);
            add_line(get_param(old,'parent'),srcPort,copy_dstPort,'autorouting','smart');
        end
    end


    delete_block(old);
end


