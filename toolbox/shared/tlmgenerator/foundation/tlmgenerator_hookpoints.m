function tlmgenerator_hookpoints(hookPoint,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok















    mdlRefTargetType=get_param(modelName,'ModelReferenceTargetType');
    isNotModelRefTarget=strcmp(mdlRefTargetType,'NONE');
    isVerboseBuild=get_param(modelName,'RTWVerbose');

    if isNotModelRefTarget


        tlmgRoot=fullfile(matlabroot,'toolbox','shared','tlmgenerator','foundation');

        switch hookPoint
        case 'error'




            disp('.');
            disp(['### Simulink Coder build procedure for model: ''',modelName...
            ,''' aborted due to an error.']);
            tlmgenerator_cleanup();

        case 'entry'



            da=Simulink.data.DataAccessor.createForExternalData(modelName);
            varIds=da.identifyVisibleVariablesDerivedFromClass('Simulink.Parameter');

            if~isempty(varIds)
                for i=1:length(varIds)
                    varId=varIds(i);
                    varName=varId.Name;
                    varObj=da.getVariable(varId);
                    ParStorageClass=varObj.get.CoderInfo.StorageClass;
                    if(~strcmp(ParStorageClass,Simulink.data.getNameForModelDefaultSC)&&...
                        ~strcmp(ParStorageClass,'Auto'))
                        error(message('TLMGenerator:TLMTargetCC:BadTunableVarsStorageClass',varName,ParStorageClass));
                    end
                end
            end

            TunableVars=regexp(get_param(modelName,'TunableVars'),'\w+','match');
            TunableVarsStorageClass=regexp(get_param(modelName,'TunableVarsStorageClass'),'\w+','match');
            if~isempty(TunableVarsStorageClass)
                for i=1:length(TunableVarsStorageClass)
                    if(~strcmp(TunableVarsStorageClass(i),Simulink.data.getNameForModelDefaultSC)&&...
                        ~strcmp(TunableVarsStorageClass(i),'Auto'))
                        error(message('TLMGenerator:TLMTargetCC:BadTunableVarsStorageClass',TunableVars{i},TunableVarsStorageClass{i}));
                    end
                end
            end

            disp(['### Starting Simulink Coder build procedure for model: ',modelName]);
            if(~isempty(dir([modelName,'_build'])))
                rmdir([modelName,'_build'],'s');
            end

            assert(builtin('license','checkout','EDA_Simulator_Link')~=0,'TLMGenerator:license','HDL Verifier license checkout failed. Unable to use TLM Generator.');

        case 'before_tlc'




        case 'before_codegen'


        case 'after_codegen'


        case 'after_tlc'







            l_display(isVerboseBuild,'### Starting TLM Component Generation');

        case 'before_make'




        case 'post_code_gen'


            tlmg_build=tlmgenerator_getbuildinfo(modelName,buildInfo);
            tlmg_config=tlmgenerator_getconfigset(modelName);
            setappdata(0,'tlmg_build',tlmg_build);

            targets='TLM Component';
            [s,mess,messid]=mkdir('tlm');%#ok

            if(strcmp(tlmg_config.tlmgGenerateTestbenchOnOff,'on'))
                targets=[targets,' and TLM stand-alone testbench'];
                [s,mess,messid]=mkdir('tlm_tb');%#ok
            end

            l_display(isVerboseBuild,['### Generating ',targets,' code for: ',modelName]);
            tlcEntryFile=fullfile(tlmgRoot,'tlmgenerator_entry.tlc');
            rtwroot=fullfile(matlabroot,'rtw');
            tlcIncludePaths=rtwprivate('getCommonTLCIncludePaths',...
            rtwroot,tlcEntryFile);
            includes=strcat('-I',tlcIncludePaths);
            tlc(tlcEntryFile,includes{:});
            l_display(isVerboseBuild,'.');

        case 'after_make'


            l_saveInfo(modelName);

            l_display(isVerboseBuild,'### Packaging generated TLM code.');
            tlmgenerator_packaging();

            tlmgenerator_report();

            l_setTbExeDir(modelName);

        case 'exit'


            tlmgenerator_launchreport();
            tlmgenerator_cleanup();
            l_display(isVerboseBuild,'.');
            disp(['### Successful completion of Simulink Coder build ',...
            'procedure for model: ',modelName]);

        end

    else

    end

end


function l_saveInfo(modelName)
    tlmg_info=tlmgenerator_getcodeinfo();%#ok<NASGU>
    tlmg_config=tlmgenerator_getconfigset(modelName);%#ok<NASGU>
    tlmg_build=getappdata(0,'tlmg_build');%#ok<NASGU> % will incl SubsystemPath/Name

    save('tlmgInfo.mat','tlmg_info','tlmg_config','tlmg_build');
end





function l_setTbExeDir(modelName)
    cfg=tlmgenerator_getconfigset(modelName);
    if(strcmp(cfg.tlmgGenerateTestbenchOnOff,'on'))

        binfo=getappdata(0,'tlmg_build');
        dut=binfo.OrigMdlDut;
        dut=slsvInternal('slsvEscapeServices','unescapeString',dut);
        currSys=get_param(0,'CurrentSystem');
        try
            set_param(0,'CurrentSystem',bdroot(dut));

            cs=getActiveConfigSet(bdroot);
            cs.setProp('tlmgTbExeDir',cfg.tlmgTbOutDir);
            cs.setProp('tlmgSubsystemPath',binfo.OrigMdlSubsystemPath);
            cs.setProp('tlmgSubsystemName',binfo.OrigMdlSubsystemName);
            l_display(cfg.RTWVerbose,'### Push the ''Verify Generated TLM Component'' button in the TLM Testbench pane to run vectors and check results.');
        catch ME
            set_param(0,'CurrentSystem',currSys);
            rethrow(ME);
        end
        set_param(0,'CurrentSystem',currSys);
    end
end

function l_display(Verbose,string)
    if(strcmp(Verbose,'on'))
        disp(string);
    end
end


