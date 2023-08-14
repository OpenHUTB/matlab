function[preAddOutSig,preAddLatency,coeffsUniqueAbsNonZero]=elabFIRPreAdder(...
    this,filterKernelNet,coeffsUniqueAbsNonZero,nonZeroCoeffs,nonZeroTapOutSig)








    coeffsNum=numel(coeffsUniqueAbsNonZero);
    preAddLatency=zeros(1,coeffsNum);

    for ii=1:coeffsNum
        coeffVal=coeffsUniqueAbsNonZero(ii);

        coeffValSymIndex=(nonZeroCoeffs==coeffVal);
        coeffValAntiSymIndex=(nonZeroCoeffs==(-1*coeffVal));
        numSymRepetitions=sum(sum(coeffValSymIndex));
        numAntiSymRepetitions=sum(sum(coeffValAntiSymIndex));
        numRepetitions=numSymRepetitions+numAntiSymRepetitions;
        if numRepetitions==1||numRepetitions==0
            if numRepetitions==1
                preAddOutSig(ii)=...
                [nonZeroTapOutSig(coeffValSymIndex),nonZeroTapOutSig(coeffValAntiSymIndex)];%#ok<AGROW> 
                if numAntiSymRepetitions>numSymRepetitions

                    coeffsUniqueAbsNonZero(ii)=-1*coeffsUniqueAbsNonZero(ii);
                end
                continue;
            else

                coeffDelta=abs(double(nonZeroCoeffs)-(-1*double(coeffsUniqueAbsNonZero(ii))));
                idx=find(coeffDelta==min(coeffDelta));
                coeffsUniqueAbsNonZero(ii)=nonZeroCoeffs(idx);
                preAddOutSig(ii)=nonZeroTapOutSig(idx);%#ok<AGROW> 
                continue
            end
        end



        if numAntiSymRepetitions>numSymRepetitions

            coeffsUniqueAbsNonZero(ii)=-1*coeffsUniqueAbsNonZero(ii);

            tmpVal=coeffValSymIndex;
            coeffValSymIndex=coeffValAntiSymIndex;
            coeffValAntiSymIndex=tmpVal;
        end

        preAddLatency(ii)=ceil(log2(numRepetitions))+1;



        preAddInSym=nonZeroTapOutSig(coeffValSymIndex);
        preAddInASym=nonZeroTapOutSig(coeffValAntiSymIndex);
        sigNamePrefix=['preAdd',num2str(ii)];
        preAddOutSig(ii)=this.elabAdderTree(filterKernelNet,...
        preAddInSym,preAddInASym,...
        sigNamePrefix);%#ok<AGROW> % signal names will be preAdd1_stage1_1 and so on...
    end

end
