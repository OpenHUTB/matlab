function varargout=convertToSLDataset(sourceMatFile,destinationMatFile,varargin)




































    nargoutchk(0,2);
    DID_SAVE=false;

    DID_NEED_CONVERSION=false;


    if isstring(sourceMatFile)&&isscalar(sourceMatFile)
        sourceMatFile=char(sourceMatFile);
    end

    if isstring(destinationMatFile)&&isscalar(destinationMatFile)
        destinationMatFile=char(destinationMatFile);
    end

    if~ischar(sourceMatFile)||~exist(sourceMatFile,'file')
        DAStudio.error('sl_sta_general:common:charArrayMATFileExist','sourceMatFile');
    end

    [~,~,sourceExt]=fileparts(sourceMatFile);

    if~strcmp(sourceExt,'.mat')
        DAStudio.error('sl_sta_general:common:charArrayMATFileExist','sourceMatFile');
    end

    if~ischar(destinationMatFile)
        DAStudio.error('sl_sta_general:common:charArrayMATFile','destinationMatFile');
    end

    [destDir,destFile,destExt]=fileparts(destinationMatFile);

    if~strcmp(destExt,'.mat')
        DAStudio.error('sl_sta_general:common:charArrayMATFile','destinationMatFile');
    end

    DOES_DEST_EXIST=exist(destinationMatFile,'file')==2;


    if(nargin>2)


        if isstring(varargin{1})&&isscalar(varargin{1})
            varargin{1}=char(varargin{1});
        end

        if~ischar(varargin{1})
            DAStudio.error('sl_inputmap:inputmap:signalNameChar');
        end
    end


    aFile=iofile.STAMatFile(sourceMatFile);
    theFile.filterStruct.ALLOW_FOR_EACH=false;
    theFile.filterStruct.ALLOW_EMPTY_DS=false;
    theFile.filterStruct.ALLOW_EMPTY_TS=false;

    signalData=import(aFile);

    aStructToSave=struct;

    ds=Simulink.SimulationData.Dataset();
    newName='';
    if~isempty(signalData.Data)


        if~isempty(varargin)
            tempName=varargin{1};
        else

            [~,aSrcFile,~]=fileparts(sourceMatFile);
            tempName=aSrcFile;

        end

        aStrUtil=sta.StringUtil();
        for k=1:length(signalData.Names)
            aStrUtil.addNameContext(signalData.Names{k});
        end

        tempName=aStrUtil.getUniqueName(tempName);

        [aStructToSave,newName,DID_NEED_CONVERSION]=...
        convertSignalsToDataset(signalData.Data,signalData.Names,tempName);

        allFieldNames=fieldnames(aStructToSave);

        if~isempty(allFieldNames)&&DID_NEED_CONVERSION


            if DOES_DEST_EXIST

                backupFile=fullfile(destDir,[destFile,'.mat.backup']);
                [status,~]=copyfile(destinationMatFile,backupFile);
                if status~=1
                    DAStudio.error('sl_sta_general:common:backupWriteFail',backupFile);
                end
            end

            try
                save(destinationMatFile,'-struct','aStructToSave');
                DID_SAVE=true;
            catch ME

                if strcmp(ME.identifier,'MATLAB:save:permissionDenied')
                    DAStudio.error('sl_sta_general:common:writeFail',destinationMatFile);
                else
                    rethrow(ME);
                end
            end

        end
    end

    if nargout>0
        varargout{1}=DID_SAVE;
        varargout{2}=newName;
    end
