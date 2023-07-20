function writeMkCfgGetBuildType(h,fid)%#ok<INUSL>





    fprintf(fid,'%%--------------------------------------------------------------------------\n');
    fprintf(fid,'function isSimTarget = is_simulation_target()\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Default output value\n');
    fprintf(fid,'isSimTarget = 0;\n');
    fprintf(fid,'\n');
    fprintf(fid,'%% Get the current model and the code generation type to decide\n');
    fprintf(fid,'%% if we must link with the host libraries or with the target libraries\n');
    fprintf(fid,'modelName = get_param(0, ''CurrentSystem'');\n');
    fprintf(fid,'if ~isempty(modelName)\n');
    fprintf(fid,'    modelName = bdroot(modelName);\n');
    fprintf(fid,'    sysTarget = get_param(modelName, ''RTWSystemTargetFile'');\n');
    fprintf(fid,'    isSimTarget = ~isempty([findstr(sysTarget, ''rtwsfcn'') findstr(sysTarget, ''accel'')]);\n');
    fprintf(fid,'\n');
    fprintf(fid,'    mdlRefSimTarget = get_param(modelName,''ModelReferenceTargetType'');\n');
    fprintf(fid,'    isSimTarget = strcmpi(mdlRefSimTarget, ''SIM'') || isSimTarget;\n');
    fprintf(fid,'\n');
    fprintf(fid,'    %% Verify again it''s not Accelerator\n');
    fprintf(fid,'    if ~isSimTarget\n');
    fprintf(fid,'        simMode = get_param(modelName, ''SimulationMode'');\n');
    fprintf(fid,'        simStat = get_param(modelName, ''SimulationStatus'');\n');
    fprintf(fid,'        isSimTarget = strcmp(simStat, ''initializing'') & strcmp(simMode, ''accelerator'');\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n');
    fprintf(fid,'\n\n');

