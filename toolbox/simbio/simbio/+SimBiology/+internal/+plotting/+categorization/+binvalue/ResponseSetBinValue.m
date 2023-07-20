classdef ResponseSetBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue

    properties(Access=public)
        responseBinValues=SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue.empty;
    end


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.ResponseSetBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.ResponseSetBinValue;
        end

        function configureSingleObjectFromStruct(obj,value)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj,value);
            set(obj,'responseBinValues',SimBiology.internal.plotting.categorization.binvalue.ResponseBinValue(value.responseBinValues));
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.RESPONSE_SET;
        end
    end


    methods(Access=public)
        function flag=isEqual(obj,comparisonObj,useDataSource)
            if ischar(comparisonObj)
                flag=strcmp({obj.value},comparisonObj);
            else
                flag=strcmp({obj.value},comparisonObj.value);
            end
        end

        function flag=isMatchDataSeries(obj,singleDataSeries,categoryVariable,useDataSource)

        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            name=obj.value;
        end
    end

    methods(Access=protected)
        function bin=getStructForSingleObject(obj)
            bin=getStructForSingleObject@SimBiology.internal.plotting.categorization.binvalue.BinValue(obj);
            bin.responseBinValues=obj.responseBinValues.getStruct;
        end
    end


    methods(Access=public)
        function responseSetBin=getResponseSetBinForResponse(obj,responseBinValue,useDataSource)
            responseSetBin=SimBiology.internal.plotting.categorization.ResponseSetBinValue.empty;
            for i=1:numel(obj)
                if obj(i).responseBinValues.includes(responseBinValue,useDataSource)
                    responseSetBin=obj(i);
                    break;
                end
            end
        end

        function flag=includesResponse(obj,responseBinValue,useDataSource)
            flag=arrayfun(@(bin)bin.responseBinValues.includes(responseBinValue,useDataSource),obj);
        end

        function unmatchedResponseBins=updateForResponses(obj,responseBinValues)
            responseUnmatched=true(size(responseBinValues));
            for b=1:numel(obj)
                match=false(size(obj(b).responseBinValues));
                for i=numel(obj(b).responseBinValues):-1:1
                    for j=1:numel(responseBinValues)
                        if obj(b).responseBinValues(i).isEqual(responseBinValues(j))
                            responseUnmatched(j)=false;
                            match(i)=true;
                            break;
                        end
                    end
                end
                obj(b).responseBinValues=obj(b).responseBinValues(match);
            end
            unmatchedResponseBins=responseBinValues(responseUnmatched);
        end

        function flag=areResponsesEmpty(obj)
            flag=arrayfun(@(bin)isempty(bin.responseBinValues),obj);
        end

        function name=createNewResponseSetName(obj)
            existingNames=arrayfun(@(bin)bin.value,obj,'UniformOutput',false);
            name=SimBiology.web.codegenerationutil('findUniqueNameUsingDelimiter',existingNames,'Set',' ',true);
        end
    end
end