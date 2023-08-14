function busElemType=util_get_bus_element_type(varargin)






    if floor(varargin{1})==varargin{1}

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

        busElemType=dfsElemInfo.dataType;
    else

        portHandle=varargin{1};
        busSelElIdx=varargin{2};

        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

        portObject=get_param(portHandle,'Object');
        busElemType=portObject.getCompiledAttributes(busSelElIdx).dataType;
    end
end
