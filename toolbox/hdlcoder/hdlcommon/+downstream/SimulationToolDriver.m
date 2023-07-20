




classdef SimulationToolDriver<hgsetget


    properties

    end

    properties(Hidden=true)

        hD=0;
    end


    methods(Access=public)

        function obj=SimulationToolDriver(hDIDriver)

            obj.hD=hDIDriver;
        end

        function[status,result]=run(this)


            result=true;

            hDriver=this.hD;
            if hDriver.isHLSWorkflow
                tool=hDriver.get('Tool');
                if strcmpi(tool,'Cadence Stratus')
                    status=runStratusSim(this);
                elseif strcmpi(tool,'Xilinx Vitis HLS')
                    status=runVitisSim(this);
                else

                    status=1;
                    return;
                end
            else
                tool=hDriver.get('SimulationTool');

                if strcmpi(tool,'ModelSim')

                    status=runModelSimSim(this);

                else

                    status=runISIMSim(this);
                end
            end
        end





        function status=runModelSimSim(this)

            hDriver=this.hD;
            cgInfo=hDriver.hCodeGen;

            dirName=cgInfo.CodegenDir;
            topName=cgInfo.EntityTop;

            d=this.setupDir(dirName);

            try

                compileDoFile=[cgInfo.hCHandle.getParameter('tb_name'),cgInfo.hCHandle.getParameter('hdlcompilefilepostfix')];
                simDoFile=[cgInfo.hCHandle.getParameter('tb_name'),cgInfo.hCHandle.getParameter('hdlsimfilepostfix')];

                ceLog=[topName,'_vsim_errlog_compile.txt'];
                seLog=[topName,'_vsim_errlog_sim.txt'];
                cLog=[topName,'_vsim_log_compile.txt'];
                sLog=[topName,'_vsim_log_sim.txt'];

                compileCmd=sprintf('vsim -voptargs=+acc -c -do %s > %s',compileDoFile,cLog);
                simCmd=sprintf('vsim -voptargs=+acc -c -do %s > %s',simDoFile,sLog);

                status=this.runCompilation(compileCmd,cLog,ceLog);
                if(status==0)


                    status=this.runSimulation(simCmd,sLog,seLog);
                end

            catch me %#ok<NASGU>
                status=1;
            end

            cd(d);

        end


        function d=setupDir(~,dirName)
            d=pwd;
            try
                cd(dirName);
            catch me
                msg=sprintf('Error: cannot find ''%d''',dirName);
                disp(msg);
                rethrow(me);
            end
        end





        function status=runISIMSim(this)


            hDriver=this.hD;
            cgInfo=hDriver.hCodeGen;

            dirName=cgInfo.CodegenDir;
            topName=cgInfo.EntityTop;

            dbgLvl=cgInfo.hCHandle.getParameter('debug');
            isvhdl=cgInfo.isVHDL;

            d=this.setupDir(dirName);

            try

                compileDoFile=[cgInfo.hCHandle.getParameter('tb_name'),cgInfo.hCHandle.getParameter('hdlcompilefilepostfix')];

                fuseDoFile=[cgInfo.EntityTop,'_tb_simprj.do'];
                simDoFile=[cgInfo.hCHandle.getParameter('tb_name'),cgInfo.hCHandle.getParameter('hdlsimfilepostfix')];

                ceLog=[topName,'_isim_errlog_compile.txt'];
                feLog=[topName,'_isim_errlog_fuse.txt'];
                seLog=[topName,'_isim_errlog_sim.txt'];

                cLog=[topName,'_isim_log_compile.txt'];
                fLog=[topName,'_isim_log_fuse.txt'];
                sLog=[topName,'_isim_log_sim.txt'];

                ccmd='vhpcomp';
                if~isvhdl
                    ccmd='vlogcomp';
                end


                exeName=fullfile('.',[topName,'_isim_design','.exe']);

                compileCmd=sprintf('%s -f %s  >%s',ccmd,compileDoFile,cLog);
                simPrjCmd=sprintf('fuse -f %s >%s',fuseDoFile,fLog);
                simCmd=sprintf('%s -tclbatch %s >%s',exeName,simDoFile,sLog);



                status=this.runCompilation(compileCmd,cLog,ceLog);
                if(status==0)


                    [status,stdout]=system(simPrjCmd);
                    this.str2file(stdout,feLog);
                    if dbgLvl
                        disp('fuse logs...');
                        disp(simPrjCmd);
                        type(feLog);
                        disp(' ');
                        type(fLog);
                    end

                    if(status==0)
                        status=this.runSimulation(simCmd,sLog,seLog);
                    else
                        fuseResults=fullfile(dirName,feLog);
                        disp(sprintf('### Generating Compilation Error Report %s',hdlgetfilelink(fuseResults)));%#ok<DSPS>
                    end

                end

            catch me %#ok<NASGU>
                status=1;
            end


            cd(d);

        end




        function status=runStratusSim(this)
            hDriver=this.hD;
            cgInfo=hDriver.hCodeGen;

            dirName=cgInfo.CodegenDir;
            topName=cgInfo.EntityTop;

            d=this.setupDir(dirName);

            try
                stratusPrjDirName='stratus_prj';
                cd(stratusPrjDirName);
                sLog=[topName,'_sim_BEH_log_sim.txt'];

                simCmd="make sim_BEH";
                [~,stdout]=system(simCmd);

                this.str2file(stdout,sLog);

                simulationResultsFileName=fullfile(dirName,stratusPrjDirName,sLog);
                disp(sprintf('### Generating Simulation Report %s',hdlgetfilelink(simulationResultsFileName)));%#ok<DSPS>

                if~isempty(stdout)&&(contains(stdout,'TEST COMPLETED (PASSED)')||contains(stdout,'SIMULATION PASSED'))
                    status=0;
                else
                    status=1;
                end

            catch me %#ok<NASGU>
                status=1;
            end

            cd(d);
        end




        function status=runVitisSim(this)
            dirName=this.hD.hCodeGen.CodegenDir;

            d=this.setupDir(dirName);

            try
                [~,hA]=this.hD.hAvailableToolList.isInToolList(this.hD.getToolName);
                vitisHLSPrjName=hA.AvailablePlugin.ProjectDir;


                this.hD.generateVitisProjectTclFile(vitisHLSPrjName,"simulation");

                if exist(vitisHLSPrjName,"dir")
                    [~,~]=system(sprintf("rm -r %s",vitisHLSPrjName));
                end

                simCmd='vitis_hls sim_script.tcl';
                [~,stdout]=system(simCmd);

                sLog='sim_log.txt';
                simulationResultsFileName=fullfile(dirName,sLog);
                disp(sprintf('### Generating Simulation Report %s',hdlgetfilelink(simulationResultsFileName)));%#ok<DSPS>

                this.str2file(stdout,simulationResultsFileName);

                if~isempty(stdout)&&~contains(stdout,'ERROR:')&&contains(stdout,'TEST COMPLETED (PASSED)')
                    status=0;
                else
                    status=1;
                end
            catch
                status=1;
            end

            cd(d);
        end

        function[status,stdout]=runCompilation(this,compileCmd,cLog,ceLog)

            dirName=this.hD.hCodeGen.CodegenDir;
            dbgLvl=this.hD.hCodeGen.hCHandle.getParameter('debug');

            [status,stdout]=system(compileCmd);
            this.str2file(stdout,ceLog);

            compileResults=fullfile(dirName,cLog);
            if~isempty(stdout)
                if(~isempty(strfind(stdout,'ERROR'))||~isempty(strfind(stdout,'FATAL'))||...
                    ~isempty(strfind(stdout,'Error'))||~isempty(strfind(stdout,'Fatal')))
                    compileResults=fullfile(dirName,ceLog);
                    disp(sprintf('### Generating Compilation Error Report %s',hdlgetfilelink(compileResults)));%#ok<DSPS>                   
                end
            end

            compileResults=fullfile(dirName,cLog);
            disp(sprintf('### Generating Compilation Report %s',hdlgetfilelink(compileResults)));%#ok<DSPS>

            if dbgLvl
                disp(compileCmd);
                disp('compilation logs...');
                type(ceLog);
                disp(' ');
                type(cLog);
            end

        end


        function status=runSimulation(this,simCmd,sLog,seLog)

            dirName=this.hD.hCodeGen.CodegenDir;
            dbgLvl=this.hD.hCodeGen.hCHandle.getParameter('debug');


            [status,stdout]=system(simCmd);

            simulationResultsFileName=fullfile(dirName,sLog);
            disp(sprintf('### Generating Simulation Report %s',hdlgetfilelink(simulationResultsFileName)));%#ok<DSPS>

            this.str2file(stdout,seLog);
            if~isempty(stdout)&&~isempty(strfind(stdout,'Error'))
                simResults=fullfile(dirName,seLog);
                disp(sprintf('### Generating Simulation Error Report %s',hdlgetfilelink(simResults)));%#ok<DSPS>
                return;
            end

            if dbgLvl
                disp('simulation logs...');
                disp(simCmd);
                type(seLog);
                disp(' ');
                type(sLog);
            end

            simLogTxt=fileread(sLog);
            if~isempty(simLogTxt)&&~isempty(strfind(simLogTxt,'TEST COMPLETED (PASSED)'))
                status=0;
            else
                status=1;
            end
        end


        function str2file(this,str,filename)%#ok<MANU>

            fid=fopen(filename,'w');

            if fid==-1
                fprintf(1,'Failed to open file ''%s'' for writing.',filename);
                error(message('hdlcommon:workflow:simulationtooldriver'));
            end

            fprintf(fid,'%s',str);
            fclose(fid);
        end

    end
end
