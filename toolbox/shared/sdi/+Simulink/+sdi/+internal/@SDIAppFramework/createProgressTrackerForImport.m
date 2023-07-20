function progTracker=createProgressTrackerForImport(~,varargin)


    progTracker=[];
    varParsers=varargin{1};


    if numel(varargin)>1&&~isempty(varargin{2})
        progTracker=varargin{2};


        progTracker.setCurrentProgressValue(0);

        totalVarSizeInBytes=0;
        for vpIt=1:length(varParsers)
            currVar=varParsers{vpIt}.VariableValue;%#ok
            currVarInfo=whos('currVar');
            totalVarSizeInBytes=totalVarSizeInBytes+currVarInfo.bytes;
        end
        progTracker.changeMaxValue(totalVarSizeInBytes);

        totalSignals=locGetTotalNumSignals(varParsers,0);
        setTotalSignals(progTracker,totalSignals);
        return
    end

    if Simulink.sdi.Instance.isSDIRunning()
        importController=Simulink.sdi.internal.controllers.ImportDialog.getController();
        totalSignals=locGetTotalNumSignals(varParsers,0);
        str=getString(message('SDI:sdi:LoggedDataImportProgress'));
        if isequal(class(varParsers{1}),'Simulink.sdi.internal.import.SimscapeNodeParser')
            progTracker=Simulink.sdi.ProgressTracker(str,totalSignals,true,false);
            return
        end
        if importController.Model.baseWSOrMAT==0

            importer=Simulink.sdi.internal.import.FileImporter.getDefault();
            [~,shortFileName,~]=fileparts(importer.FileName);
            str=getString(message('SDI:sdi:MLDATXReading',shortFileName));
            fileInfo=dir(importer.FileName);
            progTracker=Simulink.sdi.ProgressTracker(str,fileInfo.bytes,true);
        else

            totalVarSizeInBytes=0;
            for vpIt=1:length(varParsers)
                currVar=varParsers{vpIt}.VariableValue;%#ok
                currVarInfo=whos('currVar');
                totalVarSizeInBytes=totalVarSizeInBytes+currVarInfo.bytes;
            end

            progTracker=Simulink.sdi.ProgressTracker(str,totalVarSizeInBytes,true);
        end
        setTotalSignals(progTracker,totalSignals);
    end
end


function totalSignals=locGetTotalNumSignals(varParsers,totalSignals)
    numParsers=length(varParsers);
    for idx=1:numParsers
        if isVariableChecked(varParsers{idx})
            if~isVirtualNode(varParsers{idx})
                totalSignals=totalSignals+1;
                totalChannels=prod(getSampleDims(varParsers{idx}));
                if totalChannels>1
                    totalSignals=totalSignals+totalChannels;
                end
            end
            if isHierarchical(varParsers{idx})
                try
                    totalSignals=locGetTotalNumSignals(...
                    getChildren(varParsers{idx}),totalSignals);
                catch
                end

            end
        end
    end
end
