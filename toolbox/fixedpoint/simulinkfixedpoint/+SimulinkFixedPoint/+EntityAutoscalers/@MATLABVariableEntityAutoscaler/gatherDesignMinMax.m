function[min_val,max_val]=gatherDesignMinMax(~,variableIdentifier,varargin)




    min_val=[];
    max_val=[];
    if isequal(variableIdentifier.IsArgin,true)||...
        isequal(variableIdentifier.IsArgout,true)
        functionIdentifier=variableIdentifier.MATLABFunctionIdentifier;
        blockIdentifier=functionIdentifier.BlockIdentifier;
        blkObj=blockIdentifier.getObject;
        if~isempty(blkObj)
            sfDataObject=find(blkObj,...
            '-isa','Stateflow.Data',...
            'Name',variableIdentifier.VariableName);%#ok<GTARG>

            if~isempty(sfDataObject)







                parsedInfo=arrayfun(@(x)sf('DataParsedInfo',x.Id),sfDataObject);


                min_vec=arrayfun(@(x)double(x.range.minimum),parsedInfo);

                min_vec=min_vec(~isnan(min_vec(:))&~isinf(min_vec(:)));


                max_vec=arrayfun(@(x)double(x.range.maximum),parsedInfo);

                max_vec=max_vec(~isnan(max_vec(:))&~isinf(max_vec(:)));


                [minVal,maxVal]=SimulinkFixedPoint.extractMinMax([min_vec;max_vec]);

                if~isempty(minVal)
                    min_val=minVal;
                end
                if~isempty(maxVal)
                    max_val=maxVal;
                end

            end
        end
    end
end

