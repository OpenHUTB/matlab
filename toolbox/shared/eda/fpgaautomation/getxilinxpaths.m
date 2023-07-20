function[apipath,supportedise]=getxilinxpaths(varargin)




    apipath=[];
    supportedise=true;

    try

        script_path=xilinx_tool_environment_script(varargin{:});
    catch me
        warning(me.identifier,me.message);
        return;
    end

    if isempty(script_path)




        supportedise=false;
        return;
    else
        [script_loc,script_name]=fileparts(script_path);
        org_dir=pwd;

        try

            cd(script_loc);
            apipath=eval(script_name);
            cd(org_dir);
        catch me
            cd(org_dir);
        end
    end
















    function xilinx=xilinx_ise_path

        xilinx=getenv('XILINX');
        if isempty(xilinx)
            error(message('EDALink:getxilinxpaths:noxilinxenv'));
        end

        xilinx=absolute_path(xilinx);


        xilinx_fileset=fullfile(xilinx,'fileset.txt');
        if exist(xilinx,'dir')==0||exist(xilinx_fileset,'file')==0
            error(message('EDALink:getxilinxpaths:invalidxilinxenv'));
        end



        xilinx_dsp=absolute_path(getenv('XILINX_DSP'));
        if~isempty(xilinx_dsp)&&~strcmp(xilinx,xilinx_dsp)
            xilinx_dsp_fileset=fullfile(xilinx_dsp,'..','fileset.txt');
            if(exist(xilinx_dsp,'dir')==0)||...
                (exist(xilinx_dsp_fileset,'file')==0)||...
                (~strcmp(xilinx,absolute_path(fullfile(xilinx_dsp,'..','..','ISE'))))
                error(message('EDALink:getxilinxpaths:envmismatch'));
            end
        end



        function tag=xilinx_platform_tag
            platform=upper(computer);
            switch platform
            case 'PCWIN'
                tag='nt';
            case 'PCWIN64'
                tag='nt64';
            case 'GLNX86'
                tag='lin';
            case 'GLNXA64'
                tag='lin64';
            otherwise
                error(message('EDALink:getxilinxpaths:unsupportedplatform',platform));
            end



            function script_path=xilinx_tool_environment_script
                xilinx=xilinx_ise_path;
                platform_tag=xilinx_platform_tag;


                sysgen_bin_dir='';
                p=fullfile(xilinx,'sysgen','bin',platform_tag);
                if exist(p,'dir')~=0
                    sysgen_bin_dir=p;
                else

                    p=fullfile(xilinx,'..','DSP_Tools',platform_tag,'sysgen','bin');
                    if exist(p,'dir')~=0
                        sysgen_bin_dir=p;
                    end
                end


                script_path='';
                if~isempty(sysgen_bin_dir)
                    p=fullfile(sysgen_bin_dir,'xltoolenv.p');
                    if exist(p,'file')~=0
                        script_path=p;
                    end
                end



                function abs_path=absolute_path(path)
                    platform=upper(computer);
                    if strcmp(platform,'PCWIN')||strcmp(platform,'PCWIN64')
                        path=lower(path);
                    end
                    current_path=pwd;
                    try
                        cd(path);
                        abs_path=pwd;
                    catch
                        abs_path='';
                    end
                    cd(current_path);
