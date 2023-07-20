function hNewNet=createNewNetworkWithInterface(varargin)






    p=inputParser;

    p.addParamValue('Network','');
    p.addParamValue('RefComponent','');
    p.addParamValue('InputPorts',{});
    p.addParamValue('InportNames',{});
    p.addParamValue('InportKinds',{});
    p.addParamValue('OutputPorts',{});
    p.addParamValue('OutportNames',{});
    p.addParamValue('useDTC',false);
    p.addParamValue('AggregateType',[]);
    p.addParamValue('Name',[]);

    p.parse(varargin{:});
    args=p.Results;

    hN=args.Network;
    hC=args.RefComponent;
    inPort=args.InputPorts;
    inportNames=args.InportNames;
    inportKinds=args.InportKinds;
    outPort=args.OutputPorts;
    outportNames=args.OutportNames;
    useDTC=args.useDTC;
    aggType=args.AggregateType;
    netName=args.Name;


    if isempty(inPort)
        inPort=hC.PirInputPorts;
    end

    if isempty(outPort)
        outPort=hC.PirOutputPorts;
    end

    if isempty(netName)
        netName=hC.Name;
    end


    namesDefined=~isempty(inportNames);
    kindsDefined=~isempty(inportKinds);

    nins=length(inPort);
    if(nins>0)
        for ii=1:nins
            if~namesDefined
                inportNames{end+1}=inPort(ii).Name;%#ok<*AGROW>
            end
            if~kindsDefined
                inportKinds{ii}=inPort(ii).Kind;%#ok<*AGROW>
            end

            insig=inPort(ii).Signal;

            if(useDTC)

                inportTypes(ii)=aggType;%#ok<AGROW> 
            else
                inportTypes(ii)=insig.Type;%#ok<AGROW>
            end
            inportRates(ii)=insig.SimulinkRate;%#ok<AGROW>
        end
    else
        inportTypes=[];
        inportRates=[];
        inportKinds=[];
    end

    namesDefined=~isempty(outportNames);
    nouts=length(outPort);
    if(nouts>0)
        for ii=1:nouts
            if~namesDefined
                outportNames{end+1}=outPort(ii).Name;
            end

            outsig=outPort(ii).Signal;
            outportTypes(ii)=outsig.Type;%#ok<AGROW>
        end
    else
        outportTypes=[];
    end



    hNewNet=pirelab.createNewNetwork('Network',hN,...
    'Name',netName,...
    'InportNames',inportNames,...
    'InportTypes',inportTypes,...
    'InportRates',inportRates,...
    'InportKinds',inportKinds,...
    'OutportNames',outportNames,...
    'OutportTypes',outportTypes);
end
