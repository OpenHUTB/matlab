function checkVivadoVersion(varargin)

    vivadoToolPath=soc.util.getVivadoPath;
    [stat,result]=system([vivadoToolPath,' -version']);
    if(stat~=0)
        error(message('soc:msgs:NotFoundHDLTool','Xilinx Vivado'));
    end

    if isempty(varargin{:})
        supportedVersion=soc.internal.getSupportedToolVersion('Xilinx');
    else
        supportedVersion=varargin{1}{1};
    end
    if~contains(result,supportedVersion)
        currentVersion=extractAfter(result,'Vivado v');
        currentVersion=currentVersion(1:6);
        error(message('soc:msgs:unsupportHDLToolVersion','Vivado',currentVersion,supportedVersion));
    end
end

