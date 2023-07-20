function[varargout]=autoblksdrivecycle(varargin)






    block=varargin{1};
    maskMode=varargin{2};
    modelname=bdroot;
    simMode=get_param(modelname,'SimulationStatus');
    if strcmp(simMode,'running')||strcmp(simMode,'paused')||strcmp(simMode,'compiled')||strcmp(simMode,'restarting')
        tmpData=get_param(gcb,'UserData');
        varargout{1}=tmpData(1);
        varargout{2}=tmpData(2);
        varargout{3}=tmpData(3);
        varargout{4}=tmpData(4);
        varargout{5}=tmpData(5);
    else
        accelMode=get_param(block,'outAccPort');
        gearMode=get_param(block,'outGearPort');
        maskObj=Simulink.Mask.get(block);
        plotButton=maskObj.getDialogControl('plotCycle');
        simtimeButton=maskObj.getDialogControl('updateSim');
        outAccUnitObj=maskObj.getParameter('outAccUnit');
        gearBoxObj=maskObj.getParameter('outGearPort');
        gearListObj=maskObj.getParameter('gearList');
        faultMode=get_param(block,'faultOption');
        failMode=get_param(block,'failOption');
        traceMode=get_param(block,'traceOption');

        MdlConfigSet=getActiveConfigSet(modelname);
        cycleDataButton=maskObj.getDialogControl('getData');
        cycleDataButton.Visible='off';
        cycleVarObj=maskObj.getParameter('cycleVar');
        tempFileDir=tempdir;


        userData=get_param(block,'UserData');
        if~isempty(userData)
            userDataVel=userData(1);
        else
            userDataVel=[];
        end
        if isa(userDataVel,'timeseries')
            plotButton.Enabled='on';
        else
            plotButton.Enabled='off';
        end

        if~isa(MdlConfigSet,'Simulink.ConfigSetRef')&&isa(userDataVel,'timeseries')
            simtimeButton.Enabled='on';
        else
            simtimeButton.Enabled='off';
        end































































        cycleList={

        getString(message('autoblks_shared:autoblkDriveCycleNames:FTP72'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:FTP75'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:US06'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:SC03'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HWFET'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NYCC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HUDDS'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:LA92'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:LA92Short'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:IM240'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:UDDS'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:WLTP1'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:WLTP2'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:WLTP3'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ECE1'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ECE4'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:EUDC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ECExtra'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NEDC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ADAC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ArtemisU'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ArtemisR'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Artemis130'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Artemis150'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:JC08'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:JC08Hot'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Japanese10'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Japanese15'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Japanese1015'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:World'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Braunschweig'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Central'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:BusinessA'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:BusinessC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:City'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Neighborhood'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NewY'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:NewYbus'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Manhattan'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HeavyCreep'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HeavyTrans'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:HeavyCruise'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Orange'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:West'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:RTS'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:ETC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:JE05'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCp'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCspc'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdMC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNA'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNB'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:dME'))
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNC'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:CUEDCdNCH'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Wide'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:Workspace'));...
        getString(message('autoblks_shared:autoblkDriveCycleNames:MatOrOther'))
        };
        fileList={
        'cycleFTP72';...
        'cycleFTP75';...
        'cycleUS06';...
        'cycleSC03';...
        'cycleHWFET';...
        'cycleNYCC';...
        'cycleHUDDS';...
        'cycleLA92';...
        'cycleLA92Short';...
        'cycleIM240';...
        'cycleUDDS';...
        'cycleWLTP1';...
        'cycleWLTP2';...
        'cycleWLTP3';...
        'cycleECE15';...
        'cycleECE15Full';...
        'cycleEUDC';...
        'cycleECEUrbanLP';...
        'cycleNEDC';...
        'cycleADACBAB130';...
        'cycleArtUrb';...
        'cycleArtRR';...
        'cycleArtMw130';...
        'cycleArtMw150';...
        'cycleJC08';...
        'cycleJC08H';...
        'cycleJPN10';...
        'cycleJPN15';...
        'cycleJPN1015';...
        'cycleWHVC';...
        'cycleBraun';...
        'cycleCBD';...
        'cycleBACA';...
        'cycleBACC';...
        'cycleCSC';...
        'cycleNRTC';...
        'cycleNYComp';...
        'cycleNYBus';...
        'cycleManBus';...
        'cycleHHDDTCreep';...
        'cycleHHDDTTrans';...
        'cycleHHDDTCruise';...
        'cycleOCBus';...
        'cycleWVU5Peak';...
        'cycleRTS95';...
        'cycleETCFIGE4';...
        'cycleJE05';...
        'cycleCUEDCP';...
        'cycleCUEDCPS';...
        'cycleCUEDCMC';...
        'cycleCUEDCNA';...
        'cycleCUEDCNB';...
        'cycleCUEDCME';...
        'cycleCUEDCNC';...
        'cycleCUEDCNCH'};




        if(exist('drivecycledata','dir')&&exist('cycleJC08H.mat','file')&&exist('cycleWHVC.mat','file'))||strcmp(modelname,'autolibshared')
            cycleDataButton.Visible='off';
            if strcmp(get_param(block,'AttributesFormatString'),'Additional Data Unavailable')
                set_param(block,'AttributesFormatString','');
            end
        elseif exist('drivecycledata','dir')&&exist('cycleJC08.mat','file')&&exist('cycleWHVC.mat','file')&&~exist('cycleJC08H.mat','file')
            cycleDataButton.Visible='off';
            [~,idxJC08H]=intersect(fileList,{'cycleJC08H'});
            cycleList(idxJC08H)=[];
            fileList(idxJC08H)=[];
            if strcmp(get_param(block,'AttributesFormatString'),'Additional Data Unavailable')
                set_param(block,'AttributesFormatString','');
            end
        elseif exist('drivecycledata','dir')&&exist('cycleJC08.mat','file')&&~exist('cycleWHVC.mat','file')
            cycleDataButton.Visible='off';
            [~,idxJC08H]=intersect(fileList,{'cycleJC08H'});
            cycleList(idxJC08H)=[];
            fileList(idxJC08H)=[];
            cycleList=cycleList([1:28,end-2,end-1,end]);
            fileList=fileList(1:28);
            if strcmp(get_param(block,'AttributesFormatString'),'Additional Data Unavailable')
                set_param(block,'AttributesFormatString','');
            end
        else
            cycleDataButton.Visible='on';
            cycleList=cycleList([2,end-2,end-1,end]);
            fileList=fileList(2);
            if strcmp(get_param(block,'AttributesFormatString'),'')
                set_param(block,'AttributesFormatString','Additional Data Unavailable');
            end
        end


        cycleVarObj.TypeOptions=cycleList;

        caseName=get_param(block,'cycleVar');
        caseNum=strcmp(caseName,cycleList);



        if~(strcmp('JC08',cycleList{caseNum})||strcmp('JC08 Hot',cycleList{caseNum}))
            gearListObj.Visible='off';


            gearListObj.TypeOptions={message('autoblks_shared:autoblkDriveCycleSource:blkCmb_gearList_c1').getString(matlab.internal.i18n.locale('en_US'))};
            gearListObj.Value=gearListObj.TypeOptions{1};
        end












        ParamList={'dt',[1,1],{'gte',0};...
        };
        autoblkscheckparams(block,'Drive Cycle Source',ParamList);
        dt=autoblksgetparam(block,'dt','Output sample period',[1,1],'autoerrDrivecycle',{'gte',0});
        if dt==0
            set_param([block,'/Timing Mode'],'OverrideUsingVariant','1');
        else
            set_param([block,'/Timing Mode'],'OverrideUsingVariant','2');
        end

        ParamList={'dt',[1,1],{'gte',0};...
        'maxFaultCnt',[1,1],{'gte',0};...
        'maxFaultTime',[1,1],{'gte',0};...
        'maxTotFaultTime',[1,1],{'gte',0};...
        'dtTrace',[1,1],{'gt',0};...
        'traceWindow',[1,1],{'gt',0};...
        };
        autoblkscheckparams(block,'Drive Cycle Source',ParamList);
        if strcmp(faultMode,'off')
            set_param([block,'/Timing Mode/Continuous/FaultSystem/Fault Mode'],'OverrideUsingVariant','1');
            set_param([block,'/Timing Mode/Discrete/FaultSystem/Fault Mode'],'OverrideUsingVariant','1');
        else
            set_param([block,'/Timing Mode/Continuous/FaultSystem/Fault Mode'],'OverrideUsingVariant','2');
            set_param([block,'/Timing Mode/Discrete/FaultSystem/Fault Mode'],'OverrideUsingVariant','2');
        end


        if strcmp(failMode,'off')
            set_param([block,'/Timing Mode/Continuous/FaultSystem/Fault Mode/Fault On/FailureBlock'],'OverrideUsingVariant','1');
            set_param([block,'/Timing Mode/Discrete/FaultSystem/Fault Mode/Fault On/FailureBlock'],'OverrideUsingVariant','1');
        else
            set_param([block,'/Timing Mode/Continuous/FaultSystem/Fault Mode/Fault On/FailureBlock'],'OverrideUsingVariant','2');
            set_param([block,'/Timing Mode/Discrete/FaultSystem/Fault Mode/Fault On/FailureBlock'],'OverrideUsingVariant','2');
        end

        if strcmp(traceMode,'off')

            set_param([block,'/Timing Mode/Continuous/FaultSystem/TracePlot'],'OverrideUsingVariant','1');
            set_param([block,'/Timing Mode/Discrete/FaultSystem/TracePlot'],'OverrideUsingVariant','1');
        else
            if strcmp(get_param(gcb,'dtTrace'),'0')

                set_param([block,'/Timing Mode/Continuous/FaultSystem/TracePlot'],'OverrideUsingVariant','3');
                set_param([block,'/Timing Mode/Discrete/FaultSystem/TracePlot'],'OverrideUsingVariant','3');
            else

                set_param([block,'/Timing Mode/Continuous/FaultSystem/TracePlot'],'OverrideUsingVariant','2');
                set_param([block,'/Timing Mode/Discrete/FaultSystem/TracePlot'],'OverrideUsingVariant','2');
            end

        end

















        switch maskMode
        case 0
            [~]=autoblksdrivecycle(block,1);
            switch caseName
            case 'Workspace variable'
                updateMask(block,'var');
                varName=get_param(block,'wsVar');
                [DriveCycle,AccelCycle,GearCycle]=processWSvar(block,varName,maskMode);
            case '.mat, .xls, .xlsx or .txt file'
                updateMask(block,'file');

                fileName=get_param(block,'fileVar');
                fileName=strrep(fileName,'''','');



                [pathName,fileName,fileExt]=fileparts(fileName);
                if isempty(pathName)
                    fileName=which([fileName,fileExt]);
                    [pathName,fileName,fileExt]=fileparts(fileName);
                end
                if strcmp(fileExt,'.mat')
                    DriveCycleData=load([pathName,filesep,fileName,'.mat'],'-mat');
                    cycleData=DriveCycleData.(fileName);
                    [DriveCycle,AccelCycle,GearCycle]=processWSvar(block,cycleData,maskMode);





                    if isfield(DriveCycleData,[fileName,'gear'])
                        GearCycle=DriveCycleData.([fileName,'gear']);


                        GearCycle.Data=GearCycle.Data(:,1);
                    end
                elseif strcmp(fileExt,'.xls')||strcmp(fileExt,'.xlsx')
                    [dataImport,txtData,~]=xlsread([pathName,filesep,fileName,fileExt]);

                    [~,cols]=size(txtData);
                    [rows,~]=size(dataImport);


                    dataImport(:,3)=zeros(1,rows);
                    if cols>2
                        dataImport(:,3)=preProcessExcelData(dataImport(:,3),txtData(:,3));
                        dataImport=dataImport(:,1:3);
                    else
                        dataImport=dataImport(:,1:2);
                    end
                    [DriveCycle,AccelCycle,GearCycle]=processWSvar(block,dataImport,maskMode);
                else
                    try
                        textData=importdata([pathName,filesep,fileName,fileExt]);

                        if iscell(textData)
                            textData=reformatCellarray(textData);
                        else
                            if isstruct(textData)
                                [~,cols]=size(textData.data);
                            else
                                error(message('autoblks_shared:autoerrDrivecycle:invalidFile','File name'));
                            end


                            if cols>2

                                textData=preProcessTextData(pathName,fileName,fileExt,tempFileDir,textData.data);
                            end
                        end
                        importedData=textData.data;

                        [DriveCycle,AccelCycle,GearCycle]=processWSvar(block,importedData,maskMode);
                    catch

                        maskObj.getDialogControl('updateSim').Enabled='off';

                        maskObj.getDialogControl('plotCycle').Enabled='off';
                        set_param(block,'tfinal',' ')

                        error(message('autoblks_shared:autoerrDrivecycle:invalidFile','File name'));
                    end
                end
            case 'Wide Open Throttle (WOT)'
                cycleData=processWOT(block,dt);
                [DriveCycle,AccelCycle,GearCycle]=processWSvar(block,cycleData,maskMode);


            otherwise
                updateMask(block,'predef');
                [DriveCycle,AccelCycle,GearCycle]=applyDriveCycle(fileList{caseNum},gearListObj);
                DriveCycle.Name=cycleList{caseNum};
            end



            if~isa(MdlConfigSet,'Simulink.ConfigSetRef')
                simtimeButton.Enabled='on';
            end
            plotButton.Enabled='on';

            if~isempty(DriveCycle)
                if strcmp('on',get_param(gcb,'cycleRepeat'))
                    set_param(block,'tfinal',[num2str(DriveCycle.TimeInfo.End),'  ',DriveCycle.TimeInfo.Units,', Cyclic'])
                else
                    set_param(block,'tfinal',[num2str(DriveCycle.TimeInfo.End),'  ',DriveCycle.TimeInfo.Units])
                end
            end


            if strcmp(accelMode,'off')
                if strcmp(get_param([block,'/Reference Accel'],'BlockType'),'Outport')
                    outAccUnitObj.set('Enabled','off')
                    delete_line(block,'Signal Routing/2','Reference Accel/1');

                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Outport','Name','Reference Accel','built-in/Terminator','noprompt');
                    delete_block(find_system(block,'LookUnderMasks','on','FollowLinks','on','SearchDepth',1,'BlockType','UnitConversion','Name','UnitConversion1'));
                    add_line(block,'Signal Routing/2','Reference Accel/1');
                end
            else
                if strcmp(get_param([block,'/Reference Accel'],'BlockType'),'Terminator')
                    delete_line(block,'Signal Routing/2','Reference Accel/1')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Terminator','Name','Reference Accel','built-in/Outport','noprompt');
                    add_line(block,'Signal Routing/2','Reference Accel/1');
                    outAccUnitObj.set('Enabled','on');
                    AccUnitValue=outAccUnitObj.Value;
                    outAccUnitObj.set('Type','edit');
                    outAccUnitObj.Value=AccUnitValue;

                    setPortOrder(block,accelMode,gearMode,faultMode)

                end

            end



            if~isempty(GearCycle)&&any(GearCycle.Data)

                gearBoxObj.Visible='on';
            else

                set_param(block,'outGearPort','off');
                gearBoxObj.Value='off';
                gearBoxObj.Visible='off';
                if strcmp(get_param([block,'/Gear'],'BlockType'),'Outport')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Outport','Name','Gear','built-in/Terminator','noprompt');
                end
            end

            if strcmp(gearMode,'off')


                if strcmp(get_param([block,'/Gear'],'BlockType'),'Outport')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Outport','Name','Gear','built-in/Terminator','noprompt');
                end
            else

                if strcmp(get_param([block,'/Gear'],'BlockType'),'Terminator')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Terminator','Name','Gear','built-in/Outport','noprompt');

                    setPortOrder(block,accelMode,gearMode,faultMode)
                end



            end



            if strcmp(faultMode,'off')
                if strcmp(get_param([block,'/Info'],'BlockType'),'Outport')
                    delete_line(block,'Signal Routing/4','Info/1');
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Outport','Name','Info','built-in/Terminator','noprompt');
                    add_line(block,'Signal Routing/4','Info/1');
                end
            else
                if strcmp(get_param([block,'/Info'],'BlockType'),'Terminator')
                    delete_line(block,'Signal Routing/4','Info/1')
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Terminator','Name','Info','built-in/Outport','noprompt');
                    add_line(block,'Signal Routing/4','Info/1');

                    setPortOrder(block,accelMode,gearMode,faultMode)
                end


                set_param([block,'/Timing Mode/Continuous/FaultSystem/Fault Mode/upperBound'],'Unit',DriveCycle.DataInfo.Units)
                set_param([block,'/Timing Mode/Continuous/FaultSystem/Fault Mode/lowerBound'],'Unit',DriveCycle.DataInfo.Units)
                set_param([block,'/Timing Mode/Discrete/FaultSystem/Fault Mode/upperBound'],'Unit',DriveCycle.DataInfo.Units)
                set_param([block,'/Timing Mode/Discrete/FaultSystem/Fault Mode/lowerBound'],'Unit',DriveCycle.DataInfo.Units)


                set_param([block,'/Timing Mode/Continuous/FaultSystem/Signal Specification'],'Unit',get_param(block,'outUnit'))
                set_param([block,'/Timing Mode/Continuous/FaultSystem/Signal Specification1'],'Unit',get_param(block,'outUnit'))
                set_param([block,'/Timing Mode/Discrete/FaultSystem/Signal Specification'],'Unit',get_param(block,'outUnit'))
                set_param([block,'/Timing Mode/Discrete/FaultSystem/Signal Specification1'],'Unit',get_param(block,'outUnit'))


                set_param([block,'/Timing Mode/Continuous/FaultSystem/Signal Specification2'],'Unit',get_param(block,'srcUnit'))
                set_param([block,'/Timing Mode/Discrete/FaultSystem/Signal Specification2'],'Unit',get_param(block,'srcUnit'))
                set_param([block,'/Timing Mode/Continuous/FaultSystem/Signal Specification3'],'Unit',get_param(block,'inUnit'))
                set_param([block,'/Timing Mode/Discrete/FaultSystem/Signal Specification3'],'Unit',get_param(block,'inUnit'))

            end



            if strcmp(faultMode,'on')||strcmp(traceMode,'on')
                if strcmp(get_param([block,'/VelFdbk'],'BlockType'),'Ground')
                    delete_line(block,'VelFdbk/1','Timing Mode/1');
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Ground','Name','VelFdbk','built-in/Inport','noprompt');
                    add_line(block,'VelFdbk/1','Timing Mode/1')
                end
                set_param([block,'/Timing Mode/Discrete/FaultSystem/traceUnit'],'Unit',get_param(block,'outUnit'))
                set_param([block,'/Timing Mode/Continuous/FaultSystem/traceUnit'],'Unit',get_param(block,'outUnit'))
                set_param([block,'/Timing Mode/Continuous/FaultSystem/Signal Specification3'],'Unit',get_param(block,'inUnit'))
                set_param([block,'/Timing Mode/Discrete/FaultSystem/Signal Specification3'],'Unit',get_param(block,'inUnit'))
                set_param([block,'/VelFdbk'],'Unit',get_param(block,'inUnit'))
            else
                if strcmp(get_param([block,'/VelFdbk'],'BlockType'),'Inport')
                    delete_line(block,'VelFdbk/1','Timing Mode/1');
                    replace_block(block,'SearchDepth',1,'FollowLinks','on','BlockType','Inport','Name','VelFdbk','built-in/Ground','noprompt');
                    add_line(block,'VelFdbk/1','Timing Mode/1')
                end
            end

            [upperBound,lowerBound]=calcFaultBounds(block,DriveCycle);

            set_param(block,'UserData',[DriveCycle,AccelCycle,GearCycle,upperBound,lowerBound])

        case 1
            upperBound=[];
            lowerBound=[];
            switch caseName
            case 'Workspace variable'
                updateMask(block,'var');
                varName=get_param(block,'wsVar');
                [DriveCycle,AccelCycle,GearCycle]=processWSvar(block,varName,maskMode);

                if isempty(DriveCycle)
                    simtimeButton.Enabled='off';
                    plotButton.Enabled='off';
                    set_param(block,'UserData',[])
                    h=get_param(block,'Handle');
                    set(h,'tfinal',' ');
                else
                    if~isa(MdlConfigSet,'Simulink.ConfigSetRef')
                        simtimeButton.Enabled='on';
                    end
                    plotButton.Enabled='on';

                end
            case '.mat, .xls, .xlsx or .txt file'
                updateMask(block,'file');
                if isa(userDataVel,'timeseries')
                    DriveCycle=userData(1);
                    AccelCycle=userData(2);
                    GearCycle=userData(3);
                    upperBound=userData(4);
                    lowerBound=userData(5);
                else
                    plotButton.Enabled='off';
                    set_param(block,'tfinal',' ');
                    simtimeButton.Enabled='off';
                    plotButton.Enabled='off';
                    DriveCycle=[];
                    AccelCycle=[];
                    GearCycle=[];
                    set_param(block,'UserData',[])
                end
            case 'Wide Open Throttle (WOT)'
                updateMask(block,'WOT');
                set_param(block,'tfinal',' ');
                DriveCycle=[];
                AccelCycle=[];
                GearCycle=[];
                if~isa(MdlConfigSet,'Simulink.ConfigSetRef')
                    simtimeButton.Enabled='on';
                    plotButton.Enabled='on';
                end
            otherwise
                updateMask(block,'predef');
                [DriveCycle,AccelCycle,GearCycle]=applyDriveCycle(fileList{caseNum},gearListObj);


                if~isa(MdlConfigSet,'Simulink.ConfigSetRef')
                    simtimeButton.Enabled='on';
                    plotButton.Enabled='on';
                end
                if strcmp('on',get_param(gcb,'cycleRepeat'))
                    set_param(block,'tfinal',[num2str(DriveCycle.TimeInfo.End),'  ',DriveCycle.TimeInfo.Units,'Cyclic'])
                else
                    set_param(block,'tfinal',[num2str(DriveCycle.TimeInfo.End),'  ',DriveCycle.TimeInfo.Units])
                end
                DriveCycle.Name=cycleList{caseNum};
            end

        case 2
            updateMask(block,'file');
            set_param(block,'cycleVar',length(cycleList)-1);
            [fileName,pathName,~]=uigetfile({'*.mat';'*.xls';'*.xlsx';'*.txt';'*.*'},'File Selector');
            if fileName~=0
                set_param(block,'fileVar',fullfile(pathName,fileName));
            else
                DriveCycle=[];
                AccelCycle=[];
                GearCycle=[];
                upperBound=[];
                lowerBound=[];
                varargout{1}=DriveCycle;
                varargout{2}=AccelCycle;
                varargout{3}=GearCycle;
                return;
            end
            try
                MaskData=get_param(block,'UserData');
                DriveCycle=MaskData(1);
                AccelCycle=MaskData(2);
                GearCycle=MaskData(3);
                upperBound=MaskData(4);
                lowerBound=MaskData(5);
                if strcmp('on',get_param(gcb,'cycleRepeat'))
                    set_param(block,'tfinal','Cyclic')
                else
                    set_param(block,'tfinal',[num2str(DriveCycle.TimeInfo.End),'  ',DriveCycle.TimeInfo.Units])
                end
            catch
                upperBound=[];
                lowerBound=[];

            end
        case 3


            MaskData=get_param(block,'UserData');
            DriveCycle=MaskData(1);
            AccelCycle=MaskData(2);
            GearCycle=MaskData(3);
            upperBound=MaskData(4);
            lowerBound=MaskData(5);
            if strcmp('on',get_param(gcb,'cycleRepeat'))
                set_param(block,'tfinal','Cyclic')
            else
                set_param(block,'tfinal',[num2str(DriveCycle.TimeInfo.End),' ',DriveCycle.TimeInfo.Units])
            end
            if~isempty(DriveCycle)&&~isa(MdlConfigSet,'Simulink.ConfigSetRef')
                set_param(modelname,'StartTime','0','StopTime',num2str(DriveCycle.TimeInfo.End));
                simtimeButton.Enabled='off';
                plotButton.Enabled='on';
            end
        case 4
            [DriveCycle,AccelCycle,GearCycle,upperBound,lowerBound]=autosharedicon('autolibdrivecycle',gcb,0);

            if strcmp('on',get_param(gcb,'cycleRepeat'))
                set_param(block,'tfinal','Cyclic')
            else
                set_param(block,'tfinal',[num2str(DriveCycle.TimeInfo.End),'  ',DriveCycle.TimeInfo.Units])
            end
            if~isempty(DriveCycle)
                try
                    figH=figure;
                    set(figH,'Units','normalized');
                    set(figH,'Position',[0.1,0.1,0.5,0.5]);
                    set(figH,'Name',DriveCycle.Name);
                    set(figH,'NumberTitle','off');
                    title(DriveCycle.Name)
                    srcUnit=get_param(block,'srcUnit');
                    outUnit=get_param(block,'outUnit');
                    DestinationData=autoblksunitconv(DriveCycle.Data,srcUnit,outUnit);
                    outAccPort=get_param(block,'outAccPort');
                    outGearPort=get_param(block,'outGearPort');
                    if strcmp(outAccPort,'off')&&strcmp(outGearPort,'off')
                        plot(DriveCycle.Time,DestinationData)
                        if strcmp(faultMode,'on')
                            hold on
                            plot(upperBound.Time,autoblksunitconv(upperBound.Data,srcUnit,outUnit),'--')
                            plot(lowerBound.Time,autoblksunitconv(lowerBound.Data,srcUnit,outUnit),'--')
                            legend(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_drivecycle')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_upperlim')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_lowerlim')))
                            ylim([0,max(autoblksunitconv(upperBound.Data,srcUnit,outUnit))+2]);
                            hold off
                        end
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_vel',outUnit)));
                        title(DriveCycle.Name)
                    elseif strcmp(outAccPort,'on')&&strcmp(outGearPort,'off')
                        subplot(2,1,1)
                        plot(DriveCycle.Time,DestinationData)
                        if strcmp(faultMode,'on')
                            hold on
                            plot(upperBound.Time,autoblksunitconv(upperBound.Data,srcUnit,outUnit),'--')
                            plot(lowerBound.Time,autoblksunitconv(lowerBound.Data,srcUnit,outUnit),'--')
                            legend(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_drivecycle')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_upperlim')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_lowerlim')))
                            ylim([0,max(autoblksunitconv(upperBound.Data,srcUnit,outUnit))+2]);
                            hold off
                        end
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_vel',outUnit)));
                        title(DriveCycle.Name)
                        subplot(2,1,2)
                        srcAccUnit=get_param(block,'srcAccUnit');
                        outAccUnit=get_param(block,'outAccUnit');
                        DestinationData=autoblksunitconv(AccelCycle.Data,srcAccUnit,outAccUnit);
                        plot(AccelCycle.Time,DestinationData)
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_acc',outAccUnit)));
                    elseif strcmp(outAccPort,'off')&&strcmp(outGearPort,'on')
                        subplot(2,1,1)
                        plot(DriveCycle.Time,DestinationData)
                        if strcmp(faultMode,'on')
                            hold on
                            plot(upperBound.Time,autoblksunitconv(upperBound.Data,srcUnit,outUnit),'--')
                            plot(lowerBound.Time,autoblksunitconv(lowerBound.Data,srcUnit,outUnit),'--')
                            legend(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_drivecycle')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_upperlim')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_lowerlim')))
                            ylim([0,max(autoblksunitconv(upperBound.Data,srcUnit,outUnit))+2]);
                            hold off
                        end
                        title(DriveCycle.Name)
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_vel',outUnit)));
                        subplot(2,1,2)
                        plot(GearCycle.Time,GearCycle.Data)
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_gear')));
                    else
                        subplot(3,1,1)
                        plot(DriveCycle.Time,DestinationData)
                        if strcmp(faultMode,'on')
                            hold on
                            plot(upperBound.Time,autoblksunitconv(upperBound.Data,srcUnit,outUnit),'--')
                            plot(lowerBound.Time,autoblksunitconv(lowerBound.Data,srcUnit,outUnit),'--')
                            legend(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_drivecycle')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_upperlim')),...
                            getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:legend_lowerlim')))
                            ylim([0,max(autoblksunitconv(upperBound.Data,srcUnit,outUnit))+2]);
                            hold off
                        end
                        title(DriveCycle.Name)
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_vel',outUnit)));
                        subplot(3,1,2)
                        srcAccUnit=get_param(block,'srcAccUnit');
                        outAccUnit=get_param(block,'outAccUnit');
                        DestinationData=autoblksunitconv(AccelCycle.Data,srcAccUnit,outAccUnit);
                        plot(AccelCycle.Time,DestinationData)
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_acc',outAccUnit)));
                        subplot(3,1,3)
                        plot(GearCycle.Time,GearCycle.Data)
                        ylabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:ylabel_gear')));
                    end
                    xlabel(getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:xlabel_time')));


                catch
                    error(message('autoblks_shared:autoerrDrivecycle:invalidPlot','Plot variable'));
                end
            end
        case 5
            updateMask(block,'outAccPort')
            MaskData=get_param(block,'UserData');

            if~isempty(MaskData)
                DriveCycle=MaskData(1);
                AccelCycle=MaskData(2);
                GearCycle=MaskData(3);
                upperBound=MaskData(4);
                lowerBound=MaskData(5);
            else
                DriveCycle=[];
                AccelCycle=[];
                GearCycle=[];
                upperBound=[];
                lowerBound=[];
            end
        case 6
            MaskData=get_param(block,'UserData');
            if~isempty(MaskData)
                DriveCycle=MaskData(1);
                AccelCycle=MaskData(2);
                GearCycle=MaskData(3);
                upperBound=MaskData(4);
                lowerBound=MaskData(5);
            else
                DriveCycle=[];
                AccelCycle=[];
                GearCycle=[];
                upperBound=[];
                lowerBound=[];
            end
        case 8
            DriveCycle=[];
            AccelCycle=[];
            GearCycle=[];
            upperBound=[];
            lowerBound=[];
            open_system(block,'mask');

        case 9
            error(message('autoblks_shared:autoerrDrivecycle:invalidEditTime'));
        case 10
            updateMask(block,'faultOption')
            DriveCycle=[];
            AccelCycle=[];
            GearCycle=[];
            upperBound=[];
            lowerBound=[];
        case 11
            updateMask(block,'failOption')
            MaskData=get_param(block,'UserData');
            if~isempty(MaskData)
                DriveCycle=MaskData(1);
                AccelCycle=MaskData(2);
                GearCycle=MaskData(3);
                upperBound=MaskData(4);
                lowerBound=MaskData(5);
            else
                DriveCycle=[];
                AccelCycle=[];
                GearCycle=[];
                upperBound=[];
                lowerBound=[];
            end
        case 12
            updateMask(block,'traceOption')
            MaskData=get_param(block,'UserData');

            if~isempty(MaskData)
                DriveCycle=MaskData(1);
                AccelCycle=MaskData(2);
                GearCycle=MaskData(3);
                upperBound=MaskData(4);
                lowerBound=MaskData(5);
            else
                DriveCycle=[];
                AccelCycle=[];
                GearCycle=[];
                upperBound=[];
                lowerBound=[];
            end
        otherwise
            simtimeButton.Enabled='off';
            plotButton.Enabled='off';
            return
        end
        varargout{1}=DriveCycle;
        varargout{2}=AccelCycle;
        varargout{3}=GearCycle;
        varargout{4}=upperBound;
        varargout{5}=lowerBound;
    end
end



function updateMask(block,type)
    accelMode=get_param(block,'outAccPort');
    faultMode=get_param(block,'faultOption');
    failMode=get_param(block,'failOption');
    traceMode=get_param(block,'traceOption');
    switch type
    case 'file'
        autoblksenableparameters(block,{'fileVar','srcUnit'},{'wsVar'},[],{'wotParam'});
        updateMask(block,'outAccPort')
    case 'var'
        autoblksenableparameters(block,{'wsVar','srcUnit'},{'fileVar'},[],{'wotParam'});
        updateMask(block,'outAccPort')

    case 'outAccPort'

        if strcmp(accelMode,'off')
            autoblksenableparameters(block,[],{'srcAccUnit','outAccUnit'},[],[],false);
        else



            autoblksenableparameters(block,{'outAccUnit'},[],[],[],false);
            autoblksenableparameters(block,{'srcAccUnit'},[],[],[],true);
            set_param(block,'srcAccUnit',[get_param(block,'srcUnit'),'/s']);

        end
    case{'faultOption','traceOption'}
        if strcmp(faultMode,'off')&&strcmp(traceMode,'off')
            autoblksenableparameters(block,[],{'failOption','velBnd','velBndUnit','inUnit','timeBnd','dtTrace','traceWindow'},[],'failParam',true);
        elseif strcmp(faultMode,'off')&&strcmp(traceMode,'on')
            autoblksenableparameters(block,{'inUnit','dtTrace','traceWindow'},{'failOption','velBnd','velBndUnit','timeBnd'},[],{'failParam'},true);
        elseif strcmp(faultMode,'on')&&strcmp(traceMode,'off')
            autoblksenableparameters(block,{'failOption','velBnd','velBndUnit','inUnit','timeBnd'},[],[],[],true);
            updateMask(block,'failOption')
        else
            autoblksenableparameters(block,{'failOption','velBnd','velBndUnit','inUnit','timeBnd','dtTrace','traceWindow'},[],[],[],true);
            updateMask(block,'failOption')
        end
    case 'failOption'
        if strcmp(failMode,'off')
            autoblksenableparameters(block,[],[],[],{'failParam'},true);
        else
            autoblksenableparameters(block,[],[],{'failParam'},[],true);
        end
    case 'WOT'
        autoblksenableparameters(block,{'srcUnit'},{'wsVar'},{'wotParam'},[]);
        updateMask(block,'outAccPort')
    otherwise
        set_param(block,'srcUnit','m/s')
        autoblksenableparameters(block,[],{'wsVar','fileVar'},[],{'wotParam'});
        autoblksenableparameters(block,[],{'srcUnit','srcAccUnit'},[],[],false);
        updateMask(block,'outAccPort')
    end

end


function[cycleData,cycleAccData,cycleGearData]=applyDriveCycle(cycleName,gearList)
    DriveCycleData=load(cycleName,'-mat');
    cycleData=DriveCycleData.(cycleName);
    cycleAccData=DriveCycleData.([cycleName,'acc']);



    cycleGearData=cycleData;
    cycleGearData.Data(:)=0;
    cycleGearData.Time=cycleData.Time;


    if isfield(DriveCycleData,[cycleName,'gear'])
        cycleGearData=DriveCycleData.([cycleName,'gear']);




        if strcmp(cycleName,'cycleJC08')
            if strcmp(gearList.Visible,'off')
                gearList.Visible='on';
                gearList.TypeOptions=[{'SFT_A'},{'SFT_B'},{'SFT_C'}];
                gearList.Value=gearList.TypeOptions{1};
            end


            idx=find(strcmp(gearList.Value,gearList.TypeOptions));
            cycleGearData.Data=cycleGearData.Data(:,idx);

        elseif strcmp(cycleName,'cycleJC08H')
            if strcmp(gearList.Visible,'off')
                gearList.Visible='on';
                gearList.TypeOptions=[{'AT'},{'3+ODMT'},{'5MT'},{'6MT'}];
                gearList.Value=gearList.TypeOptions{1};
            end


            idx=find(strcmp(gearList.Value,gearList.TypeOptions));
            cycleGearData.Data=cycleGearData.Data(:,idx);
        else

            cycleGearData.Data=cycleGearData.Data(:,1);
        end

    end

end


function[DriveCycle,AccelCycle,GearCycle]=processWSvar(block,WSVar,maskMode)

    if ischar(WSVar)
        try
            WSVar=evalin('base',WSVar,[]);
        catch
            DriveCycle=[];%#ok<NASGU>
            AccelCycle=[];
            GearCycle=[];%#ok<NASGU>
        end
    end
    if isempty(WSVar)&&maskMode==0

        error(message('autoblks_shared:autoerrDrivecycle:invalidExist','Drive Cycle Variable'));

    elseif isnumeric(WSVar)
        [DriveCycle,GearCycle]=processWSArray(block,WSVar);

    elseif isstruct(WSVar)
        [DriveCycle,GearCycle]=processWSStruct(block,WSVar);

    elseif isa(WSVar,'timeseries')
        [DriveCycle,GearCycle]=processWSTimeSeries(block,WSVar);

    else
        bIsEditTime=isEditTimeUpdate(block);
        if~bIsEditTime
            error(message('autoblks_shared:autoerrDrivecycle:invalidType','Drive Cycle Variable'));
        end
        DriveCycle=[];
        AccelCycle=[];
        GearCycle=[];
    end
    if~isempty(DriveCycle)
        DriveCycle.DataInfo.Units=get_param(block,'srcUnit');

        if any(diff(diff(DriveCycle.Time))>=1e-10)
            error(message('autoblks_shared:autoerrDrivecycle:nonunisample','Drive Cycle Variable'));
        else
            dt=DriveCycle.Time(2)-DriveCycle.Time(1);
            AccelCycle=DriveCycle;
            AccelCycle.Data=autoblks_sgolay(DriveCycle.Data,dt,2,3);
            AccelCycle.DataInfo.Units=get_param(block,'srcAccUnit');
        end
    end
end

function cycleData=processWOT(block,dt)


    ParamList={'xdot_woto',[1,1],{};...
    't_wot1',[1,1],{'gt',0;'lt','t_wot2';'lt','t_wotend'};...
    'xdot_wot1',[1,1],{};...
    't_wot2',[1,1],{'gt','t_wot1';'lt','t_wotend'};...
    'xdot_wot2',[1,1],{};...
    't_wotend',[1,1],{'gt','t_wot2';'gt','t_wot1'};...
    };

    wotParams=autoblkscheckparams(block,ParamList);
    wotParams.t_wotend=ceil(wotParams.t_wotend);




    if dt<=0
        dtWOT=0.1;
    else
        dtWOT=dt;
    end
    tvec=0:dtWOT:wotParams.t_wotend;
    xdotvec=interp1([0,wotParams.t_wot1,wotParams.t_wot1+dtWOT,...
    wotParams.t_wot2,wotParams.t_wot2+dtWOT,wotParams.t_wotend],...
    [wotParams.xdot_woto,wotParams.xdot_woto,wotParams.xdot_wot1,...
    wotParams.xdot_wot1,wotParams.xdot_wot2,wotParams.xdot_wot2],tvec,'linear');
    cycleData=[tvec',xdotvec'];

end

function[bIsEditTime]=isEditTimeUpdate(block)
    aSimulationStatus=get_param(bdroot(block),'SimulationStatus');
    bIsEditTime=strcmp(aSimulationStatus,'stopped');
end


function[DriveCycle,GearCycle]=processWSArray(block,WSArray)

    [m,n]=size(WSArray);
    if m<1||n<2

        error(message('autoblks_shared:autoerrDrivecycle:invalidFormat','Drive Cycle Variable'));
    else
        timeData=WSArray(:,1);
        if all((diff(timeData)))
            if isempty(WSArray)||any([any(isnan(WSArray)),any(isinf(WSArray))])
                error(message('autoblks_shared:autoerrDrivecycle:emptInfNan','Drive Cycle Variable'));
            end
            DriveCycle=timeseries;
            DriveCycle.Time=timeData;


            DriveCycle.Data=WSArray(:,2);

            DriveCycle.Name=getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:Custom'));
            DriveCycle.DataInfo.Units=get_param(block,'srcUnit');



            GearCycle=timeseries;
            GearCycle.Data=zeros(m,1);
            GearCycle.Time=DriveCycle.Time;


            if n>2
                GearCycle.Data=WSArray(:,3);
            end
        else
            error(message('autoblks_shared:autoerrDrivecycle:invalidTime','Drive Cycle Variable'));

        end
    end
end


function[DriveCycle,GearCycle]=processWSStruct(block,WSStruct)




    if isfield(WSStruct,'time')
        sigNames=fieldnames(WSStruct);
        if any(strcmp(sigNames,'signals'))&&any(strcmp(sigNames,'time'))
            [m,n]=size(WSStruct.signals.values);
            if m<=1
                error(message('autoblks_shared:autoerrDrivecycle:noTime','Drive Cycle Variable'));
            end
            if isempty(WSStruct.signals.values)||any([any(isnan(WSStruct.signals.values)),any(isinf(WSStruct.signals.values))])
                error(message('autoblks_shared:autoerrDrivecycle:emptInfNan','Drive Cycle Variable'));
            end

            timeData=WSStruct.time;

            if all((diff(timeData)))
                DriveCycle=timeseries;
                DriveCycle.Time=timeData;


                DriveCycle.Data=WSStruct.signals.values(:,1);

                DriveCycle.Name=getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:Custom'));
                DriveCycle.DataInfo.Units=get_param(block,'srcUnit');


                GearCycle=timeseries;
                GearCycle.Data=zeros(m,1);
                GearCycle.Time=DriveCycle.Time;


                if n>1
                    GearCycle.Data=WSStruct.signals.values(:,2);
                end
            else
                error(message('autoblks_shared:autoerrDrivecycle:invalidTime','Drive Cycle Variable'));
            end
        else
            error(message('autoblks_shared:autoerrDrivecycle:notFromWSStruct','Drive Cycle Variable'));
        end
    end

end



function[DriveCycle,GearCycle]=processWSTimeSeries(block,WSTimeSeries)

    timeData=WSTimeSeries.Time;
    [m,n]=size(WSTimeSeries.Data);

    if m<=1
        error(message('autoblks_shared:autoerrDrivecycle:noTime','Drive Cycle Variable'));
    end
    if isempty(WSTimeSeries.Data)||any([any(isnan(WSTimeSeries.Data)),any(isinf(WSTimeSeries.Data))])
        error(message('autoblks_shared:autoerrDrivecycle:emptInfNan','Drive Cycle Variable'));
    end

    idx=1;
    DriveCycle=timeseries;
    if timeData(1)~=0||idx==1
        DriveCycle.Time=timeData+(idx-1).*timeData(end);
        DriveCycle.Data=WSTimeSeries.Data(:,idx);
    else
        DriveCycle.Time=timeData(2:end)+(idx-1).*timeData(end);
        DriveCycle.Data=WSTimeSeries.Data(2:end,idx);
    end
    DriveCycle.DataInfo.Units=get_param(block,'srcUnit');
    DriveCycle.Name=getString(message('autoblks_shared:autoblkDriveCycleSourcePlot:drvCyc',num2str(idx)));


    if n>1
        GearCycle=timeseries;
        GearCycle.Data=WSTimeSeries.Data(:,2);
        GearCycle.Time=DriveCycle.Time;


    else


        GearCycle=timeseries;
        GearCycle.Data=zeros(m,1);
        GearCycle.Time=DriveCycle.Time;
    end
end


function processedData=preProcessExcelData(numericData,textData)


    numericRows=length(numericData);
    textRows=length(textData);

    headerOffset=textRows-numericRows;


    odVal=max(numericData)+1;

    for idx=(headerOffset+1):textRows
        if~isempty(textData{idx})
            switch textData{idx}
            case 'P'
                numericData(idx-headerOffset)=80;
            case 'R'
                numericData(idx-headerOffset)=-1;
            case 'N'
                numericData(idx-headerOffset)=0;
            case 'D'
                numericData(idx-headerOffset)=2;
            case 'L'
                numericData(idx-headerOffset)=1;
            case 'OD'
                numericData(idx-headerOffset)=odVal;
            otherwise
                numericData(idx-headerOffset)=0;
            end

        end
    end
    processedData=numericData;
end


function processedData=preProcessTextData(path,file,ext,tempDirName,data)








    odValChar=num2str(max(data(:))+1);
    fileId=fopen([path,filesep,file,ext],'rt');
    rawData=fread(fileId);
    fclose(fileId);
    charData=char(rawData.');
    charsToReplace={'P','R','N','D','L','OD'};
    replacementVals={'80','-1','0','2','1',odValChar};
    for idx=1:length(charsToReplace)
        charData=strrep(charData,charsToReplace{idx},replacementVals{idx});
    end
    if~exist(tempDirName,'dir')
        mkdir(tempDirName);
    end
    convertedFileName=['edited_',file,ext];
    convertedFilePath=[tempDirName,filesep,convertedFileName];
    fileId2=fopen(convertedFilePath,'wt');
    fwrite(fileId2,charData);
    processedData=importdata(convertedFilePath);
    fclose(fileId2);
    delete(convertedFilePath);
end

function textData=reformatCellarray(cellData)
    sigLen=length(cellData);
    gearText=cell('');
    gearVal=double([]);
    for idx2=1:sigLen
        tempSpaces=regexp(cellData{idx2},'\s');
        tempTimeVal=str2double(cellData{idx2}(1:tempSpaces(1)-1));
        if isnan(tempTimeVal)
            headerIdx=idx2;
        else
            dataIdx=idx2-headerIdx;
            time(dataIdx)=tempTimeVal;
            xdot(dataIdx)=str2double(cellData{idx2}(tempSpaces(1)+1:tempSpaces(2)-1));
            gearText{dataIdx}=cellData{idx2}(tempSpaces(2)+1:end);
            gearVal(dataIdx)=str2double(gearText{idx2-headerIdx});
        end
    end
    odValChar=num2str(max(gearVal(:))+1);
    charsToReplace={'P','R','N','D','L','OD'};
    replacementVals={'80','-1','0','2','1',odValChar};
    charData=gearText;
    for idx2=1:length(charsToReplace)
        charData=strrep(charData,charsToReplace{idx2},replacementVals{idx2});
    end

    textData.data=[time',xdot',str2double(charData)'];
    textData.textdata=cellData(1:headerIdx);
    textData.colheaders=textData.textdata;
end

function setPortOrder(block,~,~,~)

    OutportNames={'Info';'Reference Speed';'Reference Accel';'Gear'};
    FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortI]=intersect(OutportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([block,'/',OutportNames{PortI(i)}],'Port',num2str(i));
    end
end

function[upperLimit,lowerLimit]=calcFaultBounds(block,DriveCycle)
    faultMode=get_param(block,'faultOption');
    faultParams=autoblksgetmaskparms(block,{'velBnd','timeBnd','dt','outUnit','velBndUnit'},false);
    velBnd=faultParams{1};
    timeBnd=faultParams{2};
    dt=faultParams{3};
    outUnit=faultParams{4};
    velBndUnit=faultParams{5};



    ParamList={
    'velBnd',[1,1],{'gt',0};...
    'timeBnd',[1,1],{'gt',0};...
    };
    autoblkscheckparams(block,'Drive Cycle Source',ParamList);
    validSettings=(velBnd>0)&&(timeBnd>0);









    regenerateBounds=checkRegen(block,DriveCycle);

    velBnd=autoblksunitconv(velBnd,velBndUnit,get_param(block,'srcUnit'));
    tmpData=get_param(gcb,'UserData');
    if isempty(tmpData)

        if dt==0
            refSample=min(DriveCycle.Time(2)-DriveCycle.Time(1),timeBnd);
        else
            refSample=min(dt,timeBnd);
        end
        cycleResample=resample(DriveCycle,DriveCycle.Time(1):refSample:DriveCycle.Time(end));
        timeVec=(cycleResample.Time(1):refSample:cycleResample.Time(end))';
        upperData=movmax(cycleResample.Data(:),floor(2.*timeBnd./refSample))+velBnd;
        lowerData=movmin(cycleResample.Data(:),floor(2.*timeBnd./refSample))-velBnd;
        upperLimit=timeseries(upperData',timeVec);
        lowerLimit=timeseries(lowerData',timeVec);
        upperLimit.DataInfo.Units=DriveCycle.DataInfo.Units;
        lowerLimit.DataInfo.Units=DriveCycle.DataInfo.Units;

        if strcmp(get_param(gcb,'forceCalcBound'),'on')
            set_param(gcb,'forceCalcBound','off')
        end
        setRegen(block,DriveCycle)
    elseif strcmp(faultMode,'off')
        upperLimit=tmpData(4);
        lowerLimit=tmpData(5);
    elseif(regenerateBounds&&validSettings)

        if dt==0
            refSample=min(DriveCycle.Time(2)-DriveCycle.Time(1),timeBnd);
        else
            refSample=min(dt,timeBnd);
        end

        cycleResample=resample(DriveCycle,DriveCycle.Time(1):refSample:DriveCycle.Time(end));

        timeVec=(cycleResample.Time(1):refSample:cycleResample.Time(end))';
        upperData=movmax(cycleResample.Data(),floor(2.*timeBnd./refSample))+velBnd;
        lowerData=movmin(cycleResample.Data(),floor(2.*timeBnd./refSample))-velBnd;
        upperLimit=timeseries(upperData',timeVec);
        lowerLimit=timeseries(lowerData',timeVec);
        upperLimit.DataInfo.Units=DriveCycle.DataInfo.Units;
        lowerLimit.DataInfo.Units=DriveCycle.DataInfo.Units;

        if strcmp(get_param(gcb,'forceCalcBound'),'on')
            set_param(gcb,'forceCalcBound','off');
        end
        setRegen(block,DriveCycle);
    else
        upperLimit=tmpData(4);
        lowerLimit=tmpData(5);
    end

    upperLimit.Data=squeeze(upperLimit.Data);
    lowerLimit.Data=squeeze(lowerLimit.Data);
end

function regenFlag=checkRegen(block,DriveCycle)
    match_DriveCycle=isequal(DriveCycle.Name,get_param(block,'lastDCname'));
    match_Units=isequal(get_param(block,'velBndUnit'),get_param(block,'lastOutUnit'));
    match_Dt=isequal(get_param(block,'dt'),get_param(block,'lastDT'));
    match_Speedbound=isequal(get_param(block,'velBnd'),get_param(block,'lastSB'));
    match_timeBnd=isequal(get_param(block,'timeBnd'),get_param(block,'lastTB'));
    regenFlag=~(match_DriveCycle&match_Units&match_Dt&match_Speedbound&match_timeBnd);
    if strcmp(get_param(gcb,'forceCalcBound'),'on')
        regenFlag=true;
    end
end

function setRegen(block,DriveCycle)
    set_param(block,'lastDCname',DriveCycle.Name)
    set_param(block,'lastOutUnit',get_param(block,'velBndUnit'));
    set_param(block,'lastDT',get_param(block,'dt'));
    set_param(block,'lastSB',get_param(block,'velBnd'));
    set_param(block,'lastTB',get_param(block,'timeBnd'));
end