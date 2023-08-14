function out=enumerations(in)










    out=in;


    if~isempty(in.getValue('squirrel_cage'))
        squirrel_cage=strrep(in.getValue('squirrel_cage'),'pe.machines.asm_squirrel_cage.squirrelcage','ee.enum.squirrelcage');
        out=out.setValue('squirrel_cage',squirrel_cage);
    end
    if~isempty(in.getValue('zero_sequence'))
        zero_sequence=strrep(in.getValue('zero_sequence'),'pe.enum','ee.enum');
        out=out.setValue('zero_sequence',zero_sequence);
    end
    if~isempty(in.getValue('connection_option'))
        connection_option=strrep(in.getValue('connection_option'),'pe.Connection','ee.enum.Connection');
        out=out.setValue('connection_option',connection_option);
    end
    if~isempty(in.getValue('param_option'))
        param_option=strrep(in.getValue('param_option'),'pe.','ee.enum.');
        out=out.setValue('param_option',param_option);
    end
    if~isempty(in.getValue('axes_param'))
        axes_param=strrep(in.getValue('axes_param'),'pe.enum','ee.enum');
        out=out.setValue('axes_param',axes_param);
    end
    if~isempty(in.getValue('d_option'))
        d_option=strrep(in.getValue('d_option'),'pe.enum','ee.enum');
        out=out.setValue('d_option',d_option);
    end
    if~isempty(in.getValue('q_option'))
        q_option=strrep(in.getValue('q_option'),'pe.enum','ee.enum');
        out=out.setValue('q_option',q_option);
    end
    if~isempty(in.getValue('initialization_option'))
        initialization_option=in.getValue('initialization_option');
        initialization_option=strrep(initialization_option,'ee.enum.asm.initialization.FluxVariables','ee.enum.asm.initialization.fluxvariables');
        initialization_option=strrep(initialization_option,'ee.enum.asm.initialization.SteadyState','ee.enum.asm.initialization.steadystate');
        initialization_option=strrep(initialization_option,'ee.enum.sm.initialization.steadyState','ee.enum.sm.initialization.steadystate');
        out=out.setValue('initialization_option',initialization_option);
    end

end
