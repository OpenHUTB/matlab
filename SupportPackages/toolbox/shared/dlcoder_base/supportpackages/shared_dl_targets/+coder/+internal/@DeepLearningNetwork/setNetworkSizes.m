%#codegen







function setNetworkSizes(obj,height,width,channels,miniBatchSize,batchSize,callerFunction)




    coder.allowpcode('plain');


    newInputSize=coder.const([height,width,channels,miniBatchSize]);

    oldInputSize=coder.internal.getprop_if_defined(obj.CodegenInputSizes);
    if~isempty(oldInputSize)





        coder.internal.assert(coder.const(@isequal,oldInputSize{1}(4),newInputSize(4)),...
        'dlcoder_spkg:cnncodegen:VaryingMiniBatchSize',...
        newInputSize(4),...
        oldInputSize{1}(4),...
callerFunction...
        );
    end

    obj.CodegenInputSizes={newInputSize};



    newBatchSize=coder.const(batchSize);

    oldBatchSize=coder.internal.getprop_if_defined(obj.BatchSize);
    if~isempty(oldBatchSize)

        coder.internal.assert(coder.const(@isequal,oldBatchSize,newBatchSize),...
        'dlcoder_spkg:cnncodegen:VaryingBatchSize',...
        oldBatchSize,...
        newBatchSize,...
callerFunction...
        );
    end

    obj.BatchSize=newBatchSize;



    obj.setAnchor();


    obj.setNetworkInfo();





    if~isequal(newInputSize,oldInputSize)||~isequal(newBatchSize,oldBatchSize)
        obj.validate();
    end




    obj.setCustomLayerProperties();

end
