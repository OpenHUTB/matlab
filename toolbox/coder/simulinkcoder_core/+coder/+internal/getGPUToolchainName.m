function[tcName,tcAlias]=getGPUToolchainName(tcStruct,varargin)






    tcList=[];
    if nargin>1
        tcList=varargin{1};
    end

    if isempty(tcStruct)
        tcStruct=coder.make.internal.getMexCompilerInfo('installedOrFirstSupported');
    end

    if~isempty(tcStruct)&&isstruct(tcStruct)
        try
            tcAlias=coder.internal.isToolchainSupportedForGPU(tcStruct);
        catch
            tcAlias=[];
        end
        if~isempty(tcAlias)
            tcName=coder.make.internal.getToolchainName(tcAlias,tcStruct,tcList);
            return;
        end
    end

    [tcName,tcAlias]=coder.make.internal.getDefaultToolchain(tcStruct,tcList);

end