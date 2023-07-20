function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok  





    sizeInportNum=length(inportNum);
    sizeOutportNum=length(outportNum);
    totalPortNum=sizeInportNum+sizeOutportNum;

    if totalPortNum==0

        pathItems={};
        return;
    end

    pathItems=cell(sizeInportNum+sizeOutportNum,1);

    for idxin=1:sizeInportNum

        pathItems{idxin}=['Input',int2str(inportNum(idxin))];
    end

    if sizeOutportNum>0
        if isa(blkObj,'Simulink.Probe')
            totalPathItems={};

            if strcmp(blkObj.ProbeWidth,'on')
                totalPathItems{end+1}='Width';
            end
            if strcmp(blkObj.ProbeSampleTime,'on')
                totalPathItems{end+1}='SampleTime';
            end
            if strcmp(blkObj.ProbeComplexSignal,'on')
                totalPathItems{end+1}='SignalComplex';
            end
            if strcmp(blkObj.ProbeSignalDimensions,'on')
                totalPathItems{end+1}='SignalDimension';
            end
            if strcmp(blkObj.ProbeFramedSignal,'on')
                totalPathItems{end+1}='SignalFrame';
            end
        end
    end
    for idxout=1:sizeOutportNum
        if outportNum(idxout)==1
            switch class(blkObj)
            case{'Simulink.Sum',...
                'Simulink.DiscreteFir',...
                'Simulink.AllpoleFilter',...
                'Simulink.DiscreteFilter',...
                'Simulink.DiscreteTransferFcn'}
                pathItems{sizeInportNum+idxout}='Output';
            otherwise
                pathItems{sizeInportNum+idxout}='1';
            end
        else

            pathItems{sizeInportNum+idxout}=int2str(outportNum(idxout));
        end
        if isa(blkObj,'Simulink.Probe')
            pathItems{sizeInportNum+idxout}=totalPathItems{outportNum(idxout)};
        end

    end


