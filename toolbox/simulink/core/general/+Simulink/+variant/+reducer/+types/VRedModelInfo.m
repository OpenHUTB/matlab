classdef(Hidden,Sealed)VRedModelInfo<handle




    properties



        OrigName(1,:)char;
        Name(1,:)char;
        IsProtected(1,1)logical;
        FullPath(1,:)char;
        ConfigInfos=[];
        ModelRefsDataStructsVec(:,1)Simulink.variant.reducer.types.VRedModelRefsData;
        VCDOInfo=[];
        VCDOProxyModelIdx=[];
        FileDependencies=[];
        Variables=[];
        BusObjectNames=[];
    end

    methods
        function delete(obj)
            obj.ModelRefsDataStructsVec=Simulink.variant.reducer.types.VRedModelRefsData.empty;
        end

        function appendModelRefsDataStructsVec(obj,modelRefsDataForConfig)




            for idx=1:numel(modelRefsDataForConfig)
                modelRefData=modelRefsDataForConfig(idx);
                if any(obj.ModelRefsDataStructsVec==modelRefData)


                    continue;
                end
                obj.ModelRefsDataStructsVec(end+1)=modelRefData;
            end
        end
    end
end
