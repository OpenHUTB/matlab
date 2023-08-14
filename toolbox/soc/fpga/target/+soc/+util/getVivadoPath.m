function path=getVivadoPath()
    if getenv('XILINX_VIVADO')
        path=fullfile(getenv('XILINX_VIVADO'),'vivado');
    else
        if ispc
            [~,vivadoPath]=soc.util.which('vivado.bat');
        else
            [~,vivadoPath]=soc.util.which('vivado');
        end
        if~isempty(vivadoPath)
            path=fullfile(vivadoPath,'vivado');
        else
            error(message('soc:msgs:vivadoEnvNotSet'));
        end
    end
end

