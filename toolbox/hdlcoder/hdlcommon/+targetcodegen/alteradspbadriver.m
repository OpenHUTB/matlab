



classdef alteradspbadriver<handle
    methods(Static)


        function result=process(stage,hdlCoder,varargin)
            result={};
            modelName=hdlCoder.modelName;
            if(isempty(targetcodegen.alteradspbadriver.findDSPBABlks(modelName)))
                return;
            end

            targetcodegen.alteradspbadriver.setDSPBALibSynthesisScriptsNeeded(true);
            dspbaFullDir=targetcodegen.alteradspbadriver.getFullDir;
            switch lower(stage)
            case 'phase1'
                [controlBlk,oldControlBlkSettings,signalsBlk,oldSignalsBlkSettings]=targetcodegen.alteradspbadriver.setupDSPBASettings(hdlCoder);
                try
                    dspba.runGeneration('Phase1','SPath',modelName,'RTLPath',dspbaFullDir);
                catch me %#ok<NASGU>
                    dspba.runGeneration('Abort1');
                end
                result={controlBlk,oldControlBlkSettings,signalsBlk,oldSignalsBlkSettings};

            case 'phase2'
                codegenResults=dspba.runGeneration('Phase2','SPath',modelName,'RTLPath',dspbaFullDir);
                codegenResults.RTLPath=dspbaFullDir;


                try
                    hasFloating=dspba.hasFloating(modelName);
                catch me
                    if(isequal(me.identifier,'MATLAB:undefinedVarOrClass'))
                        hasFloating=true;
                    end
                end
                codegenResults.PotentialMismatch=dspba.hasFolding(modelName)||hasFloating;
                targetcodegen.alteradspbadriver.setDSPBACodeGenResults(codegenResults);
            case 'phase3'
                rmdir(dspbaFullDir,'s');
            case 'phase4'
                targetcodegen.alteradspbadriver.checkRates(hdlCoder);
            case 'phase5'
                assert(nargin==3);
                targetcodegen.alteradspbadriver.cleanupDSPBASettings(varargin{:}{:});
            case 'cleanup'
                try
                    dspba.runGeneration('Abort1');
                catch
                end
            otherwise
                assertion('Unknown stage.')
            end
        end

        function checkRates(hdlCoder)

            if(hdlCoder.getParameter('clockinputs')==1)

                dutBaseRate=hdlCoder.PirInstance.getOrigDutBaseRate/hdlCoder.PirInstance.getDutBaseRateScalingFactor;
                codegenResults=targetcodegen.alteradspbadriver.getDSPBACodeGenResults();
                for i=1:length(codegenResults.Islands)
                    ph=get_param(codegenResults.Islands(1).SimulinkPath,'portHandles');
                    if(~isempty(ph.Inport))
                        refPort=ph.Inport(1);
                    elseif(~isempty(ph.Outport))
                        refPort=ph.Outport(1);
                    else
                        assert(0);
                    end
                    islandRate=get_param(refPort,'CompiledSampleTime');

                    if(dutBaseRate<islandRate(1))
                        error(message('hdlcoder:validate:dspbarunonslowrate',num2str(dutBaseRate)))
                    end
                end
            end
        end

        function checkFrequency(modelName,wfaFrequecy)



            signalsBlk=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','DSPBABase/Signals');
            if(isempty(signalsBlk))
                return;
            end

            assert(length(signalsBlk)==1);
            clkFreqSetting=get_param(signalsBlk,'freq');
            if(iscell(clkFreqSetting))
                assert(length(clkFreqSetting)==1);
                clkFreqSetting=clkFreqSetting{1};
            end
            clkFreq=slResolve(clkFreqSetting,modelName);

            if(~isequal(clkFreq,wfaFrequecy))
                error(message('hdlcoder:validate:dspbablkconflictfrequency',num2str(wfaFrequecy),num2str(clkFreq)));
            end
        end

        function[controlBlk,oldControlBlkSettings,signalsBlk,oldSignalsBlkSettings]=setupDSPBASettings(hdlCoder)
            controlBlkSettings(1).field='generate';
            controlBlkSettings(1).targetValue='on';
            controlBlkSettings(end+1).field='autotestbench';
            controlBlkSettings(end).targetValue='off';
            [controlBlk,oldControlBlkSettings]=targetcodegen.alteradspbadriver.setupSettings(hdlCoder.modelName,{'referenceBlock','DSPBABase/Control'},[],controlBlkSettings);

            signalsBlkSettings(1).field='rstactive';
            if(hdlCoder.getParameter('reset_asserted_level'))
                rstactive='High';
            else
                rstactive='Low';
            end
            signalsBlkSettings(1).targetValue=rstactive;
            [signalsBlk,oldSignalsBlkSettings]=targetcodegen.alteradspbadriver.setupSettings(hdlCoder.modelName,{'referenceBlock','DSPBABase/Signals'},[],signalsBlkSettings);

        end

        function cleanupDSPBASettings(controlBlk,oldControlBlkSettings,signalsBlk,oldSignalsBlkSettings)
            targetcodegen.alteradspbadriver.setupSettings([],{},controlBlk,oldControlBlkSettings);
            targetcodegen.alteradspbadriver.setupSettings([],{},signalsBlk,oldSignalsBlkSettings);
        end

        function[controlBlk,oldSettings]=setupSettings(parentPath,findPattens,controlBlk,targetSettings)
            if(isempty(controlBlk))


                controlBlk=find_system(parentPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,findPattens{:});
                assert(length(controlBlk)==1);
                controlBlk=controlBlk{:};
            end

            oldSettings=targetSettings;
            for i=1:length(targetSettings)
                oldSettings(i).targetValue=get_param(controlBlk,oldSettings(i).field);
                set_param(controlBlk,oldSettings(i).field,targetSettings(i).targetValue);
            end
        end


        function dspbaFullDir=getFullDir()
            dspbaFullDir='dspbartl';
        end


        function dspbaBlks=findDSPBABlks(blk)


            dspbaBlks={};
            try
                dspbaBlks=dspba.findIslands(bdroot(blk));
            catch me
                if(strcmpi(me.identifier,'MATLAB:undefinedVarOrClass')||strcmpi(me.identifier,'MATLAB:UndefinedFunction'))
                    return;
                end
                rethrow(me);
            end

            if ischar(dspbaBlks)
                dspbaBlks={dspbaBlks};
            end
        end


        function dspbaCodeGenPath=getDSPBACodeGenPath(varargin)
            dspbaCodeGenPath={};
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            if(isfield(cgInfo,'DSPBACodeGenResults'))
                if(isfield(cgInfo.DSPBACodeGenResults,'DSPBACodeGenPath'))
                    dspbaCodeGenPath=cgInfo.DSPBACodeGenResults.DSPBACodeGenPath;
                end
            end
        end


        function addDSPBACodeGenPath(dspbaCodeGenPath,simulinkPath,varargin)
            data.codeGenPath=dspbaCodeGenPath;
            data.simulinkPath=simulinkPath;
            hdlCurrentDriver=hdlcurrentdriver();
            if(isfield(hdlCurrentDriver.cgInfo,'DSPBACodeGenResults'))
                if(isfield(hdlCurrentDriver.cgInfo.DSPBACodeGenResults,'DSPBACodeGenPath'))
                    hdlCurrentDriver.cgInfo.DSPBACodeGenResults.DSPBACodeGenPath(end+1)=data;
                else
                    hdlCurrentDriver.cgInfo.DSPBACodeGenResults.DSPBACodeGenPath(1)=data;
                end
            else
                codeGenResutls.DSPBACodeGenPath(1)=data;
                hdlCurrentDriver.cgInfo.DSPBACodeGenResults=codeGenResutls;
            end
        end


        function setDSPBACodeGenResults(codegenResults,varargin)
            hdlCurrentDriver=hdlcurrentdriver();
            hdlCurrentDriver.cgInfo.DSPBACodeGenResults=codegenResults;
        end


        function codegenResults=getDSPBACodeGenResults(varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            if(isfield(cgInfo,'DSPBACodeGenResults'))
                codegenResults=cgInfo.DSPBACodeGenResults;
            else
                codegenResults=[];
            end
        end


        function bool=getDSPBAPotentialMismatch(varargin)
            codegenResults=targetcodegen.alteradspbadriver.getDSPBACodeGenResults();
            if(~isempty(codegenResults))
                bool=codegenResults.PotentialMismatch;
            else
                bool=false;
            end
        end


        function bool=isDSPBASubsystem(blockPath)
            islands=targetcodegen.alteradspbadriver.findDSPBABlks(blockPath);
            bool=any(strcmp(islands,[get_param(blockPath,'parent'),'/',get_param(blockPath,'name')]));
        end


        function fileList=getDSPBAHDLFiles(island,hdlOnly,designSpecificOnly)
            fileList={island.Files.Path}';
            hdlOnlyIdx=ones(size(island.Files));
            if(hdlOnly)
                hdlOnlyIdx=strcmpi({island.Files.Type},'vhdl');
            end
            designSpecificOnlyIdx=ones(size(island.Files));
            if(designSpecificOnly)
                designSpecificOnlyIdx=strcmpi({island.Files.Base},'rtl');
            end
            fileList=fileList(hdlOnlyIdx&designSpecificOnlyIdx);
        end


        function str=getDSPBASynthesisScripts(hdlSynthCmd,varargin)
            str='';
            if(targetcodegen.alteradspbadriver.getDSPBALibSynthesisScriptsNeeded(varargin{:}))

                quartusPath=hdlgetpathtoquartus;
                dspbaLibStr=targetcodegen.alteradspbadriver.getDSPBALibSynthesisScripts(quartusPath);
                str=sprintf('%s%s\n',str,dspbaLibStr);
            end

            dspbaCodeGenPath=targetcodegen.alteradspbadriver.getDSPBACodeGenPath(varargin{:});
            if(~isempty(dspbaCodeGenPath))

                for i=1:length(dspbaCodeGenPath)
                    libName=dspbaCodeGenPath(i).codeGenPath;

                    codegenResults=targetcodegen.alteradspbadriver.getDSPBACodeGenResults(varargin{:});
                    islandResults=codegenResults.Islands(strcmp({codegenResults.Islands.SimulinkPath},dspbaCodeGenPath(i).simulinkPath));
                    fileList=targetcodegen.alteradspbadriver.getDSPBAHDLFiles(islandResults,true,true);

                    for j=1:length(fileList)
                        if contains(fileList(j),'_msim.')

                            continue;
                        end
                        fileLocation=fullfile(targetcodegen.alteradspbadriver.getFullDir,fileList{j});
                        fileLocation=strrep(fileLocation,'\','/');
                        addFileStr=sprintf(hdlSynthCmd,fileLocation);
                        addFileStr=sprintf('%s -library %s\n',addFileStr(1:end-1),libName);
                        str=sprintf('%s%s',str,addFileStr);
                    end
                end
            end
        end


        function str=getDSPBALibSynthesisScripts(quartusPath)
            str0=sprintf('set path_to_quartus "%s"\n',quartusPath);
            libFiles=targetcodegen.alteradspbadriver.getDSPBALibFiles();
            strFiles='';
            for i=1:length(libFiles)
                strFiles=sprintf('%sset_global_assignment -name VHDL_FILE $path_to_quartus/%s\n',strFiles,libFiles{i});
            end
            str=[str0,strFiles];
        end



        function setDSPBALibSynthesisScriptsNeeded(needed)
            hdlCurrentDriver=hdlcurrentdriver();
            hdlCurrentDriver.cgInfo.DSPBALibSynthesisScriptsNeeded=needed;
        end



        function needed=getDSPBALibSynthesisScriptsNeeded(varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            if(isfield(cgInfo,'DSPBALibSynthesisScriptsNeeded'))
                needed=cgInfo.DSPBALibSynthesisScriptsNeeded;
            else
                needed=false;
            end
        end

        function needed=getDSPBALibSynthesisScriptsNeededPostMakehdl(varargin)
            codeGenStatus=targetcodegen.basedriver.getCodeGenStatus(varargin{:});
            if(isfield(codeGenStatus,'DSPBALibSynthesisScriptsNeeded'))
                needed=codeGenStatus.DSPBALibSynthesisScriptsNeeded;
            else
                needed=false;
            end
        end


        function addDSPBAAdditionalFiles(fileName,varargin)
            hdlCurrentDriver=hdlcurrentdriver();
            if(isfield(hdlCurrentDriver.cgInfo,'DSPBAAdditionalFiles'))
                hdlCurrentDriver.cgInfo.DSPBAAdditionalFiles{end+1}=fileName;
            else
                hdlCurrentDriver.cgInfo.DSPBAAdditionalFiles{1}=fileName;
            end
        end


        function files=getDSPBAAdditionalFiles(varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            if(isfield(cgInfo,'DSPBAAdditionalFiles'))
                files=cgInfo.DSPBAAdditionalFiles;
            else
                files={};
            end
        end

        function files=getDSPBAAdditionalFilesPostMakehdl(varargin)
            codeGenStatus=targetcodegen.basedriver.getCodeGenStatus(varargin{:});
            if(isfield(codeGenStatus,'DSPBAAdditionalFiles'))
                files=codeGenStatus.DSPBAAdditionalFiles;
            else
                files={};
            end
        end


        function scripts=getDSPBAAdditionalFilesSynthesisScripts(hdlSrcFolder,hdlName,needed,files)

            scripts='';
            if(needed)
                libFiles=targetcodegen.alteradspbadriver.getDSPBALibFiles();
                for jj=1:length(libFiles)
                    [~,fName,fExt]=fileparts(libFiles{jj});
                    libFile=[fName,fExt];
                    scripts=sprintf('%sadd_fileset_file %s %s PATH %s\n',...
                    scripts,libFile,hdlName,[hdlSrcFolder,'/',libFile]);
                end

                for jj=1:length(files)
                    fName=files{jj};
                    [~,~,ext]=fileparts(fName);
                    assert(strcmp(ext,'.mif')||strcmp(ext,'.hex'));

                    scripts=sprintf('%sadd_fileset_file %s %s PATH %s\n',...
                    scripts,files{jj},upper(ext(2:end)),[hdlSrcFolder,'/',files{jj}]);
                end
            end
        end

        function files=getDSPBALibFiles()


            files={'dspba/backend/Libraries/vhdl/base/dspba_library_package.vhd',...
            'dspba/backend/Libraries/vhdl/base/dspba_library.vhd',...
            };
        end
    end
end



