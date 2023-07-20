function errMsg=checkWritableFile(this)










    errMsg='';


    fPath=fileparts(this.DstFileName);
    if(exist(fPath,'dir')~=7)
        if~mkdir(fPath)
            errMsg=renamePathsToTemp(this);
        end
    end


    if~isdeployed()


        if(ispc()&&(~locIsFileWritable(this.DstFileName)))

            try

                isToClose=strncmpi(this.Format,'rtf',3)||strncmpi(this.Format,'doc',3);

                isToClose=isToClose||~isempty(strfind(this.Format,'docx'));
                if(isToClose)
                    docview(this.DstFileName,'closedoc');
                elseif(strncmpi(this.Format,'pdf',3))
                    pdfmanage('close',this.DstFileName);
                end



            catch ex %#ok<NASGU>
            end

        end

        if(~isdir(this.DstFileName))&&(~locIsFileWritable(this.DstFileName))
            response=questdlg(...
            getString(message('rptgen:rx_db_output:lockedFileMsg',this.DstFileName)),...
            getString(message('rptgen:rx_db_output:lockedFileTitle')),...
            getString(message('rptgen:rx_db_output:guiYes')),getString(message('rptgen:rx_db_output:guiNo')),getString(message('rptgen:rx_db_output:guiRetry')),getString(message('rptgen:rx_db_output:guiYes')));

            if(strcmpi(response,getString(message('rptgen:rx_db_output:guiYes'))))
                errMsg=renamePathsToTemp(this);

            elseif(strcmpi(response,getString(message('rptgen:rx_db_output:guiRetry'))))
                errMsg=this.checkWritableFile();
                return;

            end
        end
    end


    if(~isdir(this.DstFileName))&&(~locIsFileWritable(this.DstFileName))

        error(message('rptgen:rx_db_output:checkWritable',this.DstFileName));
    end


    function isWritable=locIsFileWritable(fileName)









        reportExists=exist(fileName,'file');

        try
            file=java.io.File(fileName);
            rndAccessFile=java.io.RandomAccessFile(file,'rw');
            rndAccessFile.close();
            if~reportExists
                file.delete();
            end
            isWritable=true;
        catch ME %#ok<NASGU>
            isWritable=false;
        end



        function errMsg=renamePathsToTemp(this)

            newDir=tempname;
            mkdir(newDir);

            origDst=this.DstFileName;
            [~,dFile,dExt]=fileparts(this.DstFileName);
            this.DstFileName=fullfile(newDir,[dFile,dExt]);

            [~,sFile,sExt]=fileparts(this.SrcFileName);
            this.SrcFileName=fullfile(newDir,[sFile,sExt]);

            errMsg=getString(message('rptgen:rx_db_output:destUnwritableMsg',origDst,this.DstFileName));
