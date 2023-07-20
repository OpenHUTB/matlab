function generateFPGAProject(h)






    if h.BuildOpt.FirstProcess.Run
        runMsg=sprintf('and running %s ...',h.BuildOpt.FirstProcess.Name);
    else
        runMsg='...';
    end
    l_dispAndLog(h,sprintf('Generating %s project %s',...
    h.mProjMgr.mToolInfo.FPGAToolName,runMsg));


    h.mProjMgr.deleteExistingProject;


    h.mProjMgr.initialize;
    h.mProjMgr.createProject;


    vendor=h.mBuildInfo.BoardObj.Component.PartInfo.FPGAVendor;
    family=h.mBuildInfo.BoardObj.Component.PartInfo.FPGAFamily;


    switch(lower(vendor))
    case 'xilinx'
        target.family=getFPGAPartList(family,'vendorName');
    otherwise

        target.family=family;
    end

    target.device=h.mBuildInfo.BoardObj.Component.PartInfo.FPGADevice;
    target.speed=h.mBuildInfo.BoardObj.Component.PartInfo.FPGASpeed;
    target.package=h.mBuildInfo.BoardObj.Component.PartInfo.FPGAPackage;
    h.mProjMgr.setTargetDevice(target);

    prop=[];

    switch(lower(vendor))
    case 'xilinx'


        if~strcmpi(target.family,'virtex4')
            prop(1).process='';
            prop(1).name='"Optimization Goal"';
            prop(1).value='"Speed"';

            prop(2).process='Map';
            prop(2).name='"Combinatorial Logic Optimization"';
            prop(2).value='"True"';

            if strcmpi(target.family,'kintex7')
                prop(3).process='"Generate Programming File"';
                prop(3).name='"Other Bitgen Command Line Options"';
                prop(3).value='"-g UnconstrainedPins:Allow"';
            end

            if isfield(h.mBuildInfo.BoardObj.WorkflowOptions,'GenerateBinFile')
                if h.mBuildInfo.BoardObj.WorkflowOptions.GenerateBinFile






                    prop(end+1).process='"Generate Programming File"';
                    prop(end).name='"Create Binary Configuration File"';
                    prop(end).value='true';
                end
            end
        end



















    otherwise
        if strcmpi(target.family,'Arria II GX')
            prop(1).name='OPTIMIZATION_TECHNIQUE';
        else

            prop(1).name='CYCLONEII_OPTIMIZATION_TECHNIQUE';
        end
        prop(1).value='SPEED';

        if strcmpi(h.mBuildInfo.BoardObj.Component.Communication_Channel,'SGMII')
            ipdir=eda.internal.workflow.AlteraSGMII.detectIPFolder;
            ipdir=strrep(ipdir,'\','/');
            prop(end+1).value=ipdir;
            prop(end).name='SEARCH_PATH';
        end
        if strcmpi(target.family,'MAX 10')
            prop(end+1).name='INTERNAL_FLASH_UPDATE_MODE';
            prop(end).value='"SINGLE COMP IMAGE WITH ERAM"';
        end
    end

    if isfield(h.mBuildInfo.BoardObj.WorkflowOptions,'ProjectProperties')
        prop=[prop,h.mBuildInfo.BoardObj.WorkflowOptions.ProjectProperties];
    end

    if~isempty(prop)
        h.mProjMgr.setProperties(prop);
    end









    if~strcmpi(h.mBuildInfo.BoardObj.Component.Communication_Channel,'PSEthernet')
        h.mProjMgr.addFiles(h.mBuildInfo.SourceFiles.FilePath,...
        h.mBuildInfo.SourceFiles.FileType,h.mBuildInfo.SourceFiles.FileLib,...
        'CustomLabel','User design files:');
    end












    h.mProjMgr.setFPGASystemClockFrequency(h.mBuildInfo.FPGASystemClockFrequency);

    h.mProjMgr.generateIP(h.mBuildInfo.BoardObj);



    hdlDir=h.getFullDir(h.FilHdlDir);

    if(isfield(h.FilGenFiles,'ConstraintsFiles'))
        genFiles=[h.FilGenFiles.HdlFiles,h.FilGenFiles.ConstraintsFiles];
    else
        genFiles=h.FilGenFiles.HdlFiles;
    end

    genFiles=cellfun(@(x)fullfile(hdlDir,x),genFiles,...
    'UniformOutput',false);

    fileTypes=cellfun(@l_getFileType,h.FilGenFiles.HdlFiles,...
    'UniformOutput',false);

    if(isfield(h.FilGenFiles,'ConstraintsFileTypes'))
        genTypes=[fileTypes,h.FilGenFiles.ConstraintsFileTypes];
    else
        genTypes=fileTypes;
    end


    if~isempty(genFiles)
        h.mProjMgr.addFullPathFiles(genFiles,genTypes,...
        'CustomLabel','Generated files:');
    end


    if isempty(h.mBuildInfo.TopLevelName)
        h.mProjMgr.setTopLevel(h.mBuildInfo.FPGAProjectName);
    else
        h.mProjMgr.setTopLevel(h.mBuildInfo.TopLevelName);
    end




    h.mProjMgr.cleanProject;



    if h.BuildOpt.FirstProcess.Run

        label=sprintf('Running %s ...',h.BuildOpt.FirstProcess.Name);
        runCmd=sprintf('run%s',h.BuildOpt.FirstProcess.Cmd);

        h.mProjMgr.(runCmd)('CustomLabel',label,'ProcessErrorAssertion',true);

        genbit=strcmpi(h.BuildOpt.FirstProcess.Cmd,'BitGeneration');
        if genbit
            h.mProjMgr.getTimingResult('timing_err');
        end

    end
    h.mProjMgr.closeProject;


    if h.BuildOpt.FirstProcess.Run
        if genbit
            h.printBitGenSummary;
        end
    end


    [buildErr,buildMsg]=h.mProjMgr.build(...
    'ProjectLinkDisplay',false,...
    'ProjectStatusDisplay','PreBuild',...
    'TclScriptName','createproject.tcl');

    h.LogMsg=[h.LogMsg,h.mProjMgr.getProjectStatus];

    procName=h.BuildOpt.FirstProcess.Name;
    if~isempty(procName)
        procName(1)=upper(procName(1));
    end

    if buildErr

        errMsg=getString(message('EDALink:LegacyCodeFILManager:generateFPGAProject:ProjectGenerationFailed',...
        h.mProjMgr.mToolInfo.FPGAToolName,buildMsg));
        disp(errMsg);



        if h.BuildOpt.FirstProcess.Run

            l_dispAndLog(h,sprintf('%s failed.',procName));


            h.LogMsg=[h.LogMsg,sprintf('\n%s',dispFpgaMsg(errMsg))];
            h.writeLogFile;

            error(message('EDALink:LegacyCodeFILManager:generateFPGAProject:FirstProcessFailed',procName,l_getFileLink(h.LogFilePath)));
        else

            l_dispAndLog(h,'Project generation failed.');

            l_dispAndLog(h,errMsg);
            h.writeLogFile;

            error(message('EDALink:LegacyCodeFILManager:generateFPGAProject:ProjectGenFailed'));
        end
    else
        if h.BuildOpt.FirstProcess.Run
            l_dispAndLog(h,sprintf('%s completed.',procName));
        end
    end



    function l_dispAndLog(h,str)
        h.displayStatus(str);
        h.LogMsg=[h.LogMsg,newline,dispFpgaMsg(str)];

        function link=l_getFileLink(file)
            link=['<a href="matlab:edit(''',file,''')">',file,'</a>'];

            function type=l_getFileType(filename)
                [~,~,ext]=fileparts(filename);
                switch(lower(ext))
                case '.v'
                    type='Verilog';
                case '.vhd'
                    type='VHDL';
                case '.qsys'
                    type='QSYS';
                case '.sdc'
                    type='Constraints';
                case '.qsf'
                    type='QSF file';
                case '.tcl'
                    type='Tcl script';
                case '.ip'
                    type='IP file';
                otherwise
                    type='Others';
                end

