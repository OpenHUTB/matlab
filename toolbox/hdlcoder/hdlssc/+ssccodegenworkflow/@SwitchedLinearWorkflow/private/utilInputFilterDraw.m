function filterInfo=utilInputFilterDraw(spsBlockHandle,interfaceSystem,...
    HDLAlgorithmDataType,initialInputs,filterInfo,spsBlock)






    filterOrder=get_param(spsBlockHandle,'SimscapeFilterOrder');

    filterInfo.block(spsBlock).hasInputFilter=0;

    if(strcmp(filterOrder,'1'))

        inputFilterConst=get_param(spsBlockHandle,"InputFilterTimeConstant");

        hadd=add_block('hdlsllib/Math Operations/Add',strcat(interfaceSystem,'/sum'),...
        'Inputs','+-','MakeNameUnique','on');
        hgain=add_block('hdlsllib/Math Operations/Gain',strcat(interfaceSystem,'/gain'),...
        'Gain',num2str(1/str2double(inputFilterConst)),'MakeNameUnique','on');
        htime=add_block('hdlsllib/Discrete/Discrete-Time Integrator/',strcat(interfaceSystem,'/inte'),'MakeNameUnique','on',...
        'InitialCondition',num2str(initialInputs),'OutDataTypeStr',HDLAlgorithmDataType);



        filterInfo.hdlSubSystemBlocks(end+1:end+3,1)=[hgain;hadd;htime];
        filterInfo.block(spsBlock).hasInputFilter=1;
        filterInfo.block(spsBlock).inputHandle=hadd;
        filterInfo.block(spsBlock).outputHandle=htime;

        add_line(interfaceSystem,strcat(get_param(hadd,'Name'),'/1'),strcat(get_param(hgain,'Name'),'/1'),...
        'autorouting','on');
        add_line(interfaceSystem,strcat(get_param(hgain,'Name'),'/1'),strcat(get_param(htime,'Name'),'/1'),...
        'autorouting','on');
        add_line(interfaceSystem,strcat(get_param(htime,'Name'),'/1'),strcat(get_param(hadd,'Name'),'/2'),...
        'autorouting','on');

    elseif(strcmp(filterOrder,'2'))
        inputFilterConst=get_param(spsBlockHandle,'InputFilterTimeConstant');

        hadd1=add_block('hdlsllib/Math Operations/Add',strcat(interfaceSystem,'/sum'),...
        'Inputs','+-','MakeNameUnique','on');
        hadd2=add_block('hdlsllib/Math Operations/Add',strcat(interfaceSystem,'/sum'),...
        'Inputs','+-','MakeNameUnique','on');

        hgain1=add_block('hdlsllib/Math Operations/Gain',strcat(interfaceSystem,'/gain'),...
        'Gain',num2str(1/str2double(inputFilterConst)),'MakeNameUnique','on');
        hgain2=add_block('hdlsllib/Math Operations/Gain',strcat(interfaceSystem,'/gain'),...
        'Gain',num2str(1/str2double(inputFilterConst)),'MakeNameUnique','on');
        hgain3=add_block('hdlsllib/Math Operations/Gain',strcat(interfaceSystem,'/gain'),...
        'Gain','2','MakeNameUnique','on');

        htime1=add_block('hdlsllib/Discrete/Discrete-Time Integrator/',strcat(interfaceSystem,'/inte'),'MakeNameUnique','on',...
        'InitialCondition','0','OutDataTypeStr',HDLAlgorithmDataType);
        htime2=add_block('hdlsllib/Discrete/Discrete-Time Integrator/',strcat(interfaceSystem,'/inte'),'MakeNameUnique','on',...
        'InitialCondition',num2str(initialInputs),'OutDataTypeStr',HDLAlgorithmDataType);

        filterInfo.hdlSubSystemBlocks(end+1:end+7,1)=[hgain1;hgain2;hgain3;hadd1;hadd2;htime1;htime2];
        filterInfo.block(spsBlock).hasInputFilter=1;
        filterInfo.block(spsBlock).inputHandle=hadd1;
        filterInfo.block(spsBlock).outputHandle=htime2;

        add_line(interfaceSystem,strcat(get_param(htime2,'Name'),'/1'),strcat(get_param(hadd1,'Name'),'/2'),...
        'autorouting','smart');

        add_line(interfaceSystem,strcat(get_param(hadd1,'Name'),'/1'),strcat(get_param(hgain1,'Name'),'/1'),...
        'autorouting','smart');

        add_line(interfaceSystem,strcat(get_param(hgain1,'Name'),'/1'),strcat(get_param(hadd2,'Name'),'/1'),...
        'autorouting','smart');
        add_line(interfaceSystem,strcat(get_param(hgain3,'Name'),'/1'),strcat(get_param(hadd2,'Name'),'/2'),...
        'autorouting','smart');

        add_line(interfaceSystem,strcat(get_param(hadd2,'Name'),'/1'),strcat(get_param(hgain2,'Name'),'/1'),...
        'autorouting','smart');

        add_line(interfaceSystem,strcat(get_param(hgain2,'Name'),'/1'),strcat(get_param(htime1,'Name'),'/1'),...
        'autorouting','smart');

        add_line(interfaceSystem,strcat(get_param(htime1,'Name'),'/1'),strcat(get_param(htime2,'Name'),'/1'),...
        'autorouting','smart');

        add_line(interfaceSystem,strcat(get_param(htime1,'Name'),'/1'),strcat(get_param(hgain3,'Name'),'/1'),...
        'autorouting','smart');
    end

end

