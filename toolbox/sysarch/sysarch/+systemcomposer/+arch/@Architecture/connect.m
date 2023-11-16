function cn=connect(this,src,dst,varargin)

    narginchk(3,9);

    this.validateAPISupportForAUTOSAR('connect');

    cn=systemcomposer.arch.Connector.empty;

    stereotype=[];
    rule="name";
    multiOut=false;
    routingOption='smart';

    for k=1:2:numel(varargin)
        if strcmpi(varargin{k},"Stereotype")
            stereotype=varargin{k+1};
        elseif strcmpi(varargin{k},"Rule")
            rule=string(varargin{k+1});
        elseif strcmpi(varargin{k},"MultipleOutputConnectors")
            multiOut=varargin{k+1};
        elseif strcmpi(varargin{k},"Routing")
            routingOption=varargin{k+1};
        else
            msgObj=message('SystemArchitecture:API:ConnectInvalidOption',string(varargin{k}));
            exception=MException('systemcomposer:API:ConnectInvalidOption',msgObj.getString);
            throw(exception);
        end
    end

    if numel(src)>0&&numel(dst)>0&&numel(src)~=numel(dst)
        msgObj=message('SystemArchitecture:API:ConnectArgsMismatch');
        exception=MException('systemcomposer:API:LoadModelError',msgObj.getString);
        throw(exception);
    end

    numElemsToProcess=max(numel(src),numel(dst));

    for k=1:numElemsToProcess
        srcEl=[];
        dstEl=[];
        if~isempty(src)
            srcEl=src(k);
        end
        if~isempty(dst)
            dstEl=dst(k);
        end
        cVal=LocConnect(this,srcEl,dstEl,stereotype,rule,multiOut,routingOption);
        if~isempty(cVal)
            cn=[cn,cVal];%#ok
        end
    end

end

function cn=LocConnect(this,src,dst,stereotype,rule,multiOut,routingOption)
    cn=systemcomposer.arch.Connector.empty;


    if isempty(src)
        srcPorts=this.Ports;
        candSrcPortTypes=[systemcomposer.arch.PortDirection.Input,...
        systemcomposer.arch.PortDirection.Physical];
    elseif isa(src,'systemcomposer.arch.BaseComponent')
        if~isequal(src.Parent,this)

            return;
        end
        srcPorts=src.Ports;
        candSrcPortTypes=[systemcomposer.arch.PortDirection.Output,...
        systemcomposer.arch.PortDirection.Physical];
    else

        return;
    end
    if isempty(dst)
        dstPorts=this.Ports;
        candDstPortTypes=[systemcomposer.arch.PortDirection.Output,...
        systemcomposer.arch.PortDirection.Physical];

    elseif isa(dst,'systemcomposer.arch.BaseComponent')
        if~isequal(dst.Parent,this)

            return;
        end
        dstPorts=dst.Ports;
        candDstPortTypes=[systemcomposer.arch.PortDirection.Input,...
        systemcomposer.arch.PortDirection.Physical];
    else

        return;
    end

    candSrcPorts=systemcomposer.arch.ComponentPort.empty;
    pIdx=1;
    for k=1:numel(srcPorts)
        thisP=srcPorts(k);
        if~isempty(find(candSrcPortTypes==thisP.Direction,1))&&...
            (multiOut||~thisP.Connected)
            candSrcPorts(pIdx)=thisP;
            pIdx=pIdx+1;
        end
    end

    if isempty(candSrcPorts)

        return;
    end


    candDstPorts=systemcomposer.arch.ComponentPort.empty;
    pIdx=1;
    for k=1:numel(dstPorts)
        thisP=dstPorts(k);
        if~isempty(find(candDstPortTypes==thisP.Direction,1))&&...
            ~thisP.Connected
            candDstPorts(pIdx)=thisP;
            pIdx=pIdx+1;
        end
    end
    if isempty(candDstPorts)

        return;
    end


    if strcmpi(rule,"name")
        candSrcPortNames={candSrcPorts.Name};
        candDstPortNames={candDstPorts.Name};
    else
        candSrcPortNames={candSrcPorts.InterfaceName};
        candDstPortNames={candDstPorts.InterfaceName};
    end
    candSrcPortNames=string(candSrcPortNames);
    candDstPortNames=string(candDstPortNames);

    [candSrcPortNames,sortIdx]=sort(candSrcPortNames);
    candSrcPorts=candSrcPorts(sortIdx);

    [candDstPortNames,sortIdx]=sort(candDstPortNames);
    candDstPorts=candDstPorts(sortIdx);


    sIdx=1;
    dIdx=1;
    mIdx=1;

    matchSrcPortIdx=zeros(1,numel(candSrcPortNames));
    matchDstPortIdx=zeros(1,numel(candDstPortNames));

    while(sIdx<=numel(candSrcPortNames))&&(dIdx<=numel(candDstPortNames))
        sName=candSrcPortNames(sIdx);
        dName=candDstPortNames(dIdx);
        if numel(sName)==0
            sIdx=sIdx+1;
            continue;
        end
        if numel(dName)==0
            dIdx=dIdx+1;
            continue;
        end

        if sName==dName

            matchSrcPortIdx(mIdx)=sIdx;
            matchDstPortIdx(mIdx)=dIdx;
            sIdx=sIdx+1;
            dIdx=dIdx+1;
            mIdx=mIdx+1;
        elseif sName<dName

            sIdx=sIdx+1;
        else

            dIdx=dIdx+1;
        end
    end
    mIdx=mIdx-1;

    if mIdx>0

        t=this.MFModel.beginTransaction;
        for k=1:mIdx
            srcPort=candSrcPorts(matchSrcPortIdx(k));
            dstPort=candDstPorts(matchDstPortIdx(k));
            cn(k)=srcPort.connect(dstPort,'Routing',routingOption);
        end
        t.commit;

        t2=this.MFModel.beginTransaction;

        if(~isempty(stereotype))
            for j=1:numel(cn)
                cn(j).applyStereotype(stereotype);
            end
        end
        t2.commit;
    end
end


