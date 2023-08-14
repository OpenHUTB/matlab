function Output=autoblkssetupengflwmassfrac(varargin)




    persistent SystemFlwBlkInfo


    Blk=varargin{1};
    System=get_param(bdroot(Blk),'Handle');
    if ischar(Blk)
        Blk=get_param(Blk,'Handle');
    end
    if~isa(SystemFlwBlkInfo,'containers.Map')
        SystemFlwBlkInfo=containers.Map('KeyType','double','ValueType','any');
    end


    if any(strcmp({'initializing','updating','running'},get_param(System,'SimulationStatus')))

        if SystemFlwBlkInfo.isKey(System)
            obj=SystemFlwBlkInfo(System);
            if nargin==1
                MethodName='GetMassFracInfo';
            else
                MethodName=varargin{2};
            end
            if ismethod(obj,MethodName)
                Output=obj.(MethodName)(Blk);
            else
                Output=obj.(MethodName);
            end
        else
            SystemFlwBlkInfo(System)=autoblksEngFlwSystemClass(System);
            Output=autoblkssetupengflwmassfrac(varargin{:});
        end
    else
        if SystemFlwBlkInfo.isKey(System)
            SystemFlwBlkInfo.remove(System);
        end
        Output=[];
    end

end