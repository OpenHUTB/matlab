function warmupSimulink()
    if strcmp(getenv('PREWARM_SIMULINK'),'true')


        if exist('bdclose','file')
            bdclose('all')
        end
    end
end
