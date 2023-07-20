function[WantBlockChoice,MT,Ts]=FullBridgeMMCExternalDCInit(varargin)





    block=varargin{1};
    ModelType=varargin{2};
    n=varargin{3};


    n=abs(n);
    n=round(n);
    n=max(1,n);
    if isinf(n)
        n=1;
    end

    Ts_user=varargin{4};

    switch lower(ModelType)
    case 'switching devices'
        WantBlockChoice='IGBTdiodes';
        MT=1;
        Ts=0;

    case 'switching function'
        if Ts_user>0
            WantBlockChoice='SF Discrete';
        else
            WantBlockChoice='SF Continuous';
        end

        MT=2;
        Ts=Ts_user;

    case 'average model (uref-controlled)'
        if Ts_user>0
            WantBlockChoice='AVG Discrete';
        else
            WantBlockChoice='AVG Continuous';
        end

        MT=3;
        Ts=Ts_user;

    end

    FullBridgeMMCExternalDCCback(block)



    RConnTags=get_param([block,'/FullBridgeMMCExternalDCLinks'],'RConnTags');
    PortHandles=get_param([block,'/FullBridgeMMCExternalDCLinks'],'PortHandles');

    if length(RConnTags)>2*n

        for i=2*n+1:length(RConnTags)
            LineToDelete=get_param(PortHandles.RConn(i),'line');
            delete_line(LineToDelete);
            delete_block([block,'/',RConnTags{i}]);
        end
        set_param([block,'/FullBridgeMMCExternalDCLinks'],'RConnTags',RConnTags(1:2*n));
    end

    if length(RConnTags)<2*n


        startpoint=length(RConnTags)+1;
        for i=length(RConnTags)/2+1:n

            BlockName=[block,'/c',num2str(i),'+'];
            add_block('built-in/PMIOPort',BlockName);
            set_param(BlockName,'side','Right');
            set_param(BlockName,'Position',[255,143+40+(i-2)*40,285,157+40+(i-2)*40],'orientation','left');
            RConnTags{end+1}=['c',num2str(i),'+'];

            BlockName=[block,'/c',num2str(i),'-'];
            add_block('built-in/PMIOPort',BlockName);
            set_param(BlockName,'side','Right');
            set_param(BlockName,'Position',[255,143+40+(i-2)*40+20,285,157+40+(i-2)*40+20],'orientation','left');
            RConnTags{end+1}=['c',num2str(i),'-'];

        end

        set_param([block,'/FullBridgeMMCExternalDCLinks'],'RConnTags',RConnTags);
        PortHandles=get_param([block,'/FullBridgeMMCExternalDCLinks'],'PortHandles');

        for i=startpoint:2*n
            xPortHandle=get_param([block,'/',RConnTags{i}],'PortHandles');
            add_line(block,PortHandles.RConn(i),xPortHandle.RConn);
        end

    end

    IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');
    SetNewGotoTag([block,'/Goto'],IsLibrary);
    SetNewGotoTag([block,'/From'],IsLibrary);