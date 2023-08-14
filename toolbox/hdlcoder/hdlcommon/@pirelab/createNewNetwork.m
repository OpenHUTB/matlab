function hNewNet=createNewNetwork(varargin)















    p=inputParser;

    p.addParameter('PirInstance',[]);
    p.addParameter('Network','');
    p.addParameter('Name','');
    p.addParameter('SLHandle',-1);


    p.addParameter('NumofInports',0);
    p.addParameter('NumofOutports',0);

    p.addParameter('InportSignals',[]);
    p.addParameter('OutportSignals',[]);

    p.addParameter('InportNames',{});
    p.addParameter('InportTypes',[]);
    p.addParameter('InportRates',[]);
    p.addParameter('InportKinds',[]);
    p.addParameter('OutportNames',{});
    p.addParameter('OutportTypes',[]);
    p.addParameter('OutportRates',[]);
    p.addParameter('OutportKinds',[]);

    p.parse(varargin{:});
    args=p.Results;

    hPirInstance=args.PirInstance;
    hN=args.Network;
    Name=args.Name;
    nin=args.NumofInports;
    nout=args.NumofOutports;
    inportSignals=args.InportSignals;
    outportSignals=args.OutportSignals;
    inportNames=args.InportNames;
    inportTypes=args.InportTypes;
    inportRates=args.InportRates;
    inportKinds=args.InportKinds;
    outportNames=args.OutportNames;
    outportTypes=args.OutportTypes;
    outportRates=args.OutportRates;
    outportKinds=args.OutportKinds;
    slHandle=args.SLHandle;


    if~isempty(Name)
        if~isempty(hN)&&~isempty(hN.FullPath)
            networkName=[hN.FullPath,'/',Name];
        else
            networkName=Name;
        end
    else
        error(message('hdlcommon:hdlcommon:NetworkMissingName',hN.FullPath));
    end


    if isempty(hPirInstance)
        hDriver=hdlcurrentdriver;
        if isempty(hDriver)||~isa(hDriver.PirInstance,'hdlcoder.pirctx')
            gp=pir;
            hPir=gp.getTopPirCtx;
        else
            hPir=hDriver.PirInstance;
        end
    else
        hPir=hPirInstance;
    end

    if nin~=0||nout~=0

        hNewNet=hPir.addNetwork(nin,nout);

    else

        if~isempty(inportSignals)
            if~isempty(inportNames)||~isempty(inportTypes)||~isempty(inportRates)
                error(message('hdlcommon:hdlcommon:RedundantInput',networkName));
            end
            for ii=1:numel(inportSignals)
                insig=inportSignals(ii);
                inportName{ii}=insig.Name;%#ok<AGROW>
                inportType(ii)=insig.Type;%#ok<AGROW>
                inportRate(ii)=insig.SimulinkRate;%#ok<AGROW>
            end
            inportNames=inportName;
            inportTypes=inportType;
            inportRates=inportRate;
        end


        if~isempty(outportSignals)
            if~isempty(outportNames)||~isempty(outportTypes)||~isempty(outportRates)
                error(message('hdlcommon:hdlcommon:RedundantOutput',networkName));
            end
            for ii=1:numel(outportSignals)
                outsig=outportSignals(ii);
                outportName{ii}=outsig.Name;%#ok<AGROW>
                outportType(ii)=outsig.Type;%#ok<AGROW>
                outportRate(ii)=outsig.SimulinkRate;%#ok<AGROW>
            end
            outportNames=outportName;
            outportTypes=outportType;
            outportRates=outportRate;
        end

        numInports=numel(inportNames);
        numOutports=numel(outportNames);

        hNewNet=hPir.addNetwork;


        if isempty(inportRates)
            inportRates=zeros(1,numInports);
        end

        if isempty(outportRates)
            outportRates=zeros(1,numOutports);
        end


        if isempty(inportKinds)
            inportKinds=cell(1,numInports);
            for ii=1:numInports
                inportKinds{ii}='data';
            end
        end
        if isempty(outportKinds)
            outportKinds=cell(1,numOutports);
            for ii=1:numOutports
                outportKinds{ii}='data';
            end
        end

        if~isequal(numInports,numel(inportTypes))||...
            ~isequal(numInports,numel(inportRates))||...
            ~isequal(numInports,numel(inportKinds))
            error(message('hdlcommon:hdlcommon:PortNumberMismatch','inportNames, inportType, inportRates, inportKind',networkName));
        end

        if~isequal(numOutports,numel(outportTypes))||...
            ~isequal(numOutports,numel(outportRates))||...
            ~isequal(numOutports,numel(outportKinds))
            error(message('hdlcommon:hdlcommon:PortNumberMismatch','outportNames, outportType',networkName));
        end

        for ii=1:numInports
            if strcmp(inportKinds{ii},'subsystem_trigger_rising')
                hNewNet.addTriggerInputPort(inportKinds{ii},inportNames{ii},true);
            elseif strcmp(inportKinds{ii},'subsystem_trigger_falling')
                hNewNet.addTriggerInputPort(inportKinds{ii},inportNames{ii},false);
            elseif strcmp(inportKinds{ii},'subsystem_trigger_either')
                hNewNet.addTriggerInputPort(inportKinds{ii},inportNames{ii},true);
            else
                hNewNet.addInputPort(inportKinds{ii},inportNames{ii});
            end
            hsig=hNewNet.addSignal;
            hsig.Name=inportNames{ii};
            hsig.Type=inportTypes(ii);
            hsig.SimulinkRate=inportRates(ii);
            hsig.SimulinkHandle=-1;
            hsig.addDriver(hNewNet,ii-1);
        end

        for ii=1:numOutports
            hNewNet.addOutputPort(outportKinds{ii},outportNames{ii});
            hsig=hNewNet.addSignal;
            hsig.Name=outportNames{ii};
            hsig.Type=outportTypes(ii);
            hsig.SimulinkRate=outportRates(ii);
            hsig.SimulinkHandle=-1;
            hsig.addReceiver(hNewNet,ii-1);
        end
    end

    hNewNet.SimulinkHandle=slHandle;


    hNewNet.FullPath=networkName;
    hNewNet.Name=networkName;


