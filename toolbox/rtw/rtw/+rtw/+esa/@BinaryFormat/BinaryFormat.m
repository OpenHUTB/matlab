classdef BinaryFormat<handle










    properties(GetAccess='protected',SetAccess='protected')
        FileMap;
        NeedByteSwap;
    end




    methods(Abstract=true,Access='public')






        symbols=getSymbolTable(~)

    end




    methods(Static=true,Access='protected',Sealed=true)




        function needByteSwap=isByteSwapNeeded(fileIsBigEndian)
            needByteSwap=false;
            [~,~,endian]=computer;
            if((upper(endian)=='L'&&fileIsBigEndian)||...
                (upper(endian)=='B'&&~fileIsBigEndian))
                needByteSwap=true;
            end
        end





        function swappedData=doByteSwap(fileMapData)
            if(isstruct(fileMapData))
                swappedData=fileMapData;
                fnames=fieldnames(fileMapData);
                for ctr=1:numel(fileMapData)
                    for f=1:numel(fnames)
                        swappedData(ctr).(fnames{f})=...
                        rtw.esa.BinaryFormat.doByteSwap(fileMapData(ctr).(fnames{f}));
                    end
                end
            elseif(iscell(fileMapData))
                swappedData=cell(size(fileMapData));
                for ctr=1:numel(fileMapData)
                    if(isnumeric(fileMapData{ctr}))
                        swappedData{ctr}=swapbytes(fileMapData{ctr});
                    else
                        swappedData{ctr}=...
                        rtw.esa.BinaryFormat.doByteSwap(fileMapData{ctr});
                    end
                end
            elseif(ischar(fileMapData))
                swappedData=fileMapData;
            else
                swappedData=swapbytes(fileMapData);
            end
        end

    end

end
