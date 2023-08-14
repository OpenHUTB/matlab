function utilAutoSharingFactor(h,ssp,algorithmDataType,nfpConfigSettings,partNumber)




    hdlSubsystems=numel(h);


    if strcmpi(algorithmDataType,'MixedDoubleSingle')
        dataType='double';
    else
        dataType=algorithmDataType;
    end

    mantissaMulStrat=nfpConfigSettings.LibrarySettings.MantissaMultiplyStrategy;
    latencyStrategy=nfpConfigSettings.LibrarySettings.LatencyStrategy;

    if strcmpi(mantissaMulStrat,'Auto')
        mantissaMulStrat='FullMultiplier';
    end
    sharingFactor=0;%#ok<NASGU>
    totalAdders_ss=0;
    totalMuls_ss=0;


    for i=1:hdlSubsystems
        stateSpaceParameters(i)=ssp(i);
        stateSpaceParametersVarName{i}=strcat(utilGetVarName(stateSpaceParameters),'_',num2str(i));
        eval([stateSpaceParametersVarName{i},'= stateSpaceParameters(i);']);

        Bd1=ones(size(stateSpaceParameters(i).Bd),dataType);
        Bd=cast(stateSpaceParameters(i).Bd,'like',Bd1);

        X0d1=ones(size(stateSpaceParameters(i).X0),dataType);
        X=cast(stateSpaceParameters(i).X0,'like',X0d1);

        Ad=stateSpaceParameters(i).Ad;
        Cd=stateSpaceParameters(i).Cd;
        Dd=stateSpaceParameters(i).Dd;
        Fd=stateSpaceParameters(i).F0d;
        Yd=stateSpaceParameters(i).Y0d;

        numOfSwitchingModes=stateSpaceParameters(i).NumberOfSwitchingModes;
        U=ones(size(Bd,2));
        U=cast(U,lower(dataType));
        if isempty(U)
            U=cast(1,lower(dataType));
        end
        if isempty(X)
            X=cast(1,lower(dataType));
        end

        computeModeFcn=stateSpaceParameters(i).ComputeSwitchingMode;






        sysName=find_system(getfullname(h(i)),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','hdlssclib/NFPSparseConstMultiply');
        sharingFactor=1;
        parMuls=0;
        parAdds=0;
        for k=1:size(sysName)
            constMatrix=hdlslResolve('constMatrix',get_param(sysName{k},'handle'));
            if(ischar(constMatrix))
                constMatrix=eval(constMatrix);
            end
            fullyParallel=1;
            [parMuls(k),parAdds(k)]=getMatMultBlkResCnt((constMatrix),fullyParallel,sharingFactor);
        end
        totaldpParMuls=sum(parMuls);
        totaldpParAdds=sum(parAdds);


        sumBlkAddersCnt_State=getAddersOfSumBlk(Ad,Bd,Fd);
        sumBlkAddersCnt_output=getAddersOfSumBlk(Cd,Dd,Yd);
        totalSumBlkAdders=sumBlkAddersCnt_State+sumBlkAddersCnt_output;

        if~isempty(computeModeFcn)&&numOfSwitchingModes>1

            MlBlkInfo=utilGetMatlabFunBlkInfo(computeModeFcn,U,X,nfpConfigSettings);%#ok<ASGLU>
        else
            MlBlkInfo.mlfbBlkLatency=0;
            MlBlkInfo.mlfbAdds=0;
            MlBlkInfo.mlfbMuls=0;
            MlBlkInfo.failed=0;
        end

        totalAdders_ss(i)=MlBlkInfo.mlfbAdds+totaldpParAdds+totalSumBlkAdders;
        totalMuls_ss(i)=MlBlkInfo.mlfbMuls+totaldpParMuls;
    end

    totalAadders=sum(totalAdders_ss);
    totalMuls=sum(totalMuls_ss);



    [slicePerAdd,regPer,slicePerMul,utilDSPPerMul]=getResourceUtilInfo(dataType,latencyStrategy,mantissaMulStrat);



    totalSliceUtilPercent=(slicePerAdd*totalAadders)+(slicePerMul*totalMuls);
    totalDSPUtilPercent=utilDSPPerMul*totalMuls;




    if((totalSliceUtilPercent>60)||(totalDSPUtilPercent>60))

        for kk=1:hdlSubsystems
            stateSpaceParameters(kk)=ssp(kk);
            stateSpaceParametersVarName{kk}=strcat(utilGetVarName(stateSpaceParameters),'_',num2str(kk));
            eval([stateSpaceParametersVarName{kk},'= stateSpaceParameters(kk);']);





            sysName=find_system(getfullname(h(kk)),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','hdlssclib/NFPSparseConstMultiply');
            sharingFactorMuls(1:size(sysName))=0;
            sharingFactorAdds(1:size(sysName))=0;
            for j=1:size(sysName)
                constMatrix=hdlslResolve('constMatrix',get_param(sysName{j},'handle'));
                if(ischar(constMatrix))
                    constMatrix=eval(constMatrix);
                end
                fullyParallel=0;
                sharingFactor=1;
                [sharingFactorMuls(j),sharingFactorAdds(j)]=getMatMultBlkResCnt((constMatrix),fullyParallel,sharingFactor);
            end


            totaldpSFMuls=sum(sharingFactorMuls);
            totaldpSFAdds=sum(sharingFactorAdds);



            desiredSliceUtilPercent=30;


            totaldpSFAddsForDesiredUtil=ceil(desiredSliceUtilPercent/(slicePerAdd+slicePerMul));
            desiredSF(1)=ceil(totaldpSFAdds/totaldpSFAddsForDesiredUtil);

            desiredDSPUtilPercent=30;
            totaldpSFMulssForDesiredUtil=ceil(desiredDSPUtilPercent/utilDSPPerMul);
            desiredSF(2)=ceil(totaldpSFMuls/totaldpSFMulssForDesiredUtil);
            sharingFactor=max(desiredSF);

            for jj=1:size(sysName)
                hdlset_param(sysName,'SharingFactor',sharingFactor);
            end
        end
    end
end



function[numMatMuls,numMatAdds]=getMatMultBlkResCnt(constMatrix,fullyParallel,sharingFactor)


    [activeElements,activeRowPositions,activeColumnPositions]=sschdloptimizations.getActiveElements(constMatrix,1);

    numRows=size(constMatrix,1);
    numCols=size(constMatrix,2);
    if(fullyParallel)

        numMatMuls=numel(activeElements{1});
        decrementRowCnt=0;
        for cp=1:numel(activeColumnPositions)
            if(size(activeColumnPositions{cp},2)==0)
                decrementRowCnt=decrementRowCnt+1;
            end
        end
        effectiveNumRows=numRows-decrementRowCnt;
        numMatAdds=0;
        if~(numel(activeElements{1})<effectiveNumRows)
            numMatAdds=numel(activeElements{1})-effectiveNumRows;
        end
    else



        maxRowElements=0;
        for ii=1:numel(activeRowPositions)
            rowElements=activeRowPositions{ii};
            if(numel(rowElements)>maxRowElements)
                maxRowElements=numel(rowElements);
            end
        end
        activeColsPerRow=zeros(numRows,numCols);
        for ridx=1:numRows
            activeColsPerRow(ridx,1:size((activeColumnPositions{ridx}),2))=activeColumnPositions{ridx};
        end
        activeCols=nnz(unique(activeColsPerRow));

        effDotProd=ceil(numRows/sharingFactor);
        numMatMuls=effDotProd*activeCols;
        numMatAdds=effDotProd*(activeCols-1);
    end

end



function sumBlkAddersCnt=getAddersOfSumBlk(ConstMat1,ConstMat2,ConstMat3)
    Addcount=0;
    rowCnt(1:3)=0;

    sumBlkAddersCnt=0;
    if nnz(ConstMat1)>0
        [rowCnt(1),~,~]=size(ConstMat1);
        Addcount=Addcount+1;
    end
    if nnz(ConstMat2)>0
        [rowCnt(2),~,~]=size(ConstMat2);
        Addcount=Addcount+1;
    end
    if nnz(ConstMat3)>0
        [rowCnt(3),~,~]=size(ConstMat3);
        Addcount=Addcount+1;
    end
    if(Addcount>0)
        numRowCnt=max(rowCnt);
        sumBlkAddersCnt=numRowCnt*(Addcount-1);
    end
end
function[slicePerAdd,regPer,slicePerMul,utilDSPPerMul]=getResourceUtilInfo(dataType,latencyStrategy,mantissaMulStrat)%#ok<*INUSD,*INUSL>
    addCompStrcut=resourceTableForAdd();
    addResList=struct2table(addCompStrcut);
    sliceForOneAdd=addResList.Slices(strcmpi(addResList.LatencyStrategy,latencyStrategy)&strcmpi(addResList.DataType,dataType));
    maxSlicesOnChip=addResList.MaxSlices(1,1);
    slicePerAdd=(sliceForOneAdd/maxSlicesOnChip)*100;
    regForOneAdd=addResList.SliceRegs(strcmpi(addResList.LatencyStrategy,latencyStrategy)&strcmpi(addResList.DataType,dataType));
    maxRegOnChip=addResList.MaxSliceRegs(1,1);
    regPer=(regForOneAdd/maxRegOnChip)*100;

    mulCompStruct=resourceTableForMul();
    mulResList=struct2table(mulCompStruct);
    sliceForOneMul=mulResList.Slices(strcmpi(mulResList.LatencyStrategy,latencyStrategy)&strcmpi(mulResList.DataType,dataType)&strcmpi(mulResList.MMS,mantissaMulStrat));
    slicePerMul=(sliceForOneMul/maxSlicesOnChip)*100;
    utilDSPForOneMul=mulResList.DSPs(strcmpi(mulResList.LatencyStrategy,latencyStrategy)&strcmpi(mulResList.DataType,dataType)&strcmpi(mulResList.MMS,mantissaMulStrat));
    maxDSPsOnChip=mulResList.MaxDSPs(1,1);
    utilDSPPerMul=(utilDSPForOneMul/maxDSPsOnChip)*100;
end


function addResList=resourceTableForAdd()

    lEntry.CompName='Add';lEntry.DataType='SINGLE';lEntry.LatencyStrategy='MIN';lEntry.Slices=90;lEntry.MaxSlices=50950;lEntry.SliceRegs=286;lEntry.MaxSliceRegs=4.076e+05;addResList=lEntry;
    lEntry.CompName='Add';lEntry.DataType='SINGLE';lEntry.LatencyStrategy='MAX';lEntry.Slices=119;lEntry.MaxSlices=50950;lEntry.SliceRegs=418;lEntry.MaxSliceRegs=4.076e+05;addResList(end+1)=lEntry;
    lEntry.CompName='Add';lEntry.DataType='DOUBLE';lEntry.LatencyStrategy='MIN';lEntry.Slices=180;lEntry.MaxSlices=50950;lEntry.SliceRegs=546;lEntry.MaxSliceRegs=4.076e+05;addResList(end+1)=lEntry;
    lEntry.CompName='Add';lEntry.DataType='DOUBLE';lEntry.LatencyStrategy='MAX';lEntry.Slices=199;lEntry.MaxSlices=50950;lEntry.SliceRegs=810;lEntry.MaxSliceRegs=4.076e+05;addResList(end+1)=lEntry;
end

function mulResList=resourceTableForMul()
    lEntry.Name='Mul';lEntry.DataType='SINGLE';lEntry.LatencyStrategy='MIN';lEntry.Slices=73;lEntry.MaxSlices=50950;lEntry.MMS='FullMultiplier';lEntry.DSPs=2;lEntry.MaxDSPs=840;mulResList=lEntry;
    lEntry.Name='Mul';lEntry.DataType='SINGLE';lEntry.LatencyStrategy='MAX';lEntry.Slices=92;lEntry.MaxSlices=50950;lEntry.MMS='FullMultiplier';lEntry.DSPs=2;lEntry.MaxDSPs=840;mulResList(end+1)=lEntry;
    lEntry.Name='Mul';lEntry.DataType='SINGLE';lEntry.LatencyStrategy='MIN';lEntry.Slices=136;lEntry.MaxSlices=50950;lEntry.MMS='PartMultiplierPartAddShift';lEntry.DSPs=1;lEntry.MaxDSPs=840;mulResList(end+1)=lEntry;
    lEntry.Name='Mul';lEntry.DataType='SINGLE';lEntry.LatencyStrategy='MAX';lEntry.Slices=144;lEntry.MaxSlices=50950;lEntry.MMS='PartMultiplierPartAddShift';lEntry.DSPs=1;lEntry.MaxDSPs=840;mulResList(end+1)=lEntry;
    lEntry.Name='Mul';lEntry.DataType='DOUBLE';lEntry.LatencyStrategy='MIN';lEntry.Slices=192;lEntry.MaxSlices=50950;lEntry.MMS='FullMultiplier';lEntry.DSPs=9;lEntry.MaxDSPs=840;mulResList(end+1)=lEntry;
    lEntry.Name='Mul';lEntry.DataType='DOUBLE';lEntry.LatencyStrategy='MAX';lEntry.Slices=237;lEntry.MaxSlices=50950;lEntry.MMS='FullMultiplier';lEntry.DSPs=9;lEntry.MaxDSPs=840;mulResList(end+1)=lEntry;
end

