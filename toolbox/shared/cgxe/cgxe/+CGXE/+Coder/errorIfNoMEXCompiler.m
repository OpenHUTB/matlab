function errorIfNoMEXCompiler(lang)

    try
        cc=mex.getCompilerConfigurations(lang,'Selected');
    catch ME %#ok<NASGU>
        cc=[];
    end
    if isempty(cc)
        error(message('Simulink:cgxe:MexCompilerNotFound'));
    end

end

