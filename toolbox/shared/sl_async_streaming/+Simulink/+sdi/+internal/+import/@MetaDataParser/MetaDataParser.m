classdef MetaDataParser<handle




    methods
        reset(this,sigNames,colIndices)
        parseRow(this,sigIdx,str,bCheckIfAlreadySet)

        val=getNumberOfSignals(this)
        sig=constructSignalFromMetaData(this,sigIdx)
        ds=constructDatasetFromMetaData(this)
        md=getSignalMetadata(this,idx)
    end

    methods(Static)
        ret=getMetaDataProperties()
    end

    properties(Access=private)
ParsedValues
    end
end