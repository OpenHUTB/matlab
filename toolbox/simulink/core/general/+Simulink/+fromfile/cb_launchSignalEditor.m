function cb_launchSignalEditor(dlgHandle)






    imd=DAStudio.imDialog.getIMWidgets(dlgHandle);
    tag='File name:';
    fileNameEditBox=imd.find('Tag',tag);
    fileName=fileNameEditBox.text;
    [~,JustTheFileName,ext]=fileparts(fileName);

    if isempty(ext)


        ext='.mat';
        fileName=[fileName,'.mat'];
    end
    try


        aFile=iofile.FromFilePreviewMatFile(fileName);
        vars=aFile.whos;
        if~isempty(vars)


            [~,warnStruct]=aFile.importAVariable(vars(1).name);
            if~isempty(warnStruct)
                error(warnStruct.ID,warnStruct.message);
            else
                aDLG=...
                Simulink.sta.Editor('EditMode',false,...
                'Datasource',{aFile,vars(1).name});

                aDLG.setTitle([JustTheFileName,ext]);
                aDLG.show();
            end
        else
            error('Empty Variables');
        end

    catch ME


        dlgSrc=dlgHandle.getSource;
        blkH=dlgSrc.getBlock;
        modelH=blkH.getParent;%#ok<NASGU>

        if strcmp(ME.identifier,'sl_iofile:matfile:unexpectedDataFormat')





            ME=MException('Simulink:logLoadBlocks:FromFileUnsupportedDataType','%s',...
            DAStudio.message('Simulink:logLoadBlocks:FromFileUnsupportedDataType',...
            vars(1).name,...
            fileName));
        end



        msgDetails=ME.message;

        if~isempty(ME.cause)

            msgDetails=[msgDetails,sprintf('\n'),DAStudio.message('MATLAB:MException:CausedBy')];

            whileME=ME.cause{1};


            while~isempty(whileME.cause)


                msgDetails=[msgDetails,whileME.message,sprintf('\n')];%#ok<AGROW>


                whileME=whileME.cause{1};
            end


            msgDetails=[msgDetails,whileME.message];
        end
        sldiagviewer.reportError(msgDetails,'MessageId',ME.identifier,'Component','Simulink','Category','Block');
    end

end
