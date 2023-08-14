function tlmgenerator_report



    try

        SystemInfo=tlmgenerator_getcodeinfo();
        cfg=tlmgenerator_getconfigset(SystemInfo.Name);


        if(strcmp(cfg.GenerateReport,'on'))
            LaunchReportPrev=get_param(SystemInfo.Name,'LaunchReport');
            setappdata(0,'tlmgLaunchReportPrev',LaunchReportPrev);
            unlock(getActiveConfigSet(SystemInfo.Name));
            set_param(SystemInfo.Name,'LaunchReport','off');
            lock(getActiveConfigSet(SystemInfo.Name));

            prev_pwd=pwd();
            cd('..')

            src_path=fullfile(pwd(),cfg.tlmgCompSrcDir);
            inc_path=fullfile(pwd(),cfg.tlmgCompIncDir);


            cpp_list=dir(fullfile(src_path,['*',cfg.tlmgExt,'*.cpp']));
            for i=1:numel(cpp_list)
                coder.internal.slcoderReport('addFileInfo',SystemInfo.Name,...
                cpp_list(i).name,'interface','source',src_path);
            end

            h_list=dir(fullfile(inc_path,['*',cfg.tlmgExt,'*.h']));
            for i=1:numel(h_list)
                coder.internal.slcoderReport('addFileInfo',SystemInfo.Name,...
                h_list(i).name,'interface','header',inc_path);
            end












            if(strcmp(cfg.tlmgGenerateTestbenchOnOff,'on'))

                src_tb_path=fullfile(pwd(),cfg.tlmgTbSrcDir);
                inc_tb_path=fullfile(pwd(),cfg.tlmgTbIncDir);


                cpp_tb_list=dir(fullfile(src_tb_path,['*',cfg.tlmgTbExt,'*.cpp']));
                for i=1:numel(cpp_tb_list)
                    coder.internal.slcoderReport('addFileInfo',SystemInfo.Name,...
                    cpp_tb_list(i).name,'main','source',src_tb_path);
                end

                h_tb_list=dir(fullfile(inc_tb_path,['*',cfg.tlmgTbExt,'*.h']));
                for i=1:numel(h_tb_list)
                    coder.internal.slcoderReport('addFileInfo',SystemInfo.Name,...
                    h_tb_list(i).name,'main','header',inc_tb_path);
                end









            end

            cd(prev_pwd);

        end

    catch ME
        l_me=MException('TLMGenerator:build','TLMG report: %s',ME.message);
        throw(l_me);
    end

end


