function sigSpecs=parseBaselineSource(id,srcId,fileName,allowEmpty,varargin)


    sigSpecs=[];
    [~,~,ext]=fileparts(fileName);
    if strcmpi(ext,'.mat')
        sigSpecs=stm.internal.util.ParseMatFile(id,fileName,varargin{:});
    elseif any(strcmpi(ext,[xls.internal.WriteTable.SpreadsheetExts,".csv"]))
        [sigSpecs,readTable]=stm.internal.util.parseSpreadsheet(srcId,fileName,allowEmpty);
        sigSpecs=getNonDatasetProperties(sigSpecs,readTable.getRange);
    elseif strcmpi(ext,'.mldatx')
        stm.internal.loadRunFromMLDATX(fileName);
    else
        error(message('stm:general:UnsupportedBaselineFile',ext));
    end
end

function sigSpecs=getNonDatasetProperties(sigSpecs,range)
    if isempty(range)
        return;
    elseif~range.hasTolerance&&~range.hasIntersectionSync
        return;
    end


    xls.internal.parsedVarResult('RemoveAll');
    oc=onCleanup(@()xls.internal.parsedVarResult('RemoveAll'));

    timeSections=xls.internal.getToleranceProperty(range.getID,'TimeSection');
    for x=1:numel(sigSpecs)
        name=locGetName(sigSpecs(x));
        blockPath=sigSpecs(x).BlockPath;
        blockSource=sigSpecs(x).BlockSource;
        portIndex=locGetPortIndex(sigSpecs(x));
        isBus=locIsBus(sigSpecs(x));
        signalID=xls.internal.getSignalFromMetadata(timeSections,name,blockPath,...
        blockSource,portIndex,isBus);
        signal=xls.internal.Signal(signalID);
        sigSpecs(x).AbsTol=signal.AbsTol;
        sigSpecs(x).RelTol=signal.RelTol;
        sigSpecs(x).ForwardTimeTol=signal.LeadTol;
        sigSpecs(x).BackwardTimeTol=signal.LagTol;
        sigSpecs(x).Sync=uint8(signal.Sync);
    end
end

function name=locGetName(sigSpec)

    if locIsBus(sigSpec)
        name=sigSpec.LeafBusPath;
    else
        name=sigSpec.SignalLabel;
    end
end

function bool=locIsBus(sigSpec)
    bool=strlength(sigSpec.LeafBusPath)>0;
end

function portIndex=locGetPortIndex(sigSpec)
    if isempty(sigSpec.PortIndex)
        portIndex=1;
    else
        portIndex=sigSpec.PortIndex;
    end
end
