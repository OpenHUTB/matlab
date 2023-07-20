function specialBlockInfoStructsVec=i_checkAndPopulateSpecialBlockInfo(compSpecialBlockPath,specialBlockInfoStructsVec,specialBlockInfo,varargin)

















    if nargin==4
        blockPath=varargin{1};
    else
        blockPath=compSpecialBlockPath;
    end

    idx=Simulink.variant.reducer.utils.searchNameInCell(blockPath,{specialBlockInfoStructsVec.BlockPath});

    if isempty(idx)







        specialBlockInfoStruct=copy(specialBlockInfo);
        specialBlockInfoStruct.BlockPath=blockPath;
        specialBlockInfoStructsVec(end+1)=specialBlockInfoStruct;

    else


        specialBlockInfoStruct=specialBlockInfoStructsVec(idx);
        specialBlockInfoStruct.ActiveInputPortNumbers=unique(...
        [specialBlockInfoStruct.ActiveInputPortNumbers;...
        specialBlockInfo.ActiveInputPortNumbers]);
        specialBlockInfoStruct.ActiveOutputPortNumbers=unique(...
        [specialBlockInfoStruct.ActiveOutputPortNumbers;...
        specialBlockInfo.ActiveOutputPortNumbers]);


        if numel(specialBlockInfoStruct.ActiveInputPortNumbers)>1...
            ||numel(specialBlockInfoStruct.ActiveOutputPortNumbers)>1
            specialBlockInfoStruct.Operation='prune';
            specialBlockInfoStruct.ReplacedBlock='';
        else

            specialBlockInfoStruct.Operation='replace';


            Simulink.variant.reducer.utils.assert(...
            strcmp(specialBlockInfoStruct.ReplacedBlock,...
            specialBlockInfo.ReplacedBlock));
        end
        specialBlockInfoStructsVec(idx)=specialBlockInfoStruct;
    end
end


