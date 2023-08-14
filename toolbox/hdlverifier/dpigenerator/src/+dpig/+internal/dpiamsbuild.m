function dpiamsbuild(model,subsys,varargin)




    currentDir=pwd;
    restoreDir=onCleanup(@()cd(currentDir));


    p=inputParser;
    p.addOptional('Include','');
    p.addOptional('Target','grt');
    p.parse(varargin{:});


    if~isempty(p.Results.Include)
        validateattributes(p.Results.Include,{'char'},{})
    end






    open_system(model);

    fullsubsys=cell(numel(subsys),1);
    for m=1:numel(subsys)
        fullsubsys{m}=[model,'/',subsys{m}];
        blockType=get_param(fullsubsys{m},'BlockType');
        if~strcmpi(blockType,'subsystem')
            error('Block %d in model %s is not a subsystem, which is required for this function',...
            subsys{m},model);
        end
    end

    moduleNames=cell(numel(subsys),1);


    if~isempty(p.Results.Include)
        if exist(fullfile(p.Results.Include,'svdpi.h'),'file');
            set_param(bdroot(model),'CustomInclude',p.Results.Include);
        else
            warning('Include directory %s is ignored since does not contain svdpi.h header.',...
            p.Results.Include);
        end
    end

    systemtargetfile=get_param(bdroot(model),'SystemTargetFile');

    switch systemtargetfile
    case{'systemverilog_dpi_ert.tlc','systemverilog_dpi_grt.tlc'}

    otherwise
        error('EDALink:dpig:WrongSystemTargetFile',...
        'System Target File must be systemverilog_dpi_ert.tlc or systemverilog_dpi_grt.tlc');
    end

    customizationoption=get_param(bdroot(model),'DPICustomizeSystemVerilogCode');
    if~strcmpi(customizationoption,'on')
        error('EDALink:dpig:WrongSystemTargetFile',...
        'DPICustomizeSystemVerilogCode must be turned on');
    end

    template=get_param(bdroot(model),'DPISystemVerilogTemplate');
    if~strcmpi(template,'svdpi_event.vgt')
        error('EDALink:dpig:WrongSystemTargetFile',...
        'DPISystemVerilogTemplate must be svdpi_event.vgt');
    end

    for m=1:numel(subsys)
        pause(1);
        rtwbuild(fullsubsys{m});
        mgr=dpig.internal.VariableManager.getInstance;
        moduleNames{m}=mgr.moduleName;

    end

    order=dpic_getSortedExecutionOrder(model,subsys);
    newModuleNames=moduleNames(order);
    schFile=fullfile(pwd,'event_scheduler.sv');
    dpigenerator_disp(['Generating event scheduler ',schFile]);
    h=dpig.internal.GenSVCode(schFile);
    h.appendCode('module event_scheduler;');
    h.addIndent;
    h.appendCode('parameter SAMPLE_TIME=10;');

    for m=1:numel(newModuleNames)
        newModuleNames{m}=['u_',newModuleNames{m}];
    end

    h.appendCode('initial begin');
    h.addIndent;
    h.appendCode('#0');
    for m=1:numel(newModuleNames)
        h.appendCode(['->',newModuleNames{m},'.DPI_INIT;']);
    end
    for m=1:numel(newModuleNames)
        h.appendCode(['#0 ->',newModuleNames{m},'.DPI_OUTPUT;']);
    end
    h.reduceIndent;
    h.appendCode('end');
    h.appendCode('always#SAMPLE_TIME begin');
    h.addIndent;
    for m=1:numel(newModuleNames)
        h.appendCode(['->',newModuleNames{m},'.DPI_UPDATE;']);
    end
    for m=1:numel(newModuleNames)
        h.appendCode(['#0 ->',newModuleNames{m},'.DPI_OUTPUT;']);
    end
    h.reduceIndent;
    h.appendCode('end');
    h.reduceIndent;
    h.appendCode('endmodule');

end

function order=dpic_getSortedExecutionOrder(modelName,subsys)
    feval(modelName,[],[],[],'compileForSizes');
    onCleanupObj=onCleanup(@()feval(modelName,[],[],[],'term'));

    list=get_param(gcs,'SortedList');

    sysNames=get_param(list,'Name');
    sysNames=intersect(sysNames,subsys);


    order=zeros(1,numel(subsys));
    for m=1:numel(subsys)
        tmp=strcmp(subsys{m},sysNames);
        order(m)=find(tmp,1);
    end
end
