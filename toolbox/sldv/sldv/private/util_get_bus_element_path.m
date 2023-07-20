function busElemPath=util_get_bus_element_path(varargin)








    if nargin==3

        blkHandle=varargin{1};
        outIndex=varargin{2};
        busSelElIdx=varargin{3};

        ph=get_param(blkHandle,'porthandles');
        if isempty(ph.Outport)
            portHandle=ph.Inport(outIndex);
        else
            portHandle=ph.Outport(outIndex);
        end

        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

        portObject=get_param(portHandle,'Object');

        dataAccessor=Simulink.data.DataAccessor.create(get_param(bdroot(blkHandle),'name'));
        busElemPath=util_get_index_in_bus_array(dataAccessor,...
        portObject.getCompiledAttributes(busSelElIdx).fullPath,...
        portObject.getCompiledAttributes.dataType,...
        portObject.getCompiledAttributes.dimensions(2:end),...
        busSelElIdx);
    elseif nargin==2

        sfObjId=varargin{1};
        busSelElIdx=varargin{2};

        rt=sfroot;
        sfHandle=rt.idToHandle(sfObjId);

        testcomp=Sldv.Token.get.getTestComponent;
        modelName=get_param(testcomp.analysisInfo.analyzedModelH,'Name');

        oldFeatureVal=slsvTestingHook('BusDiagnosticTesting',1);
        dfsElemInfo=slInternal('busDiagnostics',...
        'getInfoForDFSElementInBus',...
        modelName,...
        sfHandle.CompiledType,...
        prod(str2num(sfHandle.CompiledSize)),...
        busSelElIdx);
        slsvTestingHook('BusDiagnosticTesting',oldFeatureVal);

        dataAccessor=Simulink.data.DataAccessor.create(modelName);

        busElemPath=util_get_index_in_bus_array(dataAccessor,...
        dfsElemInfo.fullPath,...
        sfHandle.CompiledType,...
        str2num(sfHandle.CompiledSize));
    end
end

function mPath=util_get_index_in_bus_array(dataAccessor,CPath,busName,...
    busDimension,busSelElIdx)










    mPath=busName;

    elems=strsplit(CPath,'.');
    for i=1:length(elems)
        temp=strsplit(elems{i},{'[',']'});

        if i==1
            maxDims=busDimension;
            busObj=Sldv.utils.getBusObjectFromName(busName,true,dataAccessor);
            if isempty(busObj)



                isEmptyBusObj=true;
            else
                isEmptyBusObj=false;
            end
        else
            if isEmptyBusObj

                mPath=[mPath,'-',int2str(busSelElIdx)];
                return;
            end
            for j=1:length(busObj.Elements)
                if strcmp(busObj.Elements(j).Name,temp{1})
                    maxDims=busObj.Elements(j).Dimensions;
                    [~,busObj]=Sldv.utils.isBusType(busObj.Elements(j).DataType,dataAccessor);
                    break;
                end
            end
        end

        if length(temp)==3
            idx=str2double(temp{2})+1;

            allDims=util_gen_all_combinations(maxDims);
            myDim=regexprep(int2str(allDims{idx}),' +',',');
        else
            myDim='';
        end

        if i~=1
            mPath=[mPath,'.',temp{1}];%#ok<AGROW>
        end

        if~isempty(myDim)
            mPath=[mPath,'(',myDim,')'];%#ok<AGROW>
        end
    end
end
