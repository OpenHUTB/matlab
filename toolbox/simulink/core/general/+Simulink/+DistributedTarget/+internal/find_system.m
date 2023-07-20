function output=find_system(varargin)







    narginchk(1,3);
    nargoutchk(0,1);

    allout=false;
    obj=varargin{1};
    switch length(varargin)
    case 1
        allout=true;
    case 2
        DAStudio.error('MATLAB:narginchk:notEnoughInputs');
    case 3
        param=varargin{2};
        paramVal=varargin{3};
    end

    if~Simulink.DistributedTarget.internal.isvalidobj(obj)
        DAStudio.error('Simulink:mds:InvalidObjectIdentifier',obj);
    end
    archobj=strsplit(obj,'/');
    archH=Simulink.DistributedTarget.internal.getmappingmgr(archobj{1});
    handle=Simulink.DistributedTarget.internal.gethandle(archobj(2:end),archH);

    if allout
        testFcn=@(x)true;
    else
        testFcn=@(x)isSatisfied(x,param,paramVal);
    end
    children=Simulink.DistributedTarget.internal.allchildren(handle,testFcn);

    if~isempty(children)
        output=cell(length(children),1);
        for i=1:length(children)
            output{i}=[archobj{1},Simulink.DistributedTarget.internal.getfullname(...
            archH,children{i})];
        end
    else
        output={};
    end
end

function ret=isSatisfied(handle,param,paramVal)
    ret=false;
    try
        handleVal=Simulink.architecture.get_param(handle,param);
        if strcmp(handleVal,paramVal)
            ret=true;
        end
    catch err %#ok
        ret=false;
    end
end

