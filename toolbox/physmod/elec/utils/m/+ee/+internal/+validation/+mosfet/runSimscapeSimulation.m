function[outputStruct,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissvalid,qossvalid]=runSimscapeSimulation(SimscapeFile,test,structArrayIndex,nodes)





























    iconSize=40;
    dutVerticalRatio=4;
    dutPos=[750-iconSize,90];
    initLoadPos=[750-3*iconSize,50];
    initOpenPos=initLoadPos-[3*iconSize,0];
    initSourcePos=initOpenPos-[3*iconSize,-5*iconSize];
    qissvalid=1;
    qossvalid=1;


    try
        SimscapeFile=which(SimscapeFile);
    catch
        pm_error("physmod:ee:spice2ssc:CannotOpenFile",SimscapeFile);
    end

    [~,fName,~]=fileparts(SimscapeFile);
    modelFile="testModel"+fName;


    load_system(new_system(char(modelFile)));
    finishup1=onCleanup(@()CleanupFun1(char(modelFile)));


    set_param(modelFile,'MaxStep',num2str(test(structArrayIndex).simTime/test(structArrayIndex).minPts));
    set_param(modelFile,'StopTime',num2str(test(structArrayIndex).simTime));


    assignedNodes=unique([test(structArrayIndex).openNodes,test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes]);
    unassignedNodes=setdiff(1:length(nodes),assignedNodes);
    if max(assignedNodes)>length(nodes)
        pm_error('physmod:ee:SPICE2sscvalidation:SimscapesimulationAssignedNodesError');
    end
    if strncmpi(test(structArrayIndex).treatUnspecifiedNodes,'O',1)
        test(structArrayIndex).openNodes=[test(structArrayIndex).openNodes,unassignedNodes];
    elseif strncmpi(test(structArrayIndex).treatUnspecifiedNodes,'G',1)
        test(structArrayIndex).dcNodes=[test(structArrayIndex).dcNodes,unassignedNodes];
        test(structArrayIndex).dcValues=[test(structArrayIndex).dcValues,zeros(size(unassignedNodes))];
        tempStr=strings(size(unassignedNodes));
        tempStr(:)="voltage";
        test(structArrayIndex).dcTypes=[test(structArrayIndex).dcTypes,tempStr];
        clear tempStr;
    else
        pm_error('physmod:ee:SPICE2sscvalidation:SimscapesimulationUnassignedNodesError');
    end
    if~isempty(intersect(test(structArrayIndex).openNodes,test(structArrayIndex).dcNodes))...
        ||~isempty(intersect(test(structArrayIndex).openNodes,test(structArrayIndex).stepNodes))...
        ||~isempty(intersect(test(structArrayIndex).openNodes,test(structArrayIndex).sweepNodes))...
        ||~isempty(intersect(test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes))...
        ||~isempty(intersect(test(structArrayIndex).dcNodes,test(structArrayIndex).sweepNodes))...
        ||~isempty(intersect(test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes))...
        ||~isempty(intersect(test(structArrayIndex).openNodes,test(structArrayIndex).loadNodes))
        pm_error('physmod:ee:SPICE2sscvalidation:SimscapesimulationOverlappingValuesError');
    end
    if length(test(structArrayIndex).dcNodes)~=length(test(structArrayIndex).dcValues)...
        ||length(test(structArrayIndex).dcNodes)~=length(test(structArrayIndex).dcTypes)
        pm_error('physmod:ee:SPICE2sscvalidation:SimscapesimulationVectorsLengthsError');
    end
    if length(test(structArrayIndex).stepNodes)~=length(test(structArrayIndex).stepType)
        pm_error('physmod:ee:SPICE2sscvalidation:SimscapesimulationSteppedNodesLengthsError');
    end
    if length(test(structArrayIndex).sweepNodes)~=length(test(structArrayIndex).sweepType)
        pm_error('physmod:ee:SPICE2sscvalidation:SimscapesimulationSweepNodesLengthsError');
    end
    if length(test(structArrayIndex).sweepValues)>2||length(test(structArrayIndex).sweepValues)==1
        pm_warning('physmod:ee:SPICE2sscvalidation:SimscapesimulationSweepVectorWarning');
    end
    if test(structArrayIndex).sweepValues(1)==test(structArrayIndex).sweepValues(end)
        pm_warning('physmod:ee:SPICE2sscvalidation:SimscapesimulationConstantSweepValueWarning');
    end
    Simscapefile_char=convertStringsToChars(SimscapeFile);
    k1=regexp(Simscapefile_char,'\+','once');
    k2=isempty(k1);
    if(k2==0)
        newpath=Simscapefile_char(1:k1-2);
        addpath(newpath);
        newChr=strrep(Simscapefile_char(k1+1:end),'\+','.');
        newChr=strrep(newChr,'/+','.');
        newChr2=strrep(newChr,filesep,'.');
        [~,fName,~]=fileparts(newChr2);
    end
    if(k2==1)
        [FILEPATH,fName,~]=fileparts(Simscapefile_char);
        addpath(FILEPATH);
    end


    try
        add_block('nesl_utility/Simscape Component',[char(modelFile),'/DUT']);
        simscape.setBlockComponent([char(modelFile),'/DUT'],fName);
        set_param(modelFile,'SimscapeLogType','all');
        set_param(modelFile,'SimscapeLogName','simlog');
        set_param(modelFile,'SimscapeLogLimitData','off');
        configPos=dutPos+iconSize*[0,dutVerticalRatio]+[0,2*iconSize];
        add_block('nesl_utility/Solver Configuration',[char(modelFile),'/Config'],'Position',[configPos,configPos+iconSize*[1,1]]);
        add_line(char(modelFile),'Config/RConn1','DUT/LConn1','autorouting','on');
        set_param([char(modelFile),'/Config'],'DoDC','on');
        set_param([char(modelFile),'/Config'],'UseLocalSolver','on');
        if(test(structArrayIndex).name=="qisst5")||(test(structArrayIndex).name=="qosst5")||(test(structArrayIndex).name=="qisst3")||(test(structArrayIndex).name=="qosst3")||...
            (test(structArrayIndex).name=="qisst4")||(test(structArrayIndex).name=="qosst4")||(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qosst6")
            if(-test(structArrayIndex).sweepValues(2)<1e-10)
                pp=0.01*(-test(structArrayIndex).sweepValues(2));
                set_param([char(modelFile),'/Config'],'ResidualTolerance',num2str(pp));
            else
                set_param([char(modelFile),'/Config'],'ResidualTolerance','1e-10');
            end
        else
            set_param([char(modelFile),'/Config'],'ResidualTolerance','1e-10');
        end
        set_param([char(modelFile),'/Config'],'LocalSolverSampleTime',num2str(test(structArrayIndex).simTime/test(structArrayIndex).minPts));
        for nn=1:length(test(structArrayIndex).loadNodes)
            currLoadPos=initLoadPos+[0,2*iconSize]*(nn-1);
            add_block('fl_lib/Electrical/Electrical Elements/Resistor',[char(modelFile),'/load',num2str(test(structArrayIndex).loadNodes(nn))],'Position',[currLoadPos,currLoadPos+iconSize]);
            add_line(char(modelFile),['DUT/LConn',num2str(test(structArrayIndex).loadNodes(nn))],['load',num2str(test(structArrayIndex).loadNodes(nn)),'/RConn1'],'autorouting','on');
            set_param([char(modelFile),'/load',num2str(test(structArrayIndex).loadNodes(nn))],'R',num2str(test(structArrayIndex).loadValues(nn)));
        end
        for nn=1:length(test(structArrayIndex).openNodes)
            currOpenPos=initOpenPos+[0,2*iconSize]*(nn-1);
            add_block('fl_lib/Electrical/Electrical Elements/Open Circuit',[char(modelFile),'/open',num2str(test(structArrayIndex).openNodes(nn))],'Position',[currOpenPos,currOpenPos+iconSize]);
            add_line(char(modelFile),['DUT/LConn',num2str(test(structArrayIndex).openNodes(nn))],['open',num2str(test(structArrayIndex).openNodes(nn)),'/LConn1'],'autorouting','on');
        end
        currSourcePos=initSourcePos;
        for nn=1:length(test(structArrayIndex).dcNodes)
            currSourcePos=initSourcePos-[2*iconSize,0]*(nn-1);
            currRefPos=currSourcePos+[0,2*iconSize];
            if strncmpi(test(structArrayIndex).dcTypes(nn),'voltage',1)
                device='fl_lib/Electrical/Electrical Sources/DC Voltage Source';
            elseif strncmpi(test(structArrayIndex).dcTypes(nn),'current',1)
                device='fl_lib/Electrical/Electrical Sources/DC Current Source';
            else
                error('Check the DC source types. Only current and voltage are allowed.');
            end
            add_block(device,[char(modelFile),'/source',num2str(test(structArrayIndex).dcNodes(nn))],'Position',[currSourcePos,currSourcePos+iconSize]);
            add_block('fl_lib/Electrical/Electrical Elements/Electrical Reference',[char(modelFile),'/ref',num2str(test(structArrayIndex).dcNodes(nn))],'Position',[currRefPos,currRefPos+iconSize]);
            add_line(char(modelFile),['source',num2str(test(structArrayIndex).dcNodes(nn)),'/RConn1'],['ref',num2str(test(structArrayIndex).dcNodes(nn)),'/LConn1'],'autorouting','on');
            if ismember(test(structArrayIndex).dcNodes(nn),test(structArrayIndex).loadNodes)
                add_line(char(modelFile),['source',num2str(test(structArrayIndex).dcNodes(nn)),'/LConn1'],['load',num2str(test(structArrayIndex).dcNodes(nn)),'/LConn1'],'autorouting','on');
            else
                add_line(char(modelFile),['source',num2str(test(structArrayIndex).dcNodes(nn)),'/LConn1'],['DUT/LConn',num2str(test(structArrayIndex).dcNodes(nn))],'autorouting','on');
            end
            set_param([char(modelFile),'/source',num2str(test(structArrayIndex).dcNodes(nn))],'v0',num2str(test(structArrayIndex).dcValues(nn)));
        end
        for nn=1:length(test(structArrayIndex).stepNodes)
            currSourcePos=currSourcePos-[2*iconSize,0];
            currRefPos=currSourcePos+[0,2*iconSize];
            if strncmpi(test(structArrayIndex).stepType,'voltage',1)
                device='fl_lib/Electrical/Electrical Sources/DC Voltage Source';
                parName='v0';
            elseif strncmpi(test(structArrayIndex).stepType,'current',1)
                device='fl_lib/Electrical/Electrical Sources/DC Current Source';
                parName='i0';
            else
                error('Check the step source types. Only current and voltage are allowed.');
            end
            add_block(device,[char(modelFile),'/source',num2str(test(structArrayIndex).stepNodes(nn))],'Position',[currSourcePos,currSourcePos+iconSize]);
            add_block('fl_lib/Electrical/Electrical Elements/Electrical Reference',[char(modelFile),'/ref',num2str(test(structArrayIndex).stepNodes(nn))],'Position',[currRefPos,currRefPos+iconSize]);
            add_line(char(modelFile),['source',num2str(test(structArrayIndex).stepNodes(nn)),'/RConn1'],['ref',num2str(test(structArrayIndex).stepNodes(nn)),'/LConn1'],'autorouting','on');
            if ismember(test(structArrayIndex).stepNodes(nn),test(structArrayIndex).loadNodes)
                add_line(char(modelFile),['source',num2str(test(structArrayIndex).stepNodes(nn)),'/LConn1'],['load',num2str(test(structArrayIndex).stepNodes(nn)),'/LConn1'],'autorouting','on');
            else
                add_line(char(modelFile),['source',num2str(test(structArrayIndex).stepNodes(nn)),'/LConn1'],['DUT/LConn',num2str(test(structArrayIndex).stepNodes(nn))],'autorouting','on');
            end
            S=evalin('base','whos');
            varname={S.name};
            U=matlab.lang.makeUniqueStrings('stepValue',varname);
            finishup2=onCleanup(@()CleanupFun2(U));
            set_param([char(modelFile),'/source',num2str(test(structArrayIndex).stepNodes(nn))],parName,U);
            set_param([char(modelFile),'/source',num2str(test(structArrayIndex).stepNodes(nn))],[parName,'_conf'],'runtime');
            assignin('base',U,test(structArrayIndex).stepValues(1));
        end
        for nn=1:length(test(structArrayIndex).sweepNodes)
            currSourcePos=currSourcePos-[2*iconSize,0];
            currRefPos=currSourcePos+[0,2*iconSize];
            if strncmpi(test(structArrayIndex).sweepType,'voltage',1)
                device='ee_lib/Additional Components/SPICE Sources/Piecewise Linear Voltage Source';
                parName='VOLTlist';
            elseif strncmpi(test(structArrayIndex).sweepType,'current',1)
                device='ee_lib/Additional Components/SPICE Sources/Piecewise Linear Current Source';
                parName='CURRlist';
            else
                error('Check the sweep source types. Only current and voltage are allowed.');
            end
            add_block(device,[char(modelFile),'/source',num2str(test(structArrayIndex).sweepNodes(nn))],'Position',[currSourcePos,currSourcePos+iconSize]);
            add_block('fl_lib/Electrical/Electrical Elements/Electrical Reference',[char(modelFile),'/ref',num2str(test(structArrayIndex).sweepNodes(nn))],'Position',[currRefPos,currRefPos+iconSize]);
            add_line(char(modelFile),['source',num2str(test(structArrayIndex).sweepNodes(nn)),'/RConn1'],['ref',num2str(test(structArrayIndex).sweepNodes(nn)),'/LConn1'],'autorouting','on');
            if ismember(test(structArrayIndex).sweepNodes(nn),test(structArrayIndex).loadNodes)
                add_line(char(modelFile),['source',num2str(test(structArrayIndex).sweepNodes(nn)),'/LConn1'],['load',num2str(test(structArrayIndex).sweepNodes(nn)),'/LConn1'],'autorouting','on');
            else
                add_line(char(modelFile),['source',num2str(test(structArrayIndex).sweepNodes(nn)),'/LConn1'],['DUT/LConn',num2str(test(structArrayIndex).sweepNodes(nn))],'autorouting','on');
            end
            if strncmpi(test(structArrayIndex).sweepType,'voltage',1)
                set_param([char(modelFile),'/source',num2str(test(structArrayIndex).sweepNodes(nn))],parName,mat2str(test(structArrayIndex).sweepValues));
                set_param([char(modelFile),'/source',num2str(test(structArrayIndex).sweepNodes(nn))],'TIMElist',mat2str([0,test(structArrayIndex).simTime]));
            end
            if strncmpi(test(structArrayIndex).sweepType,'current',1)
                set_param([char(modelFile),'/source',num2str(test(structArrayIndex).sweepNodes(nn))],parName,mat2str([0,test(structArrayIndex).sweepValues(end),test(structArrayIndex).sweepValues(end)]));
                set_param([char(modelFile),'/source',num2str(test(structArrayIndex).sweepNodes(nn))],'TIMElist',mat2str([0,test(structArrayIndex).sweepValues(1),test(structArrayIndex).simTime]));
            end
            add_block('ee_lib/Utilities/Environment Parameters',[char(modelFile),'/env']);
            add_line(char(modelFile),'Config/RConn1','env/RConn1','autorouting','on');
            set_param([char(modelFile),'/env'],'GMIN','0');
            if strncmpi(test(structArrayIndex).sweepType,'current',1)
                add_block('fl_lib/Electrical/Electrical Elements/Resistor',[char(modelFile),'/res'],'Position',[currSourcePos-2*iconSize,currSourcePos-iconSize]);
                add_line(char(modelFile),['res/LConn1'],['ref',num2str(test(structArrayIndex).sweepNodes(nn)),'/LConn1'],'autorouting','on');%#ok<*NBRAK>
                add_line(char(modelFile),['source',num2str(test(structArrayIndex).sweepNodes(nn)),'/LConn1'],['res/RConn1'],'autorouting','on');
                set_param([char(modelFile),'/res'],'R','1e12');
            end
        end


        set_param(char(modelFile),'FastRestart','on');
        sim(char(modelFile),0);
    catch
        pm_error('physmod:ee:SPICE2sscvalidation:SimscapeFileError');
    end
    SimscapeVoltages=cell(1,max([1,length(test(structArrayIndex).stepValues)]));
    SimscapeCurrents=cell(1,max([1,length(test(structArrayIndex).stepValues)]));
    SimscapeTime=cell(1,length(test(structArrayIndex).stepValues));
    for ss=1:max([1,length(test(structArrayIndex).stepValues)])
        if~isempty(test(structArrayIndex).stepValues)
            assignin('base',U,test(structArrayIndex).stepValues(ss));
        end
        simout=sim(char(modelFile));
        simlog=simout.simlog;
        SimscapeTime{ss}=simlog.DUT.(char(nodes(1))).v.series.time;
        SimscapeVoltages{ss}=zeros(length(nodes),length(SimscapeTime{ss}));
        SimscapeCurrents{ss}=zeros(length(nodes),length(SimscapeTime{ss}));
        for nn=1:length(nodes)
            SimscapeVoltages{ss}(nn,:)=simlog.DUT.(char(nodes(nn))).v.series.values;
            if ismember(nn,[test(structArrayIndex).dcNodes,test(structArrayIndex).stepNodes,test(structArrayIndex).sweepNodes])
                sourceName=sprintf('source%d',nn);
                SimscapeCurrents{ss}(nn,:)=simlog.(sourceName).i.series.values;
            end
        end

        if strncmpi(test(structArrayIndex).name,"qiss",4)
            len=length(simlog.source2.i.series.values);
            sourcecurrentvalue=simlog.source2.i.series.values;
            resistorcurrentvalue=simlog.res.i.series.values;
            if abs((resistorcurrentvalue(len)/sourcecurrentvalue(len)))>0.01
                pm_warning('physmod:ee:SPICE2sscvalidation:QissNotValidWarning');
                qissvalid=0;
                outputStruct.plots(structArrayIndex).results=table.empty;
                return
            end
        end
        if strncmpi(test(structArrayIndex).name,"qoss",4)
            len=length(simlog.source1.i.series.values);
            sourcecurrentvalue=simlog.source1.i.series.values;
            resistorcurrentvalue=simlog.res.i.series.values;
            if abs((resistorcurrentvalue(len)/sourcecurrentvalue(len)))>0.01
                pm_warning('physmod:ee:SPICE2sscvalidation:QossNotValidWarning');
                qossvalid=0;
                outputStruct.plots(structArrayIndex).results=table.empty;
                return
            end
        end

        if(test(structArrayIndex).name=="idvgst3")||(test(structArrayIndex).name=="idvgst4")||(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst6tj27")||...
            (test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvgst6tj75")
            if(test(structArrayIndex).name=="idvgst3")||(test(structArrayIndex).name=="idvgst4")
                s2.testname(ss,:)="id vs vgs";
            end
            if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst6tj27")
                s2.testname(ss,:)="id vs vgs for tj=27";
            end
            if(test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvgst6tj75")
                s2.testname(ss,:)="id vs vgs for tj=75";
            end
            s2.Vds_values(ss,:)=test(structArrayIndex).stepValues(ss);
            s2.Vgs_values(ss,:)=SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1);
            s2.Simscape_currents(ss,:)=-SimscapeCurrents{ss}(1,:);
            outputStruct.plots(structArrayIndex).results=struct2table(s2);
        end
        if(test(structArrayIndex).name=="idvdst5")||(test(structArrayIndex).name=="idvdst3")||(test(structArrayIndex).name=="idvdst6")||(test(structArrayIndex).name=="idvdst4")
            s3.testname(ss,:)="id vs vds";
            s3.Vgs_values(ss,:)=test(structArrayIndex).stepValues(ss);
            s3.Vds_values(ss,:)=SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1);
            s3.Simscape_currents(ss,:)=-SimscapeCurrents{ss}(1,:);
            outputStruct.plots(structArrayIndex).results=struct2table(s3);
        end
        if(test(structArrayIndex).name=="qisst5")||(test(structArrayIndex).name=="qisst3")||(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qisst4")
            s4.t(structArrayIndex).testname(ss,:)="qiss";
            s4.t(structArrayIndex).Simtime_values(ss,:)=SimscapeTime{1};
            s4.t(structArrayIndex).Simscape_voltages(ss,:)=SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,1:end);
            outputStruct.plots(structArrayIndex).results=struct2table(s4.t(structArrayIndex));
        end
        if(test(structArrayIndex).name=="qosst5")||(test(structArrayIndex).name=="qosst3")||(test(structArrayIndex).name=="qosst6")||(test(structArrayIndex).name=="qosst4")
            s5.t(structArrayIndex).testname(ss,:)="qoss";
            s5.t(structArrayIndex).Simtime_values(ss,:)=SimscapeTime{1};
            s5.t(structArrayIndex).Simscape_voltages(ss,:)=SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,1:end);
            outputStruct.plots(structArrayIndex).results=struct2table(s5.t(structArrayIndex));
        end
        if(test(structArrayIndex).name=="breakdownt5")||(test(structArrayIndex).name=="breakdownt3")||(test(structArrayIndex).name=="breakdownt6")||(test(structArrayIndex).name=="breakdownt4")
            s6.t(structArrayIndex).testname(ss,:)="breakdown";
            s6.t(structArrayIndex).Vds_values(ss,:)=SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,:);
            s6.t(structArrayIndex).Simscape_currents(ss,:)=-SimscapeCurrents{ss}(1,:);
            outputStruct.plots(structArrayIndex).results=struct2table(s6.t(structArrayIndex));
        end
    end
    if exist('U','var')
        evalin('base',char(strcat('clear',{' '},U)));
    end
    set_param(char(modelFile),'FastRestart','off');
    close_system(char(modelFile),0);
end

function CleanupFun1(g)
    if bdIsLoaded(g)
        set_param(g,'FastRestart','off');
        bdclose(g)
    end
end

function CleanupFun2(U)
    evalin('base',char(strcat('clear',{' '},U)))
end