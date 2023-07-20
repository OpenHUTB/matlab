classdef AlteraSGMII<handle


    methods(Static)

        function folder=detectIPFolder
            folder='';
            [isexist,exepath]=eda.internal.workflow.simpleWhich('quartus');
            if~isexist
                errmsg='Cannot find the Quartus II executables on PATH';
                r=false;
            else
                folder=fullfile(exepath,'..','..','ip','altera','ethernet','altera_eth_tse');
                [r,errmsg]=eda.internal.workflow.AlteraSGMII.validateIPFolder(folder);
            end

            while~r
                prompt=message('EDALink:AlteraSGMII:SourceDirPrompt',errmsg);
                answer=inputdlg(prompt.getString,'Source Directory');
                if isempty(answer)
                    error(message('EDALink:AlteraSGMII:Abort'));
                else
                    folder=answer{1};
                    [r,errmsg]=eda.internal.workflow.AlteraSGMII.validateIPFolder(folder);
                end
            end
            folder=['"',folder,';',fullfile(exepath,'..','..','ip','altera','primitives','altera_std_synchronizer'),'"'];
        end

        function[r,msg]=validateIPFolder(folder)
            r=true;
            msg='';
            if~exist(folder,'dir')
                msg=sprintf('Folder "%s" does not exist',folder);
                r=false;
                return;
            end

            vfilename='altera_tse_pcs_pma.v';
            fullfilepath=fullfile(folder,vfilename);
            if~exist(fullfilepath,'file')
                msg=sprintf('Cannot find file "%s" in folder "%s"',vfilename,libfolder);
                r=false;
                return;
            end
        end

    end


end

