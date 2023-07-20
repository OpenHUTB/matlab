function[CbpreAddOutSig,CrpreAddOutSig,preAddLatency,coeffsUniqueAbsNonZero]=elabFIRPreAdder(...
    this,filterKernelNet,coeffsUniqueAbsNonZero,nonZeroCoeffs,CbnonZeroTapOutSig,CrnonZeroTapOutSig)








    coeffsNum=numel(coeffsUniqueAbsNonZero);
    preAddLatency=zeros(1,coeffsNum);

    for ii=1:coeffsNum
        coeffVal=coeffsUniqueAbsNonZero(ii);

        coeffValSymIndex=(nonZeroCoeffs==coeffVal);
        coeffValAntiSymIndex=(nonZeroCoeffs==(-1*coeffVal));
        numSymRepetitions=sum(sum(coeffValSymIndex));
        numAntiSymRepetitions=sum(sum(coeffValAntiSymIndex));
        numRepetitions=numSymRepetitions+numAntiSymRepetitions;
        if numRepetitions==1
            CbpreAddOutSig(ii)=...
            [CbnonZeroTapOutSig(coeffValSymIndex),CbnonZeroTapOutSig(coeffValAntiSymIndex)];%#ok
            CrpreAddOutSig(ii)=...
            [CrnonZeroTapOutSig(coeffValSymIndex),CrnonZeroTapOutSig(coeffValAntiSymIndex)];%#ok
            if numAntiSymRepetitions>numSymRepetitions

                coeffsUniqueAbsNonZero(ii)=-1*coeffsUniqueAbsNonZero(ii);
            end
            continue;
        end



        if numAntiSymRepetitions>numSymRepetitions

            coeffsUniqueAbsNonZero(ii)=-1*coeffsUniqueAbsNonZero(ii);

            tmpVal=coeffValSymIndex;
            coeffValSymIndex=coeffValAntiSymIndex;
            coeffValAntiSymIndex=tmpVal;
        end

        preAddLatency(ii)=ceil(log2(numRepetitions))+1;



        CbpreAddInSym=CbnonZeroTapOutSig(coeffValSymIndex);
        CbpreAddInASym=CbnonZeroTapOutSig(coeffValAntiSymIndex);
        CbsigNamePrefix=['CbpreAdd',num2str(ii)];

        CbpreAddOutSig(ii)=this.elabAdderTree(filterKernelNet,...
        CbpreAddInSym,CbpreAddInASym,...
        CbsigNamePrefix,'PreAdder (along Cb data path)');%#ok

        CrpreAddInSym=CrnonZeroTapOutSig(coeffValSymIndex);
        CrpreAddInASym=CrnonZeroTapOutSig(coeffValAntiSymIndex);
        CrsigNamePrefix=['CrpreAdd',num2str(ii)];

        CrpreAddOutSig(ii)=this.elabAdderTree(filterKernelNet,...
        CrpreAddInSym,CrpreAddInASym,...
        CrsigNamePrefix,'PreAdder (along Cr data path)');%#ok

    end

end
