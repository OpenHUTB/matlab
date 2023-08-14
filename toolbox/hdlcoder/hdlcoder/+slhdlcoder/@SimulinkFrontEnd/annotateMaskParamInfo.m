function annotateMaskParamInfo(this,maskInfo,hChildNetwork,hNtwkInstComp,foundPirNtwkForSS)



    if nargin<5
        foundPirNtwkForSS=false;
    end
    if nargin<4
        hNtwkInstComp=[];
    end

    if~isempty(maskInfo)
        if~foundPirNtwkForSS

            for ii=1:length(maskInfo)
                param=maskInfo{ii};
                genericName=param.Name;
                genericValue=convertMaskValueToInt(param.Value);
                genericDataType=param.DataType;
                hChildNetwork.addGenericPort(genericName,genericValue,genericDataType);


                useCases=param.UseCases;
                for jj=1:length(useCases)
                    usecase=useCases{jj};

                    hC=this.findComponentUnderNetwork(hChildNetwork,usecase.BlockHandle);

                    if~isempty(hC)
                        hC.addGenericPort(genericName,genericValue,genericDataType);
                    end
                end
            end
        end



        if~isempty(hNtwkInstComp)
            for ii=1:length(maskInfo)
                param=maskInfo{ii};
                genericName=param.Name;
                genericValue=convertMaskValueToInt(param.Value);
                genericDataType=param.DataType;
                hNtwkInstComp.addGenericPort(genericName,genericValue,genericDataType);
            end
        end
    end
end
