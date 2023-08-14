function data=loadFile(fileName,varargin)




    tempData=load(fileName);

    if(nargin>1)
        modelName=varargin{1};
        newDesignChecksum=incrementalcodegen.IncrementalCodeGenDriver.hashEntireDesign(modelName,...
        @qoroptimizations.getModelGenStatusDataForOptimization);
        if(~isequal(tempData.designChecksum,newDesignChecksum))
            error(message('hdlcoder:optimization:ChecksumMismatch'));
        end
    end

    data=rmfield(tempData,'designChecksum');
end