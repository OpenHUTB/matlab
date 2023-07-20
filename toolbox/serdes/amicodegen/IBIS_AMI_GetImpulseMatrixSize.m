

function matrixSize=IBIS_AMI_GetImpulseMatrixSize(paramName)
    ws=get_param(bdroot,'ModelWorkspace');
    matrixSize=0;
    if ws.evalin('base',['exist(''',paramName,''', ''var'')'])
        if ws.evalin('base',['isa(',paramName,', ''Simulink.Parameter'')'])
            matrixSize=ws.evalin('base',['numel(',paramName,'.Value)']);
        else
            matrixSize=ws.evalin('base',['numel(',paramName,')']);
        end
    elseif evalin('base',['exist(''',paramName,''', ''var'')'])
        if evalin('base',['isa(',paramName,', ''Simulink.Parameter'')'])
            matrixSize=evalin('base',['numel(',paramName,'.Value)']);
        else
            matrixSize=evalin('base',['numel(',paramName,')']);
        end
    end
