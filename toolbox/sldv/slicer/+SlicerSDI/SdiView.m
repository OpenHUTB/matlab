


classdef SdiView<handle

    properties(SetAccess=private,GetAccess=public)


sliceCriterion


        runID=[];


        tempSessionFileName=[];
    end

    properties(Constant)
        fileExt='.mldatx';
    end

    properties(Dependent=true,SetAccess=private,GetAccess=public,Hidden=true)
cursorPositions
constraintIntervals
        isEnabled;
    end

    methods
        function obj=SdiView(sc)
            assert(isa(sc,'SliceCriterion'));
            obj.sliceCriterion=sc;
        end

        function pos=get.cursorPositions(obj)
            if obj.isEnabled
                cvd=obj.sliceCriterion.cvd;
                [startTime,stopTime]=cvd.getStartStopTime();
                pos=[startTime,stopTime];
            else
                pos=[];
            end
        end

        function intervals=get.constraintIntervals(obj)
            if obj.isEnabled
                cvd=obj.sliceCriterion.cvd;
                intervals=cvd.getConstraintTimeIntervals();
            else
                intervals=[];
            end
        end

        function yesno=get.isEnabled(obj)
            sc=obj.sliceCriterion;
            yesno=sc.useCvd&&~isempty(sc.cvd);
        end

        function plotSimData(obj)


            success=false;
            if obj.isValidSessionFile()
                try
                    loadSessionFromTempFile(obj);
                    obj.runID=Simulink.sdi.getAllRunIDs();
                    success=~isempty(obj.runID);
                catch

                end
            end
            if~success
                try
                    runName=getRunName(obj);
                    simData=getSimData(obj);
                    if~isempty(simData)
                        rId=Simulink.sdi.createRun(runName,'vars',simData);
                        setCurrentRun(obj,rId,true);
                    end
                catch
                end
            end
        end

        function setCurrentRun(obj,runID,usingSdi)
            obj.runID=runID;
            selectStartingPointSignals(obj);
            if usingSdi
                renameSlicerRun(obj);
                saveSessionToTempFile(obj);
                updateSessionInSlicexFile(obj);
            end
        end

        function renameSlicerRun(obj)
            if~isempty(obj.runID)
                try
                    runObj=Simulink.sdi.getRun(obj.runID);
                    runObj.Name=getRunName(obj);
                catch

                    obj.runID=[];
                end
            end
        end

        function saveSessionToTempFile(obj)
            if obj.isEnabled
                if isempty(obj.tempSessionFileName)
                    obj.tempSessionFileName=getSessionFileName(obj);
                elseif exist(obj.tempSessionFileName,'file')

                    delete(obj.tempSessionFileName);
                end
                allRuns=Simulink.sdi.getAllRunIDs();
                if~isempty(allRuns)
                    Simulink.sdi.save(obj.tempSessionFileName);
                end
            end
        end

        function loadSessionFromTempFile(obj)
            try
                if obj.isValidSessionFile()
                    Simulink.sdi.load(obj.tempSessionFileName);
                end
            catch Mex
                rethrow(Mex);
            end
        end

        function updateSessionInSlicexFile(obj)
            if obj.isEnabled
                try
                    if~isValidSlicexFile(obj)
                        return;
                    end
                    packageName=obj.sliceCriterion.cvFileName;
                    if obj.isValidSessionFile()
                        slcrxPackager.mexHelper('updateSdiData',packageName,obj.tempSessionFileName);
                    end
                catch mex
                    rethrow(mex);
                end
            end
        end

        function extractSessionFromSlicexFile(obj)
            try
                if~isValidSlicexFile(obj)
                    return
                end
                packageName=obj.sliceCriterion.cvFileName;
                if isempty(obj.tempSessionFileName)
                    obj.tempSessionFileName=getSessionFileName(obj);
                else
                    delete(obj.tempSessionFileName);
                end
                slcrxPackager.mexHelper('getSdiData',packageName,obj.tempSessionFileName);
                obj.runID=[];
            catch
                obj.tempSessionFileName=[];
            end
        end
        function clearSessionFile(obj)
            if obj.isValidSessionFile()
                delete(obj.tempSessionFileName);
                obj.tempSessionFileName=[];
            end
        end
    end

    methods(Hidden=true,Access=public)
        function fileName=getSessionFileName(obj)
            sc=obj.sliceCriterion;
            modelH=sc.modelSlicer.modelH;
            [~,slicexName]=fileparts(sc.cvFileName);
            fileName=fullfile(get_param(modelH,'UnpackedLocation'),...
            [slicexName,SlicerSDI.SdiView.fileExt]);
        end
    end

    methods(Access=private)
        function runName=getRunName(obj)
            assert(obj.isEnabled());
            sc=obj.sliceCriterion;
            [~,slicexName]=fileparts(sc.cvFileName);
            runName=[sc.name,' : ',slicexName];
        end

        function simData=getSimData(obj)
            assert(obj.isEnabled());
            cvd=obj.sliceCriterion.cvd;
            simData=cvd.simData;
        end

        function selectStartingPointSignals(obj)
            try
                runObj=Simulink.sdi.getRun(obj.runID);
                loggedPortsH=obj.sliceCriterion.sdiLoggingPointsAll;
                sigCount=runObj.SignalCount;
                for i=1:sigCount
                    sig=runObj.getSignalByIndex(i);
                    ownerH=get_param(sig.BlockPath,'handle');
                    ph=get_param(ownerH,'PortHandles');
                    if sig.PortIndex<=length(ph.Outport)&&...
                        sig.PortIndex>0
                        h=ph.Outport(sig.PortIndex);
                        if ismember(h,loggedPortsH)
                            sig.Checked=true;
                        end
                    end
                end
            catch
            end
        end
        function yesno=isValidSessionFile(obj)
            yesno=false;
            try
                if exist(obj.tempSessionFileName,'file')

                    [~,~,ext]=fileparts(obj.tempSessionFileName);
                    yesno=strcmpi(ext,SlicerSDI.SdiView.fileExt);
                    if yesno
                        descr=matlabshared.mldatx.internal.getDescription(obj.tempSessionFileName);
                        yesno=strcmp(descr,getString(message('SDI:sdi:SDISessionDescription')));
                    end
                end
            catch
            end
        end
        function yesno=isValidSlicexFile(obj)
            yesno=false;
            packageName=obj.sliceCriterion.cvFileName;
            if isempty(packageName)||~exist(packageName,'file')
                return
            end
            [~,~,ext]=fileparts(packageName);
            yesno=strcmp(ext,'.slslicex');
        end
    end
end

