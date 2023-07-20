function allInDataForTC=getTestCaseData(tcDataVal,inpIdList,inpSizeList,stepValueList)













    modelH=get_param(bdroot(gcs),'Handle');
    numSteps=length(stepValueList);
    [inputPortInfo,~,~]=Sldv.DataUtils.generateIOportInfo(modelH);

    inpCount=length(inpIdList);
    allInDataForTC=cell(inpCount,1);
    try
        for idx=1:inpCount
            inDataForTC=tcDataVal{inpIdList(idx)};
            allInDataForTC{inpIdList(idx)}=getInportData(inDataForTC,inpSizeList(idx),inputPortInfo{idx},numSteps);
        end
    catch
        allInDataForTC=[];
    end

end







































function inportData=getInportData(inData,inpSize,portInfo,numSteps)

    inportData=cell(inpSize,1);

    if iscell(inData)
        nameIdMap=containers.Map;
        nameDataMap=containers.Map;
        isBusArray=iscell(portInfo)&&isfield(portInfo{1},'Dimensions')&&any(portInfo{1}.Dimensions~=1);
        flatInportData(nameIdMap,nameDataMap,inData,portInfo,isBusArray,numSteps);

        keyList=nameIdMap.keys;
        for idx=1:inpSize
            inportData{nameIdMap(keyList{idx})}=nameDataMap(keyList{idx});
        end
    else
        inportData{1}=lower(inData);
    end
end

function flatInportData(interfaceNameIdMap,interfaceNameDataMap,inportTestData,inportInfo,isBusArray,numSteps)

    if~iscell(inportTestData)
        nRows=numel(inportTestData)/numSteps;


        dataValues=lower(reshape(inportTestData,nRows,numSteps));

        if~isKey(interfaceNameDataMap,inportInfo.SignalLabels)
            interfaceNameIdMap(inportInfo.SignalLabels)=1+interfaceNameIdMap.length;
            interfaceNameDataMap(inportInfo.SignalLabels)=dataValues;
        else
            interfaceNameDataMap(inportInfo.SignalLabels)=[interfaceNameDataMap(inportInfo.SignalLabels);dataValues];
        end
    else


        for i=1:numel(inportTestData)
            if isBusArray
                portInfo=inportInfo;
                isChildBusArray=false;
            else
                portInfo=inportInfo{i+1};
                isChildBusArray=false;
                if iscell(portInfo)&&isfield(portInfo{1},'Dimensions')&&any(portInfo{1}.Dimensions~=1)
                    isChildBusArray=true;
                end
            end
            flatInportData(...
            interfaceNameIdMap,interfaceNameDataMap,...
            inportTestData{i},...
            portInfo,...
            isChildBusArray,...
            numSteps);
        end
    end

end





function low=lower(data)
    if isa(data,'double')||isa(data,'single')
        if isreal(data)
            low=compose('%.17g',data);
        else
            lowReal=compose('%.17g',real(data));
            lowImag=compose('%+.17gi',imag(data));

            for i=1:numel(lowReal)
                low{i}=[lowReal{i},lowImag{i}];
            end
        end
    elseif isa(data,'embedded.fi')


        unScaledFiObj=stripscaling(data);

        low=cell(size(unScaledFiObj));
        for i=1:numel(unScaledFiObj)
            x=unScaledFiObj(i);
            low{i}=x.Value;
        end
    else
        if isreal(data)
            if isa(data,'uint64')
                low=compose('%lu',uint64(data));
            elseif isa(data,'int64')
                low=compose('%ld',int64(data));
            else
                low=compose('%d',data);
            end
        else
            if isa(data,'uint64')
                low=compose('%lu',uint64(real(data)));
                lowImag=compose('+%lui',uint64(imag(data)));
            elseif isa(data,'int64')
                low=compose('%ld',int64(real(data)));
                lowImag=compose('+%ldi',int64(imag(data)));
            else
                low=compose('%d',real(data));
                lowImag=compose('%+di',imag(data));
            end

            for i=1:numel(low)
                low{i}=[low{i},lowImag{i}];
            end
        end
    end
end
