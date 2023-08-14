function[outputStruct,SPICEVoltages,SPICECurrents,SPICETime,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissValid,qossValid]=compareSPICEWithSimscape(SimscapeFile,SPICEFile,subcircuitName,...
    subcircuitDetails,test,structArrayIndex,SPICETool,SPICEPath,relTol,absTol,vnTol,absErrTol,relErrTol,Rawfile_idvgstj27,Rawfile_idvgstj75,Rawfile_idvds,Rawfile_qiss,Rawfile_qoss,Rawfile_breakdown)






























































    if strncmpi(test(structArrayIndex).name,"idvgst3",7)||strncmpi(test(structArrayIndex).name,"idvgst4",7)||strncmpi(test(structArrayIndex).name,"idvgst5tj27",10)||strncmpi(test(structArrayIndex).name,...
        "idvgst6tj27",10)
        Rawfile{structArrayIndex}=Rawfile_idvgstj27;
    elseif strncmpi(test(structArrayIndex).name,"idvgst5tj75",10)||strncmpi(test(structArrayIndex).name,"idvgst6tj75",10)
        Rawfile{structArrayIndex}=Rawfile_idvgstj75;
    elseif strncmpi(test(structArrayIndex).name,"idvds",5)
        Rawfile{structArrayIndex}=Rawfile_idvds;
    elseif strncmpi(test(structArrayIndex).name,"qiss",4)
        Rawfile{structArrayIndex}=Rawfile_qiss;
    elseif strncmpi(test(structArrayIndex).name,"qoss",4)
        Rawfile{structArrayIndex}=Rawfile_qoss;
    elseif strncmpi(test(structArrayIndex).name,"breakdown",9)
        Rawfile{structArrayIndex}=Rawfile_breakdown;
    end
    if(isempty(Rawfile{structArrayIndex}))
        rawDataFile="testNetlist"+subcircuitName+".raw";
        if~exist(SPICEPath,"file")||~endsWith(SPICEPath,["XVIIx64.exe","XVIIx86.exe"])
            pm_error("physmod:ee:SPICE2sscvalidation:SPICEPathError");
            SPICECommand=string.empty;
        else
            SPICECommand=""""+SPICEPath+""" -b -run ";
        end


        tempDir=tempname;
        mkdir(tempDir);
        dirname=convertCharsToStrings(tempDir);
        finishup2=onCleanup(@()myCleanupFun2(dirname));


        netlistFile=ee.internal.validation.mosfet.createSPICEToolNetlist(1,SPICETool,dirname,SPICEFile,subcircuitName,subcircuitDetails,test,structArrayIndex,relTol,absTol,vnTol);


        result=system(char(SPICECommand+strcat(dirname+"/"+netlistFile)));
        if result~=0
            pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
        end
        raw_data=ee.spice.LTspice2Matlab(strcat(dirname+"/"+rawDataFile));
    else
        raw_data=ee.spice.LTspice2Matlab(strcat(Rawfile{structArrayIndex}));
    end


    cdex=find(diff(raw_data.time_vect)<0);
    sdex=[1,cdex+1];
    edex=[cdex,length(raw_data.time_vect)];
    SPICEVoltages=cell(1,length(sdex));
    SPICECurrents=cell(1,length(sdex));
    SPICETime=cell(1,length(sdex));
    for ss=1:length(sdex)
        SPICEVoltages{ss}=zeros(length(subcircuitDetails.nodes),edex(ss)-sdex(ss)+1);
        SPICECurrents{ss}=zeros(length(subcircuitDetails.nodes),edex(ss)-sdex(ss)+1);
        SPICETime{ss}=raw_data.time_vect(sdex(ss):edex(ss));
        vidx=zeros(size(subcircuitDetails.nodes));
        iidx=zeros(size(subcircuitDetails.nodes));
        for nodeIndex=1:length(subcircuitDetails.nodes)
            vidx(nodeIndex)=find(strcmpi(raw_data.variable_name_list,sprintf("V(dut%d)",nodeIndex)));
            SPICEVoltages{ss}(nodeIndex,:)=raw_data.variable_mat(vidx(nodeIndex),sdex(ss):edex(ss));
            [isSource,location]=ismember(nodeIndex,test(structArrayIndex).dcNodes);
            if isSource
                if strncmpi(test(structArrayIndex).dcTypes(location),"voltage",1)
                    iidx(nodeIndex)=find(strcmpi(raw_data.variable_name_list,sprintf("I(V%d)",nodeIndex)));
                else
                    iidx(nodeIndex)=find(strcmpi(raw_data.variable_name_list,sprintf("I(I%d)",nodeIndex)));
                end
                SPICECurrents{ss}(nodeIndex,:)=raw_data.variable_mat(iidx(nodeIndex),sdex(ss):edex(ss));
            end
            [isSource,location]=ismember(nodeIndex,test(structArrayIndex).stepNodes);
            if isSource
                if strncmpi(test(structArrayIndex).stepType(location),"voltage",1)
                    iidx(nodeIndex)=find(strcmpi(raw_data.variable_name_list,sprintf("I(V%d)",nodeIndex)));
                else
                    iidx(nodeIndex)=find(strcmpi(raw_data.variable_name_list,sprintf("I(I%d)",nodeIndex)));
                end
                SPICECurrents{ss}(nodeIndex,:)=raw_data.variable_mat(iidx(nodeIndex),sdex(ss):edex(ss));
            end
            [isSource,location]=ismember(nodeIndex,test(structArrayIndex).sweepNodes);
            if isSource
                if strncmpi(test(structArrayIndex).sweepType(location),"voltage",1)
                    iidx(nodeIndex)=find(strcmpi(raw_data.variable_name_list,sprintf("I(V%d)",nodeIndex)));
                else
                    iidx(nodeIndex)=find(strcmpi(raw_data.variable_name_list,sprintf("I(I%d)",nodeIndex)));
                end
                SPICECurrents{ss}(nodeIndex,:)=raw_data.variable_mat(iidx(nodeIndex),sdex(ss):edex(ss));
            end
        end
    end


    [~,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissValid,qossValid]=ee.internal.validation.mosfet.runSimscapeSimulation(SimscapeFile,test,structArrayIndex,subcircuitDetails.nodes);


    [outputStruct]=ee.internal.validation.mosfet.generateOutputTable(test,structArrayIndex,SPICEVoltages,SPICECurrents,SPICETime,SimscapeVoltages,SimscapeCurrents,SimscapeTime,absErrTol,relErrTol);


    if(isempty(Rawfile{structArrayIndex}))
        if exist(dirname,"dir")
            rmdir(dirname,"s");
        end
    end
end

function myCleanupFun2(V)
    if exist(V,"dir")
        rmdir(V,"s");
    end
end