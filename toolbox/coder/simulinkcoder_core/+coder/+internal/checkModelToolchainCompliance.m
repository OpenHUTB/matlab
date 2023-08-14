function output=checkModelToolchainCompliance(config)






    output=checkToolchainCompliance(config);
    if~output.IsTargetCompliant
        return
    end


    output=checkIfUsingDefaultParameters(config,output);




    function output=checkToolchainCompliance(config)
        try
            value=get_param(config,'UseToolchainInfoCompliant');
            compliant=~isempty(value)&&strcmpi(value,'on');
        catch exc %#ok<NASGU>


            compliant=false;
        end
        stf=get_param(config,'SystemTargetFile');
        if compliant
            complianceReport{1}=getString(message('coder_compile:toolchain:UAToolchainInfo_TargetCompliant',stf));
            output.AllParamsCompliant=true;
        else
            complianceReport{1}=getString(message('coder_compile:toolchain:UAToolchainInfo_TargetNotCompliant',stf));
            output.AllParamsCompliant=false;
        end
        output.Target=stf;
        output.IsTargetCompliant=compliant;
        output.TargetComplianceReport=complianceReport;




        function output=checkIfUsingDefaultParameters(config,output)
            STF=get_param(config,'SystemTargetFile');
            fullSTFName=which(STF);
            output.ToolchainOverride=false;
            if~isempty(fullSTFName)




                if isempty(regexp(fullSTFName,regexptranslate('escape',matlabroot),'once'))



                    output.ToolchainOverride=true;
                end
            end
            GenerateMakefile=get_param(config,'GenerateMakefile');
            MakeCommand=get_param(config,'MakeCommand');
            TemplateMakefile=get_param(config,'TemplateMakefile');
            RTWCompilerOptimization=get_param(config,'RTWCompilerOptimization');

            defaultTMF=coder.make.internal.Utils.getDefaultTMF(STF);

            paramStruct=struct(...
            'Parameter','',...
            'DefaultValue',[],...
            'ActualValue',[],...
            'IsCompliant',true,...
            'ComplianceReport',[],...
            'UpgradeMode','',...
            'UpgradeMessage',[],...
            'OtherUpgrades',[]);
            output.Params=repmat(paramStruct,[1,4]);

            output.Params(1).Parameter='GenerateMakefile';
            output.Params(1).DefaultValue='On';
            output.Params(1).ActualValue=GenerateMakefile;

            output.Params(2).Parameter='MakeCommand';
            output.Params(2).DefaultValue='make_rtw';
            output.Params(2).ActualValue=MakeCommand;

            output.Params(3).Parameter='TemplateMakefile';
            output.Params(3).DefaultValue=defaultTMF;
            output.Params(3).ActualValue=TemplateMakefile;

            output.Params(4).Parameter='RTWCompilerOptimization';
            output.Params(4).DefaultValue='off';
            output.Params(4).ActualValue=RTWCompilerOptimization;




            param='GenerateMakefile';
            idx=find(strcmp({output.Params.Parameter},param));
            output.Params(idx).IsCompliant=strcmpi(GenerateMakefile,output.Params(idx).DefaultValue);
            if~output.Params(idx).IsCompliant
                output.Params(idx).ComplianceReport=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultGenMakefileParam'));

                output.Params(idx).UpgradeMode='not-upgradable';
                output.ToolchainOverride=false;
            end




            param='RTWCompilerOptimization';
            idx=find(strcmp({output.Params.Parameter},param));
            if strcmpi(RTWCompilerOptimization,'on')

                output.Params(idx).IsCompliant=false;
                output.Params(idx).ComplianceReport=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultRTWCompilerOptimParam','on'));

                output.Params(idx).UpgradeMode='upgradable';
                output.Params(idx).UpgradeMessage=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultRTWCompilerOptimParam_Rec',...
                output.Params(idx).DefaultValue,'Faster Runs'));
                output.Params(idx).OtherUpgrades={...
                'BuildConfiguration','Faster Runs'};

            elseif strcmpi(RTWCompilerOptimization,'custom')

                output.Params(idx).IsCompliant=false;
                output.Params(idx).ComplianceReport=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultRTWCompilerOptimParam','custom'));

                output.Params(idx).UpgradeMode='not-upgradable';
            end




            param='MakeCommand';
            idx=find(strcmp({output.Params.Parameter},param));

            makeCommandValueType=[];%#ok<NASGU>
            fullMakeCommand=strtrim(MakeCommand);
            [MakeCommand,makeCommandArgs,hasDefault]=getMakeCommandArgs(fullMakeCommand);
            makeCommandValueType=getMakeCommandValueType(MakeCommand,makeCommandArgs,hasDefault);

            switch makeCommandValueType
            case 'default'

            case 'default-with-args'
                output.Params(idx).IsCompliant=false;
                output.Params(idx).ComplianceReport=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultMakeCommandParam_WithArgs',fullMakeCommand));

                output.Params(idx).UpgradeMode='upgradable';
                output.Params(idx).UpgradeMessage=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultMakeCommandParam_WithArgs_Rec','make_rtw',makeCommandArgs{:}));

            case 'default-not-in-MATLAB-root'
                output.Params(idx).IsCompliant=false;
                output.Params(idx).ComplianceReport=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultMakeCommandParam_OutsideMLRoot'));

                if~output.ToolchainOverride
                    output.Params(idx).UpgradeMode='not-upgradable';
                else
                    output.Params(idx).UpgradeMode='upgradable';
                end

            case 'custom'
                output.Params(idx).IsCompliant=false;
                output.Params(idx).ComplianceReport=...
                getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultMakeCommandParam_Custom'));

                if~output.ToolchainOverride
                    output.Params(idx).UpgradeMode='not-upgradable';
                else
                    output.Params(idx).UpgradeMode='upgradable';
                end

            otherwise
                assert(false,['Variable "makeCommandValueType" in ',upper(mfilename),' cannot be empty.']);
            end




            param='TemplateMakefile';
            idx=find(strcmp({output.Params.Parameter},param));

            tmfValueType=getTMFValueType(TemplateMakefile,output.Params(idx).DefaultValue);

            switch tmfValueType
            case 'default'
                output.Params(idx).IsCompliant=true;
            case 'custom'
                if~output.ToolchainOverride
                    output.Params(idx).IsCompliant=false;
                    output.Params(idx).ComplianceReport=...
                    getString(message('coder_compile:toolchain:UAToolchainInfo_NonDefaultTemplateMakefileParam_',TemplateMakefile));
                    output.Params(idx).UpgradeMode='not-upgradable';
                else
                    output.Params(idx).IsCompliant=true;
                end

            otherwise
                assert(false,['Variable "tmfValueType" in ',upper(mfilename),' cannot be empty.']);
            end
            output.AllParamsCompliant=all([output.Params.IsCompliant]);





            function[makeCommand,makeCommandArgs,hasDefault]=getMakeCommandArgs(fullMakeCommand)
                values=regexp(fullMakeCommand,'\s+','split');
                makeCommand=values{1};
                validDefaults={'make_rtw','make_rtw_target'};
                hasDefault=~isempty(strcmp(makeCommand,validDefaults));
                if numel(values)>1
                    makeCommandArgs=values(2:end);
                else
                    makeCommandArgs=[];
                end




                function makeCommandType=getMakeCommandValueType(MakeCommand,makeCommandArgs,hasDefault)

                    if hasDefault
                        makeCommandType='default';

                        makeCommandFile=which(MakeCommand);
                        if isempty(makeCommandFile)
                            makeCommandType='custom';
                        else
                            if iscell(makeCommandFile)
                                makeCommandFile=makeCommandFile{1};
                            end
                            if~contains(makeCommandFile,matlabroot)
                                makeCommandType='default-not-in-MATLAB-root';
                            else
                                if~isempty(makeCommandArgs)
                                    makeCommandType='default-with-args';
                                end
                            end
                        end
                    else
                        makeCommandType='custom';
                    end





                    function tmfValueType=getTMFValueType(TemplateMakefile,defaultTMF)


                        if strcmp(TemplateMakefile,defaultTMF)
                            tmfValueType='default';
                        else
                            tmfValueType='custom';
                        end
