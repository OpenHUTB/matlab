




































function elem=sldvPickObjectives(hdls,varargin)

    elem=[];





    if~iscell(hdls)
        elem=createElem(hdls);
        for k=1:2:numel(varargin)
            switch varargin{k}
            case 'covtype'
                elem.covType=setCoverageType(varargin{k+1});
            case 'outcome'
                elem.outIdx=setOutcomeVal(varargin{k+1});
            case 'vectorId'
                elem.vecIdx=setVectorVal(varargin{k+1});
            case 'conditionId'
                elem.condIdx=setConditionIdx(varargin{k+1});
            case 'portId'
                elem.beginPortIdx=setPortIdx(varargin{k+1});
            case 'blockType'
                elem.blkType=setBlockType(varargin{k+1});
            end
        end
    else
        for n=1:length(hdls)
            e=createElem(hdls{n});
            for k=1:2:numel(varargin)
                switch varargin{k}
                case 'covType'
                    e.covtype=setCoverageType(varargin{k+1});
                case 'outcome'
                    e.outIdx=setOutcomeVal(varargin{k+1});
                case 'vectorId'
                    e.vecIdx=setVectorVal(varargin{k+1});
                case 'conditionId'
                    e.condIdx=setConditionIdx(varargin{k+1});
                case 'portId'
                    e.beginPortIdx=setPortIdx(varargin{k+1});
                case 'blockType'
                    e.blkType=setBlockType(varargin{k+1});
                end
            end
            if isempty(elem)
                elem=e;
            else
                elem(n)=e;%#ok<*AGROW>
            end

        end
    end



    elem=updateBlockCov(elem);
    elem=updatePortIdx(elem);

end

function e=createElem(hdl)

    e.sid=Simulink.ID.getSID(hdl);
    e.lbl='default';
    e.covType='ANY_COV';





    e.outIdx=-1;
    e.vecIdx=-1;
    e.condIdx=-1;
    e.beginPortIdx=-1;
    e.cntPortIdx=-1;
    e.blkType=-1;
end

function v=setCoverageType(val)


    switch val
    case 'condition-decision'
        v='COND_DEC_COV';
    case 'decision'
        v='DEC_COV';
    case 'mcdc'
        v='MCDC_COV';
    case 'strictmcdc'
        v='STRICT_MCDC_COV';
    case 'condition'
        v='COND_COV';
    case 'blkcov'
        v='BLOCK_COV';
    case 'addDelay'
        v='ADD_DELAY';
    otherwise
        v='ANY_COV';
    end
end

function v=setPortIdx(val)
    if ischar(val)
        v=str2num(val);
    end

    if isnumeric(val)
        v=val;
    end
end

function v=setOutcomeVal(val)
    if ischar(val)
        v=str2num(val);%#ok<*ST2NM>
    end

    if isnumeric(val)
        v=val;
    end
end


function v=setVectorVal(val)
    if ischar(val)
        v=str2num(val);
    end

    if isnumeric(val)
        v=val;
    end
end

function v=setBlockType(val)
    if ischar(val)
        v=str2num(val);
    end

    if isnumeric(val)
        v=val;
    end
end

function elem=updateBlockCov(elem)
    for i=1:length(elem)
        if strcmp(elem(i).covType,'BLOCK_COV')
            elem(i).condIdx=elem(i).outIdx;
            elem(i).outIdx=elem(i).beginPortIdx;
            elem(i).beginPortIdx=-1;
        end
    end
end

function elem=updatePortIdx(elem)

    for i=1:length(elem)
        if elem(i).beginPortIdx==-1
            continue;
        end

        blkH=sldvprivate('util_sid',elem(i).sid);
        if~strcmp(get_param(blkH,'Type'),'block')||...
            ~strcmp(get_param(blkH,'BlockType'),'Logic')||...
            ~strcmp(elem(i).covType,'COND_COV')
            elem(i).beginPortIdx=-1;
            continue;
        end

        portNum=elem(i).beginPortIdx;
        portHs=get_param(blkH,'PortHandles');
        cnt=0;
        for j=1:portNum-1
            cnt=cnt+get_param(portHs.Inport(j),'CompiledPortWidth');
        end
        elem(i).beginPortIdx=cnt;
        elem(i).cntPortIdx=get_param(portHs.Inport(portNum),'CompiledPortWidth');
    end
end

function v=setConditionIdx(val)
    if ischar(val)
        v=str2num(val);
    end

    if isnumeric(val)
        v=val;
    end
end


