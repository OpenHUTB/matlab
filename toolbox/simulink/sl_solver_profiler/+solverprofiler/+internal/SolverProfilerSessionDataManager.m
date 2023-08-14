classdef SolverProfilerSessionDataManager<handle












    properties(SetAccess=private)
SPData
    end

    methods

        function obj=SolverProfilerSessionDataManager(data)
            obj.SPData=data;
        end


        function delete(~)

        end


        function sessionData=createSessionData(obj)
            import solverprofiler.internal.SolverProfilerSessionDataClass;

            simlogFileName=[];
            xoutFileName=[];


            simlogHandle=obj.SPData.getSimlog();
            obj.SPData.setSimlog([]);

            if~isempty(simlogHandle)



                if strcmp(simlogHandle.loggingMode,getString(message('physmod:common:logging2:mli:node:kernel:Disk')))
                    [~,simlogFileName]=fileparts(tempname);
                    name='_simlog.mldatx';
                    simlogFileName=[simlogFileName,name];
                    simlogFileName=fullfile(pwd,simlogFileName);
                    simscape.logging.export(simlogHandle,simlogFileName);
                    simlogHandle=simscape.logging.import(simlogFileName);
                end
                obj.SPData.setSimlog(simlogHandle);
            end

            mdl=obj.SPData.getData('Model');
            statesFileName=struct('xout',xoutFileName,'simlog',simlogFileName);
            sessionData=SolverProfilerSessionDataClass(actualData,mdl,statesFileName);
        end


        function saveSessionData(obj,pathname,filename)
            import solverprofiler.internal.SolverProfilerSessionDataClass;

            simlogFileName=[];
            xoutFileName=[];





            simlogHandle=obj.SPData.getSimlog();
            obj.SPData.setSimlog([]);
            SEHandle=obj.SPData.getData('StatesExplorer');
            obj.SPData.setData('StatesExplorer',[]);
            ZEHandle=obj.SPData.getData('ZCExplorer');
            obj.SPData.setData('ZCExplorer',[]);


            actualData.data=obj.SPData;


            if~isempty(simlogHandle)

                if strcmp(simlogHandle.loggingMode,getString(message('physmod:common:logging2:mli:node:kernel:Disk')))
                    simlogFileName=strrep(filename,'.mat','');


                    if simscape.logging.internal.derived_data_logging()
                        name='_simlog.mldatx';
                    else
                        name='_simlog.h5';
                    end
                    simlogFileName=[simlogFileName,name];
                    simlogFileName=fullfile(pathname,simlogFileName);
                    simscape.logging.export(simlogHandle,simlogFileName);
                else
                    actualData.data.setSimlog(simlogHandle);
                end
            end


            if obj.SPData.isStateObjectValid()&&obj.SPData.isStateStreamed()
                xoutFileName=strrep(filename,'.mat','');
                xoutFileName=[xoutFileName,'_xout.mat'];
                xoutFileName=fullfile(pathname,xoutFileName);
                obj.SPData.copyFileToLocation(xoutFileName);
            end





            statesFileName=struct('xout',xoutFileName,'simlog',simlogFileName);


            mdl=obj.SPData.getData('Model');
            sessionData=SolverProfilerSessionDataClass(actualData,mdl,statesFileName);












            oldWarningState=warning('error','MATLAB:save:sizeTooBigForMATFile');

            try
                save(fullfile(pathname,filename),'sessionData');
            catch ME
                if strcmp(ME.identifier,'MATLAB:save:sizeTooBigForMATFile')
                    save(fullfile(pathname,filename),'sessionData','-v7.3','-nocompression');
                else
                    warning(oldWarningState);
                    throw(ME);
                end
            end
            warning(oldWarningState);


            obj.SPData.setSimlog(simlogHandle);
            obj.SPData.setData('StatesExplorer',SEHandle);
            obj.SPData.setData('ZCExplorer',ZEHandle);
        end


        function loadSessionData(obj,sessionData)
            import solverprofiler.util.*


            try




                modelName=sessionData.getModel();
                actualData=sessionData.getActualDataFromSolverProfilerSessionData();
            catch
                id='failedToLoadData:notASessionData';
                msg=utilDAGetString('notASessionDataForCurrentRelease');
                throw(MException(id,msg));
            end

            if~obj.SPData.isSameModel(modelName)
                id='failedToLoadData:notTheSameModel';
                msg=[utilDAGetString('notTheSameModel'),' ',modelName];
                throw(MException(id,msg));
            end


            obj.resetSPData(actualData.data);


            statesFileName=sessionData.getStatesFileName();
            simlogFileName=statesFileName.simlog;
            xoutFileName=statesFileName.xout;

            if~isempty(simlogFileName)&&exist(simlogFileName,'file')==2
                simlogHandle=simscape.logging.import(simlogFileName);
                obj.SPData.setSimlog(simlogHandle);
            end

            if obj.SPData.isStateStreamed()
                if~isempty(xoutFileName)&&exist(xoutFileName,'file')==2
                    obj.SPData.attachStateData(xoutFileName);
                end
            end
        end








    end


    methods(Access=private)


        function resetSPData(obj,data)



            obj.SPData.setSimlog([]);


            obj.SPData.setData('SortedPD',data.releaseSortedPD());


            tout=obj.SPData.getTout();
            obj.SPData.setData('UIStatusAtSim',data.getData('UIStatusAtSim'));
            obj.SPData.setData('OverallDiag',data.OverallDiag);
            obj.SPData.setData('FigureTimeRange',[tout(1)-32*eps,tout(end)+32*eps]);
            obj.SPData.setData('ExceptionTableIndexList',obj.SPData.getRankedFailureStateList());
            obj.SPData.setData('ZCTableIndexList',obj.SPData.getBlockListWithZcEvents());


            obj.SPData.setData('NeedToClearStreamedStates',false);


            obj.SPData.setData('TimerTag',[]);
            obj.SPData.setData('StatesExplorer',[]);
            obj.SPData.setData('ZCTableRowSelected',[]);
            obj.SPData.setData('ExceptionTableRowSelected',[]);
            obj.SPData.setData('ExceptionTableColumnSelected',[]);
            obj.SPData.setData('ResetTableRowSelected',[]);
            obj.SPData.setData('ResetTableColumnSelected',[]);
            obj.SPData.setData('StatisticsTableRowSelected',[]);
            obj.SPData.setData('JacobianTableRowSelected',[]);
            obj.SPData.setData('HilitePath',[]);
            obj.SPData.setData('TabSelected','Statistics');
        end
    end
end
