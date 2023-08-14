function verifyTlmComp(this,hDialog)%#ok<INUSD>




    disp('### Starting component verification');


    disp('### Checking available compiler.');

    l_host=computer;
    CC_found=false;

    if(strcmp(l_host,'GLNXA64'))
        CC_found=true;
        make_cmd='make -f makefile.gnu all';

    elseif(strcmp(l_host,'PCWIN64'))
        VSList={};
        for i=1:numel(this.tlmgCompilerSelectVSSupported)
            VSList={VSList{:},this.tlmgCompilerSelectVSSupported{i}{1}};
        end
        res=strcmp(this.tlmgCompilerSelect,VSList);
        if any(res)
            index=find(res);
            VSTools=this.tlmgCompilerSelectVSSupported{index(1)}{2};

            if strcmp(VSTools,'SDK71')
                rootKey='HKEY_LOCAL_MACHINE';
                subKey='SOFTWARE\Wow6432Node\Microsoft\Microsoft SDKs\Windows\v7.1';
                try
                    key=winqueryreg(rootKey,subKey,'InstallationFolder');
                    if~isempty(key)&&exist(key,'dir')==7
                        CC_found=true;
                        vsvarsFile='setup_mssdk71.bat';
                        msvcSDK71SetupFcn(vsvarsFile);
                        VCVarCmd=['"',fullfile(pwd,vsvarsFile),'" && '];
                    end
                catch
                end
            elseif strcmp(VSTools,'VS150COMNTOOLS')
                CC_found=true;
                vsvarsFile='setup_msvc150.bat';
                msvc150SetupFcn(vsvarsFile);
                fid=fopen(vsvarsFile,'a+');
                fprintf(fid,'\nset "VSCMD_START_DIR=%%CD%%"');
                fprintf(fid,'\n"%%VS150COMNTOOLS%%\\..\\..\\VC\\Auxiliary\\Build\\vcvarsall" x64');
                fclose(fid);
                VCVarCmd=['"',fullfile(pwd,vsvarsFile),'" && '];
            else
                env=getenv(VSTools);
                if~isempty(env)&&exist(env,'dir')==7
                    CC_found=true;
                    VCVarCmd=['"%',VSTools,'%\..\..\VC\vcvarsall" x64 && '];
                end
            end
        end

        if CC_found
            make_cmd=[VCVarCmd,'nmake -f makefile.mk all'];

        else
            VSListDisplay='';
            for i=1:numel(VSList)-1
                VSListDisplay=[VSListDisplay,VSList{i},', '];
            end
            VSListDisplay=[VSListDisplay,VSList{numel(VSList)},'.'];
            warndlg(sprintf('%s\n%s\n%s\n%s\n%s',...
            'The TLM Generator cannot find a supported installation of Microsoft(R)',...
            'Visual Studio(R) on this machine',...
            ['TLM Generator supports ',VSListDisplay],...
            'Therefore it will support only the generation of verification',...
            'vectors and will not support testbench compilation and execution.'),...
            'Host partially supported');
        end

    else
        warndlg(sprintf('%s\n%s %s.\n%s\n%s %s.',...
        'The TLM Generator supports only the generation',...
        'of verification vectors on',computer('arch'),...
        'The TLM Generator does not support testbench',...
        'compilation and execution on',computer('arch')),...
        'Host partially supported');
    end

    savedpwd=pwd;

    try

        cd(this.tlmgTbExeDir);


        try
            load(fullfile('utils','tlmgInfo'));
        catch ME
            l_me=MException('TLMGenerator:TLMTargetCC:BadTlmgInfoMat',...
            'Could not load tlmgInfo.mat from ''%s''.  Please regenerate the TLM component and testbench.',...
            this.tlmgTbExeDir);
            l_me=l_me.addCause(ME);
            throw(l_me);
        end


        if(CC_found)
            disp('### Building testbench and TLM component.');
            s=system(make_cmd);
            if(s)
                l_me=MException('TLMGenerator:TLMTargetCC:BadMake',...
                'Build of generated component and testbench failed.  See MATLAB command window.');
                throw(l_me);
            end
        end


        cd(savedpwd);

        ssP=tlmg_build.OrigMdlSubsystemPath;
        ssN=tlmg_build.OrigMdlSubsystemName;
        ssN=slsvInternal('slsvEscapeServices','unescapeString',ssN);
        if(isempty(ssP)),dutName=ssN;
        else dutName=[ssP,'/',ssN];
        end

        tbobj=tlmg.TLMTestbench(ssP,ssN);
        try
            disp('### Running Simulink simulation to capture inputs and expected outputs.')
            tbobj.genVectors();
            cd(this.tlmgTbExeDir);
            tbobj.saveToMatFile('original Simulink signal log');
            tbobj.saveToMatFile('TLM input vectors');
        catch ME
            l_me=MException('TLMGenerator:TLMTargetCC:BadGenVectors',...
            ['Could not capture Simulink data for ''%s'' or could not translate the data to TLM vectors.\n',...
            'Saw following error:\n',...
            '%s'],dutName,ME.message);
            l_me=l_me.addCause(ME);
            throw(l_me);
        end


        exeName=[tlmg_config.tlmgTbCompName,'.exe'];
        if(CC_found)
            disp('### Executing TLM testbench to generate actual outputs.')

            st=false;
            for ii=1:4
                st=(exist(exeName,'file')==2);
                if(st),break;end;
                pause(2);
            end
            if(~st)
                l_me=MException('TLMGenerator:TLMTargetCC:ExeNotFound',...
                ['Build of generated component and testbench succeeded but could',...
                'not find the testbench executable ',exeName,' in ',...
                this.tlmgTbExeDir,'.  Likely to be a file system issue.']);
                throw(l_me);
            end

            s=system(fullfile('.',exeName));

            if(l_hadNonDataFailures(s))
                l_me=MException('TLMGenerator:TLMTargetCC:TbExecErr',...
                'The testbench execution had non-data failures.  Cannot reliably perform data comparison.  Check the testbench log.');
                throw(l_me);
            elseif(l_hadJustDataFailures(s))
                warning(message('TLMGenerator:TLMTargetCC:DataMiscompare'));
            end

            try
                disp('### Comparing expected vs. actual results.');
                tbobj.checkResults();
                disp('### Component verification completed');
            catch ME
                l_me=MException('TLMGenerator:TLMTargetCC:BadCheckResults',...
                'Could not check results for ''%s''.  Saw following error:\n%s',...
                dutName,ME.message);
                l_me=l_me.addCause(ME);
                throw(l_me);
            end
        end

    catch ME
        cd(savedpwd);
        rethrow(ME);
    end

    cd(savedpwd);

end




function dataFailures=l_hadJustDataFailures(s)
    dataFailures=(s==16);
end
function nonDataFailures=l_hadNonDataFailures(s)
    nonDataFailures=((s~=0)&&(~l_hadJustDataFailures(s)));
end



