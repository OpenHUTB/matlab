classdef RepresentableBinCalculator<handle
















    properties(Constant,Hidden)
        DATA=SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.initializeData()






        CAPACITY=500

        STORE=SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.initializeStore()
    end

    properties(SetAccess=private,Hidden)
        Cache=containers.Map('KeyType','char','ValueType','any')%#ok<MCHDP>
    end

    methods
        function representableBins=getBinsForNumerictype(this,dataType)





            representableBins=double.empty(1,0);
            if isempty(dataType)||dataType.isscalingunspecified
                return
            end
            key=this.getKey(dataType);
            if this.Cache.isKey(key)
                validIndices=this.Cache(key);
            elseif SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.STORE.isKey(key)

                validIndices=SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.STORE(key);
            else

                if this.Cache.Count==this.CAPACITY
                    indexToRemove=randi(this.Cache.Count);
                    keys=this.Cache.keys();
                    this.Cache.remove(keys{indexToRemove});
                end
                if dataType.Bias==0&&dataType.SlopeAdjustmentFactor==1






                    validIndices=false(1,numel(this.DATA.Bins));
                    startIndex=max(1075+dataType.FixedExponent,1);
                    endIndex=min(1074+dataType.FixedExponent+dataType.WordLength,2098);
                    indices=startIndex:endIndex;
                    validIndices(indices)=true;
                else









































                    castedValues=abs(double(fi(SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.DATA.ToCast,dataType)));
                    validIndices=any((castedValues>=SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.DATA.Intervals(1,:))&...
                    (castedValues<=SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.DATA.Intervals(2,:)),1);
                end
                this.Cache(key)=validIndices;
            end
            representableBins=SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator.DATA.Bins(validIndices);
        end

        function representableBins=getBinsForAnyDataType(this,dt)


            try
                dataType=fixed.internal.type.extractNumericType(dt);
            catch
                dataType=[];
            end
            representableBins=getBinsForNumerictype(this,dataType);
        end
    end

    methods(Static,Hidden)
        function data=initializeData()


            log2RepresentableBin=-1074:1023;
            lowerBound=2.^log2RepresentableBin;




            upperBoundInclusive=ones(size(lowerBound));
            upperBoundInclusive(1:52)=lowerBound(1:52).*(2-2.^(0:-1:-51));
            upperBoundInclusive(53:end)=lowerBound(53:end)*(2-2^-52);
            intervals=[lowerBound;upperBoundInclusive];
            midPoints=sum(intervals)/2;
            midPoints(end)=(intervals(1,end)/2+intervals(2,end)/2);
            valuesToCast=[midPoints;-midPoints];
            data=struct('Bins',log2RepresentableBin,'Intervals',intervals,'ToCast',valuesToCast);
        end

        function store=initializeStore()



            store=containers.Map('KeyType','char','ValueType','any');
            keyValuePairs={
            'double',-1074:1023;
            'single',-149:127;
            'half',-24:15;
            'boolean',0;
            'uint8',0:7;
            'int8',0:7;
            'uint16',0:15;
            'int16',0:15;
            'uint32',0:31;
            'int32',0:31;
            'uint64',0:63;
            'int64',0:63;
            };
            keys=keyValuePairs(:,1);
            values=keyValuePairs(:,2);
            logicals=false(1,2098);
            for iKey=1:numel(keys)
                v=logicals;
                v(values{iKey}+1075)=true;
                store(keys{iKey})=v;
            end
        end

        function key=getKey(dataType)


            key=dataType.tostringInternalSlName;
        end
    end
end

