function results=create(harnessOwner,varargin)


    results=[];

    useBatchMode=needToUseBatchMode(harnessOwner);
    if~useBatchMode
        harnessOwner=convertStringsToChars(harnessOwner);

        if nargin>1
            [varargin{:}]=convertStringsToChars(varargin{:});
        end
    end
    try
        topModel=getTopModelValue(varargin);



        params=removeTopModelFromVarargin(varargin);
        if~useBatchMode
            if~isempty(topModel)
                warning(message("Simulink:Harness:IgnoreTopModelInLegacyMode"));
            end
            results=Simulink.harness.internal.create(harnessOwner,false,true,params{:});
            warnMssgs=[];
        else




            if isempty(topModel)
                error(message("Simulink:Harness:TopModelRequiredInBatchMode"));
            end
            [results,~,warnMssgs]=Simulink.harness.internal.createMultipleHarnesses(harnessOwner,topModel,params{:});
            results=reshape(results,size(harnessOwner));
        end
    catch ME
        throwAsCaller(ME);
    end
    results=Simulink.harness.internal.processStructOutput(results,warnMssgs);
end

function res=needToUseBatchMode(harnessOwner)
    if~ischar(harnessOwner)
        res=numel(harnessOwner)>1;
    else
        res=false;
    end
end

function res=getTopModelValue(argsin)
    p=inputParser;
    p.KeepUnmatched=true;
    p.addParameter('TopModel',[]);
    p.parse(argsin{:});
    res=p.Results.TopModel;
end

function res=removeTopModelFromVarargin(argsin)
    argin=argsin(1:2:end);
    ind=find(strcmp('TopModel',string(argin)));
    ind=2*ind-1;
    if~isempty(ind)
        argsin(ind)=[];
        argsin(ind)=[];
    end
    res=argsin;
end