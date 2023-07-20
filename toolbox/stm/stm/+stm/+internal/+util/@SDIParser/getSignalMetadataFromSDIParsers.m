function varOutputs=getSignalMetadataFromSDIParsers(this,varParsers,isMat)






    ws=warning('off',...
    'Simulink:Logging:ModelDataLogConvertError_StateflowNotSupported');
    cleanupWarning=onCleanup(@()warning(ws));
    varOutputs=[];
    traverseHierarchy(varParsers,true);

    function traverseHierarchy(varParser,isTopLevel)

        numVars=length(varParser);
        for x=1:numVars
            vParser=varParser{x};
            children=getChildren(vParser);
            if allowSelectiveChildImport(vParser)&&~isempty(children)
                traverseHierarchy(children,false);
            elseif~isVirtualNode(vParser)||isa(vParser,"Simulink.sdi.internal.import.TimetableParser")
                varOutputs=[varOutputs,populateData(vParser,isMat)];%#ok
            end

            if(isTopLevel)
                notify(this,'VariableLoadEvent',Simulink.sdi.internal.VarImportEvent(numVars,x));
            end
        end
    end
end

function varOutput=populateData(varParser,isMat)

    varOutput=struct(...
    'SignalLabel',getSignalLabel(varParser),...
    'LeafBusPath',locGetLeafBusPath(varParser,isMat),...
    'BlockSource',getBlockSource(varParser),...
    'BlockPath',locGetBlockPath(varParser,isMat),...
    'ModelSource',getModelSource(varParser),...
    'Dimensions',num2str(getSampleDims(varParser)),...
    'DataSource',getDataSource(varParser),...
    'RootSource',getRootSource(varParser),...
    'TimeSource',getTimeSource(varParser),...
    'rootDataSrc',getDataSource(varParser),...
    'interpolation',getInterpolation(varParser),...
    'Sync',uint8(xls.internal.Synchronizations.union),...
    'SID','',...
    'PortIndex',getPortIndex(varParser),...
    'AbsTol',0,...
    'RelTol',0,...
    'ForwardTimeTol',0,...
    'BackwardTimeTol',0,...
    'Parser',varParser);





end

function leafBusPath=locGetLeafBusPath(varParser,isMat)
    if isMat||strlength(varParser.LeafBusPath)==0
        leafBusPath='';
    elseif strlength(varParser.getCustomExportNames)==0
        leafBusPath=buildBusPath(varParser);
    else
        leafBusPath=varParser.LeafBusPath;
    end
end

function blockPath=locGetBlockPath(varParser,isMat)
    if isMat
        blockPath=string.empty;
    else
        blockPath=string(varParser.getFullBlockPath.convertToCell);
    end
end

function leafBusPath=buildBusPath(varParser)

    leafBusPath=string(varParser.getSignalLabel);
    while strlength(varParser.Parent.BusName)>0
        leafBusPath=[leafBusPath,varParser.Parent.BusName];%#ok<AGROW>
        varParser=varParser.Parent;
    end

    leafBusPath=char("."+join(fliplr(leafBusPath),'.'));
end
