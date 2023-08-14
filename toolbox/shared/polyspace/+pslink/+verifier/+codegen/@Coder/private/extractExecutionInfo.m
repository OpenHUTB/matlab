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
    if strcmpi(self.configInfo.TargetLang,'C++')...
        &&isprop(self.configInfo,'CppInterfaceStyle')...
        &&strcmpi(self.configInfo.CppInterfaceStyle,'Methods')
        className=self.configInfo.CppInterfaceClassName;
    end



    if self.mustWriteAllData
        return
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


