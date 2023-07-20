function varargout=hdllink_block_init(varargin)





    if nargout
        [varargout{1:nargout}]=feval(varargin{:});
    else
        feval(varargin{:});
    end

end




function[inP,outP,outTs,outDT,outF,fcP,rcP,fcTs,rcTs,tclPre,tclPost,iconStr1,iconStr,crSignals,crTypes,crTimes,xsiData]=...
    initializationCommands(blkName,blkHandle,PortPaths,PortModes,PortTimes,PortSigns,PortFracs,...
    ClockPaths,ClockModes,ClockTimes,...
    tclPreCommand,tclPostCommand,idxCellArray,...
    CommShowInfo,CommLocal,CommSharedMemory,CommPortNumber,CommHostName,...
    CosimBypass,ProductName)

    PortModes=eval(PortModes);


    if~strcmp(idxCellArray,'UNUSED_VAR')
        if isempty(PortTimes)

            PortTimes=1;
        end

        [PortPaths,PortModes,PortTimes,PortSigns,PortFracs,...
        ClockPaths,ClockModes,ClockTimes]=...
        parseIdxCellArray(idxCellArray,PortTimes);
    end


    inP='';
    outP='';
    outTs=[];
    outDT=[];
    outF=[];
    fcP='';
    rcP='';
    fcTs=[];
    rcTs=[];
    iconInfo.inport=[];
    iconInfo.outport=[];
    iconInfo.instr={};
    iconInfo.outstr={};

    crSignals=ClockPaths;
    crTypes=ClockModes;
    crTimes=ClockTimes;

    fullSigNames={};


    PortPaths=strread(PortPaths,'%s','delimiter',';','whitespace','');
    ClockPaths=strread(ClockPaths,'%s','delimiter',';','whitespace','');



    if isempty(PortTimes)
        PortTimes=ones(1,length(PortPaths));
    end
    if isempty(PortFracs)
        PortFracs=ones(1,length(PortPaths));
    end
    if isempty(ClockTimes)
        ClockTimes=2*ones(1,length(ClockPaths));
    end


    numPortPaths=length(PortPaths);
    numPortModes=length(PortModes);
    numPortTimes=length(PortTimes);
    numPortSigns=length(PortSigns);
    numPortFracs=length(PortFracs);
    if~isequal(numPortPaths,numPortTimes)||...
        ~isequal(numPortPaths,numPortModes)||...
        ~isequal(numPortPaths,numPortSigns)||...
        ~isequal(numPortPaths,numPortFracs)


        if isequal(numPortSigns,numPortPaths+1)&&...
            isequal(numPortFracs,numPortPaths+1)
            PortSigns=PortSigns(1:end-1);
            PortFracs=PortFracs(1:end-1);
        else
            warning(message('HDLLink:BlockInit:NumberofParamsConflict1',blkName));
        end
    end

    numClockPaths=length(ClockPaths);
    numClockModes=length(ClockModes);
    numClockTimes=length(ClockTimes);
    if~isequal(numClockPaths,numClockTimes)||~isequal(numClockPaths,numClockModes)
        warning(message('HDLLink:BlockInit:NumberofParamsConflict2',blkName));
    end

    inportIndex=1;
    outportIndex=1;

    for ii=1:numPortPaths
        curPath=PortPaths{ii};
        switch PortModes(ii)
        case 1

            inP=[inP,';',curPath];

            iconInfo.inport(inportIndex)=inportIndex;
            lastSlash=findlastdelim(curPath);
            iconInfo.instr{inportIndex}=curPath(lastSlash+1:end);
            inportIndex=inportIndex+1;
        case 2

            outP=[outP,';',PortPaths{ii}];

            outTs=[outTs,PortTimes(ii)];

            outDT=[outDT,PortSigns(ii)];

            outF=[outF,PortFracs(ii)];

            iconInfo.outport(outportIndex)=outportIndex;
            lastSlash=findlastdelim(curPath);
            iconInfo.outstr{outportIndex}=curPath(lastSlash+1:end);
            outportIndex=outportIndex+1;
        otherwise
            error(message('HDLLink:BlockInit:UnknownPortType'));
        end
        fullSigNames=[fullSigNames,{curPath}];
    end


    if~isempty(inP)
        inP=inP(2:end);
    end
    if~isempty(outP)
        outP=outP(2:end);
    end


    for ii=1:numClockPaths
        curPath=ClockPaths{ii};
        switch ClockModes(ii)
        case 1

            fcP=[fcP,';',curPath];

            fcTs=[fcTs,ClockTimes(ii)];
        case 2

            rcP=[rcP,';',curPath];

            rcTs=[rcTs,ClockTimes(ii)];
        case 3

        case 4

        otherwise
            error(message('HDLLink:BlockInit:UnknownClockType'));
        end
        fullSigNames=[fullSigNames,{curPath}];
    end


    if~isempty(fcP)
        fcP=fcP(2:end);
    end
    if~isempty(rcP)
        rcP=rcP(2:end);
    end


    uniqueNames=unique(fullSigNames);
    if length(uniqueNames)~=length(fullSigNames)
        warning(message('HDLLink:BlockInit:DuplicateNames',blkName));
    end

    tclPre=tclPreCommand;
    tclPost=tclPostCommand;










    switch(ProductName)
    case 'EDA Simulator Link VS'
        xsiData=get_param(blkHandle,'UserData');

        if isempty(xsiData)||~isstruct(xsiData)
            xsiData=createXsiData();
        end
    otherwise
        if isempty(get_param(blkHandle,'userdata'))
            set_param(blkHandle,'userdata',getlocalhostname);
        end
        xsiData=createXsiData();
    end



    [iconStr1,iconStr]=update_block_icon(iconInfo,blkHandle,...
    CommShowInfo,CommLocal,CommSharedMemory,CommPortNumber,CommHostName,...
    CosimBypass,ProductName,xsiData);
end




function lastdelim=findlastdelim(str)

    delims='[\/.:]';


    if(~isempty(regexp(str(end),delims,'once'))&&length(str)>1)
        str=str(1:end-1);
    end


    dindx=regexp(str,delims);
    lastdelim=max(dindx);


    if(isempty(lastdelim)||lastdelim==length(str))
        lastdelim=0;
    end

end


function[PortPaths,PortModes,PortTimes,PortSigns,PortFracs,...
    ClockPaths,ClockModes,ClockTimes]=...
    parseIdxCellArray(cellArray,outTs)

    PortPaths='';
    PortModes=[];
    PortTimes=[];
    PortSigns=[];
    PortFracs=[];

    ClockPaths='';
    ClockModes=[];
    ClockTimes=[];

    for ii=1:2:length(cellArray)
        switch cellArray{ii+1}
        case 'in'
            PortPaths=[PortPaths,';',cellArray{ii}];
            PortModes=[PortModes,1];
            PortTimes=[PortTimes,1];
            PortSigns=[PortSigns,-1];
            PortFracs=[PortFracs,0];
        case 'out'
            PortPaths=[PortPaths,';',cellArray{ii}];
            PortModes=[PortModes,2];
            PortTimes=[PortTimes,outTs];
            PortSigns=[PortSigns,-1];
            PortFracs=[PortFracs,0];
        case 'fclk'
            ClockPaths=[ClockPaths,';',cellArray{ii}];
            ClockModes=[ClockModes,1];
            ClockTimes=[ClockTimes,2];
        case 'rclk'
            ClockPaths=[ClockPaths,';',cellArray{ii}];
            ClockModes=[ClockModes,2];
            ClockTimes=[ClockTimes,2];
        end
    end

    if isempty(PortPaths)

    else

        PortPaths=PortPaths(2:end);
    end

    if isempty(ClockPaths)

    else

        ClockPaths=ClockPaths(2:end);
    end

end


function[iconStr1,iconStr]=update_block_icon(iconInfo,blkHandle,...
    CommShowInfo,CommLocal,CommSharedMemory,CommPortNumber,CommHostName,...
    CosimBypass,ProductName,xsiData)









    switch(ProductName)
    case 'EDA Simulator Link IN'
        iname='lfilogo.jpeg';
    case 'EDA Simulator Link MQ'
        iname='lfmlogo.jpeg';
    case 'EDA Simulator Link VS'
        iname='lfvlogo.jpeg';
    otherwise
        errordlg(['Unknown HDL link product ',ProductName],...
        'HDLLink:UnknownProduct');

    end

    str=['image(imread(''',iname,'''),''center'');'];

    for i=1:length(iconInfo.inport)
        str=[str,'port_label(''input'',',num2str(iconInfo.inport(i)),',''',iconInfo.instr{i},''');'];
    end
    for i=1:length(iconInfo.outport)
        str=[str,'port_label(''output'',',num2str(iconInfo.outport(i)),',''',iconInfo.outstr{i},''');'];
    end




    switch(ProductName)
    case 'EDA Simulator Link VS'
        iconStr='HDL Design DLL';
    otherwise
        switch CosimBypass
        case 2
            iconStr='Confirm Interface Only';
        case 3
            iconStr='No Connection';
        otherwise
            if CommShowInfo
                if CommLocal
                    if CommSharedMemory
                        iconStr='SharedMem';
                    else
                        cached_localhost=get_param(blkHandle,'userdata');
                        iconStr=[cached_localhost,':',CommPortNumber];
                    end
                else
                    iconStr=[CommHostName,':',CommPortNumber];
                end
            else
                iconStr='';
            end
        end
    end

    iconStr=['{\bf \it ',iconStr,' }'];
    halign='0.5';
    valign='0.05';
    xtraArgs=',''tex'', ''on''';
    textCmd=['text( ',halign,',',valign,',iconStr,''horizontalAlignment'',''center'',''verticalAlignment'',''base''',xtraArgs,');'];
    iconStr1=[str,textCmd];

end




function update_subsystem_ports(currSys,blkName,blkHandle,PortPaths,PortModes)




    currStatus=get_param(currSys,'SimulationStatus');
    if(strcmp(currStatus,'running')||...
        strcmp(currStatus,'terminating')||...
        strcmp(get_param(currSys,'ExtModeConnected'),'on')||...
        strcmp(get_param(bdroot(get(blkHandle,'Parent')),'Lock'),'on'))
        return;
    end





    [paths,modes]=getMaskParams(PortPaths,PortModes);
    [ipaths,opaths]=separateInAndOutPaths(paths,modes);


    [iports,oports]=getSubSystemPorts(blkName,blkHandle);



    deleteAllLines(blkHandle);
    iports=deleteObsoletePorts(blkName,ipaths,iports);
    oports=deleteObsoletePorts(blkName,opaths,oports);


    iports=createSubsystemPorts(blkName,ipaths,iports,'Inport');
    oports=createSubsystemPorts(blkName,opaths,oports,'Outport');




    try
        initSfuncBlock(blkName,size(ipaths,1),size(opaths,1));
        connectSubsystemPorts(blkName,ipaths,iports,'Inport');
        connectSubsystemPorts(blkName,opaths,oports,'Outport');
    catch ME
        disp('HDL Cosimulation Block Error')
        disp(ME.message)
    end
end




function[paths,modes]=getMaskParams(PortPaths,PortModes)



    PortPaths=strrep(PortPaths,'/','_');
    paths=strread(PortPaths,'%s','delimiter',';','whitespace','');

    PortModes=strrep(PortModes,'[','');
    PortModes=strrep(PortModes,']','');
    modes=strread(PortModes,'%s','delimiter',' ');

    if(size(modes)~=size(paths))
        error(message('HDLLink:BlockInit:SubsystemUpdate'));
    end
end


function[ipaths,opaths]=separateInAndOutPaths(paths,modes)


    ipaths={};opaths={};
    for idx=1:numel(modes)
        if(strcmp(modes{idx},'1'))
            ipaths{end+1}=['Inport_',paths{idx}];
        elseif(strcmp(modes{idx},'2'))
            opaths{end+1}=['Outport_',paths{idx}];
        end
    end
    ipaths=ipaths';
    opaths=opaths';
end


function[iports,oports]=getSubSystemPorts(subsysName,subsysHandle)





    blks=get_param(subsysHandle,'Blocks');
    iports={};oports={};
    for idx=1:numel(blks)
        blkName=[subsysName,'/',blks{idx}];
        blkType=get_param(blkName,'BlockType');
        if(strcmp(blkType,'Inport')),iports{end+1}=blkName;
        elseif(strcmp(blkType,'Outport')),oports{end+1}=blkName;
        end
    end
    iports=iports';
    oports=oports';
end


function deleteAllLines(subsysHandle)
    lines=get_param(subsysHandle,'Lines');
    lineH=[lines.Handle];
    delete_line(lineH);
end


function newPortsList=deleteObsoletePorts(subsysName,paths,ports)




    newPortsList={};
    for portidx=1:numel(ports)
        pathExists=0;
        for pathidx=1:numel(paths)
            currPath=[subsysName,'/',paths{pathidx}];
            if(strcmp(ports{portidx},currPath))
                pathExists=1;
                newPortsList{end+1}=ports{portidx};
            end
        end
        if(~pathExists),delete_block(ports{portidx});end
    end
    newPortsList=newPortsList';

end


function newPortsList=createSubsystemPorts(subsysName,paths,ports,portType)
    if(strcmp(portType,'Inport'))
        posLeft=125;
    else
        posLeft=725;
    end


    npaths=length(paths);



    if npaths*30<32500
        step=30;
    else
        step=floor(32500/npaths);
    end

    newPortsList={};
    for pathidx=1:numel(paths)
        portExists=0;
        position=[posLeft,pathidx*step,posLeft+30,(pathidx*step+15)];
        currPath=[subsysName,'/',paths{pathidx}];
        newPortsList{end+1}=currPath;
        for portidx=1:numel(ports)
            if(strcmp(currPath,ports{portidx}))
                portExists=1;
                set_param(ports{portidx},'Port',num2str(pathidx));
                set_param(ports{portidx},'Position',position);
            end
        end
        if(~portExists)
            add_block(['built-in/',portType],currPath,...
            'Port',num2str(pathidx),'Position',position);
        end
    end
    newPortsList=newPortsList';
end


function initSfuncBlock(subsysName,numIports,numOports)


    vsize=min(max(numIports,numOports)*30,32767-25);
    hsize=100;
    sfuncPath=[subsysName,'/S-Function'];







    set_param(sfuncPath,'initReason','subsystemUpdate');


    set_param(sfuncPath,'Position',[300,25,300+hsize,25+vsize]);
end


function connectSubsystemPorts(subsysName,paths,ports,portType)
    for pathidx=1:numel(paths)
        portExists=0;
        currPath=[subsysName,'/',paths{pathidx}];
        for portidx=1:numel(ports)
            if(strcmp(currPath,ports{portidx}))
                portExists=1;

                if(strcmp(portType,'Inport'))
                    add_line(subsysName,[paths{pathidx},'/1'],...
                    ['S-Function/',num2str(pathidx)],...
                    'autorouting','on');
                else
                    add_line(subsysName,['S-Function/',num2str(pathidx)],...
                    [paths{pathidx},'/1'],...
                    'autorouting','on');
                end
            end
        end
        if(~portExists)
            add_line(subsysName,[paths{pathidx},'/',num2str(pathidx)],...
            ['S-Function/',num2str(pathidx)],...
            'autorouting','on');
        end
    end
end


