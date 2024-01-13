function[execMap,className]=extractExecutionInfo(self,unused)%#ok<INUSD>

    execMap=containers.Map({1},{{}});
    execMap.remove(1);

    for ii=1:numel(self.codeInfo.TimingProperties)
        key=nGetSampleTimeAsKey(self.codeInfo.TimingProperties(ii));
        if isempty(key)
            continue
        end
        execMap(key)={{},{}};
    end
    if~isempty(self.codeInfo.InitializeFunctions)
        nAddFunctionToMap(self.codeInfo.InitializeFunctions(1),true);
    end
    for ii=1:numel(self.codeInfo.OutputFunctions)
        nAddFunctionToMap(self.codeInfo.OutputFunctions(ii),false);
    end
    for ii=1:numel(self.codeInfo.UpdateFunctions)
        nAddFunctionToMap(self.codeInfo.UpdateFunctions(ii),false);
    end

    className=[];
    for ii=1:numel(self.codeInfo.InternalData)
        currentType=self.codeInfo.InternalData(ii).Implementation.Type;
        if isa(currentType,'coder.types.Class')
            currentType=currentType.getEmbeddedType;
        end
        if isa(currentType,'embedded.classtype')
            className=currentType.Identifier;
            break
        end
    end

    if self.mustWriteAllData
        return
    end

    for ii=1:numel(self.codeInfo.Inports)
        if self.codeInfo.Inports(ii).UsageKind==1
            key=nGetSampleTimeAsKey(self.codeInfo.Inports(ii).Timing);
            if isempty(key)
                self.mustWriteAllData=true;
                return
            end
            exprInCode=nGetExprInCode(self.codeInfo.Inports(ii));
            if isempty(exprInCode)
                self.mustWriteAllData=true;
                return
            end
            if~execMap.isKey(key)
                execMap(key)={{},{}};
            end
            val=execMap(key);
            val{2}=unique([val{2},{exprInCode}]);
            execMap(key)=val;
        end
    end

    if self.mustWriteAllData
        return
    end

    for ii=1:numel(self.codeInfo.DataStores)
        if self.codeInfo.DataStores(ii).UsageKind==1
            key=nGetSampleTimeAsKey(self.codeInfo.DataStores(ii).Timing);
            if isempty(key)
                continue
            end
            exprInCode=nGetExprInCode(self.codeInfo.DataStores(ii));
            if isempty(exprInCode)
                continue
            end
            if~execMap.isKey(-inf)
                execMap(-inf)={{},{}};
            end
            val=execMap(-inf);
            val{2}=unique([val{2},{exprInCode}]);
            execMap(-inf)=val;
        end
    end

    if self.paramFullRange==true||...
        isempty(self.codeInfo.Parameters)||...
        isempty(self.codeInfo.InitializeFunctions)
        return
    end

    for ii=1:numel(self.codeInfo.Parameters)
        if self.codeInfo.Parameters(ii).UsageKind==1
            exprInCode=nGetExprInCode(self.codeInfo.Parameters(ii));
            if isempty(exprInCode)
                continue
            end
            if~execMap.isKey(-inf)
                execMap(-inf)={{},{}};
            end
            val=execMap(-inf);
            val{2}=unique([val{2},{exprInCode}]);
            execMap(-inf)=val;
        end
    end


    function nAddFunctionToMap(fcn,isInit)
        if isempty(fcn.Timing)
            if isInit
                stKey=-inf;
            else
                stKey=-1;
            end
        else
            stKey=nGetSampleTimeAsKey(fcn.Timing);
            if isempty(stKey)
                return
            end
        end
        if~execMap.isKey(stKey)
            execMap(stKey)={{},{}};
        end
        mVal=execMap(stKey);
        mVal{1}=[mVal{1},{fcn.Prototype.Name}];
        execMap(stKey)=mVal;
    end


    function exprInCode=nGetExprInCode(data)
        exprInCode='';
        if data.Implementation.isDefined&&~isa(data.Implementation,'RTW.PointerVariable')
            if isa(data.Implementation,'RTW.Variable')
                exprInCode=data.Implementation.getExpression();
            elseif isa(data.Implementation,'RTW.StructExpression')
                exprInCode=data.Implementation.getBaseVariable.getExpression();
            else

            end
        end
    end


    function key=nGetSampleTimeAsKey(timingProperty)

        if isempty(timingProperty)
            key=[];
            return
        end
        switch timingProperty.TimingMode
        case 'PERIODIC'
            key=timingProperty.SamplePeriod;
        case 'ONESHOT'
            key=-inf;
        case 'INHERITED'
            key=-1;
        case 'ASYNCHRONOUS'
            key=-2;
        case 'CONTINUOUS'
            key=-1;
        otherwise

            key=[];
        end
    end

end


