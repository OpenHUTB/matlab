function varargout=autoblksmappedengine(varargin)


    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'UseCheckBoxCallback'
        UseCheckBoxCallback(Block,varargin{3});
    case 'EnableEngTempInput'
        EnableEngTempInput(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end

end


function Initialization(Block)

    NameClash=CheckForNameClashes(Block);

    if NameClash
        error(message('autoblks_shared:autoerrMappedEngine:portnameclash',Block));
    else

        FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
        FirstPort=get_param([Block,'/',FoundNames{1}],'Port');
        if strcmp(FirstPort,'1')
            set_param([Block,'/',FoundNames{1}],'name',get_param(Block,'RowVarName'));
            set_param([Block,'/',FoundNames{2}],'name',get_param(Block,'ColVarName'));
            EngTmpInpEnbl=strcmp(get_param(Block,'EngTmpInpEnbl'),'on');
            if EngTmpInpEnbl&&length(FoundNames(:))==3
                set_param([Block,'/',FoundNames{3}],'name',get_param(Block,'TmpVarName'));
            elseif EngTmpInpEnbl&&length(FoundNames(:))==2
                FoundGround=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Ground'),'Name');
                set_param([Block,'/',FoundGround{1}],'name',[get_param(Block,'TmpVarName'),' Ground']);
            end
        else
            EngTmpInpEnbl=strcmp(get_param(Block,'EngTmpInpEnbl'),'on');
            if EngTmpInpEnbl&&length(FoundNames(:))==3
                set_param([Block,'/',FoundNames{3}],'name',get_param(Block,'TmpVarName'));
            elseif EngTmpInpEnbl&&length(FoundNames(:))==2
                FoundGround=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Ground'),'Name');
                set_param([Block,'/',FoundGround{1}],'name',[get_param(Block,'TmpVarName'),' Ground']);
            end
            set_param([Block,'/',FoundNames{2}],'name',get_param(Block,'RowVarName'));
            set_param([Block,'/',FoundNames{1}],'name',get_param(Block,'ColVarName'));
        end
    end


    TabNames={'Power','Air','Fuel','Temperature','Efficiency','HC','CO','NOx','CO2','PM'};


    if autoblkschecksimstopped(Block)
        EnableEngTempInput(Block);
        EngTmpInpEnbl=get_param(Block,'EngTmpInpEnbl');

        if strcmp(EngTmpInpEnbl,'on')
            SwitchInport(Block,get_param(Block,'TmpVarName'),true);
        else
            SwitchInport(Block,get_param(Block,'TmpVarName'),false);
            ph=get_param([Block,'/',get_param(Block,'TmpVarName'),' Ground'],'porthandles');
            delete_line(get(ph.Outport,'Line'));
            add_line(Block,[get_param(Block,'TmpVarName'),' Ground/1'],'Temp/1','autorouting','on');
        end


        FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
        MO=get_param(Block,'MaskObject');

        TabIndex=[];
        PortNames={};
        k=1;


        for i=1:length(TabNames)
            if strcmp(get_param(Block,['Use',num2str(i)]),'on')&&strcmp(MO.Parameters.findobj('Name',['Use',num2str(i)]).Enabled,'on')
                PortNames{k}=get_param(Block,['Name',num2str(i)]);
                TabIndex(k)=i;
                k=k+1;
            end
        end

        FoundTables=find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Lookup_n-D');
        if~isempty(FoundNames)
            CurrentLUTBlockNumInputs=str2double(get_param(FoundTables{1},'NumberOfTableDimensions'));
        else
            CurrentLUTBlockNumInputs=0;
        end

        if(strcmp(EngTmpInpEnbl,'on')&&(CurrentLUTBlockNumInputs==3))||(strcmp(EngTmpInpEnbl,'off')&&(CurrentLUTBlockNumInputs==2))
            [~,IDelete,IAdd]=setxor(FoundNames,PortNames);
        else
            [~,IDelete,~]=setxor(FoundNames,{});
            [~,~,IAdd]=setxor({},PortNames);
        end

        DeleteExcessLookups(Block,FoundNames(IDelete));
        AddLookup(Block,TabIndex(IAdd));


        for i=1:length(PortNames)
            set_param([Block,'/',PortNames{i}],'Port',num2str(i));
        end
    end



    if strcmp(EngTmpInpEnbl,'off')

        TblBpt={'rowbreakpoints',{},'colbreakpoints',{}};


        LookupTblList=[];
        for i=1:10
            if i<=length(TabNames(:))
                if strcmp(get_param(Block,['Use',num2str(i)]),'on')
                    LookupTblList=[LookupTblList;{TblBpt,['Name',num2str(i),'_z'],{}};];
                end
            else
                break;
            end
        end

    else

        TblBpt={'rowbreakpoints',{},'colbreakpoints',{},'Tmpbreakpoints',{}};


        LookupTblList=[];
        for i=1:10
            if i<=length(TabNames(:))
                if strcmp(get_param(Block,['Use',num2str(i)]),'on')
                    LookupTblList=[LookupTblList;{TblBpt,['Name',num2str(i),'_z_3d'],{}};];
                end
            else
                break;
            end
        end

    end

    if~isempty(LookupTblList)
        autoblkscheckparams(Block,'Mapped Engine',[],LookupTblList);
    end

end



function UseCheckBoxCallback(Block,Index)


    if strcmp(get_param(Block,['Use',num2str(Index)]),'on')
        autoblksenableparameters(Block,[],[],['Tab',num2str(Index)],[]);
    else
        autoblksenableparameters(Block,[],[],[],['Tab',num2str(Index)]);
    end

    EngTmpInpEnbl=strcmp(get_param(Block,'EngTmpInpEnbl'),'on');

    ContainersTmpInput={'TmpVarName','Tmpbreakpoints',['Name',num2str(Index),'_z_3d']};
    ContainersNoTmpInput={['Name',num2str(Index),'_z']};

    if EngTmpInpEnbl>0
        autoblksenableparameters(Block,ContainersTmpInput,ContainersNoTmpInput);
    else
        autoblksenableparameters(Block,ContainersNoTmpInput,ContainersTmpInput);
    end

end




function AddLookup(Block,TabNum)
    if~isempty(TabNum)
        Inport1Pos=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport','Port','1'),'Position');
        Inport1Pos=Inport1Pos{:};
        TblHeight=64;
        TblWidth=64;
        PortHeight=14;
        PortWidth=30;
    end

    for i=1:length(TabNum)
        ParmName=get_param(Block,['Name',num2str(TabNum(i))]);

        BlkPosStart=[Inport1Pos(3)+100,Inport1Pos(2)+(TblHeight+25)*(TabNum(i)-1)];
        TblHdl=add_block('simulink/Lookup Tables/2-D Lookup Table',[Block,'/',ParmName,' Table'],'Position',[BlkPosStart,BlkPosStart+[TblWidth,TblHeight]]);
        PortHdl=get_param(TblHdl,'PortHandles');
        PortPos=get_param(PortHdl.Outport(1),'Position');
        PortPos=PortPos+[100,-PortHeight/2];
        add_block('simulink/Sinks/Out1',[Block,'/',ParmName],'Position',[PortPos,PortPos+[PortWidth,PortHeight]]);

        EngTmpInpEnbl=get_param(Block,'EngTmpInpEnbl');

        if strcmp(EngTmpInpEnbl,'on')
            set_param([Block,'/',ParmName,' Table'],'NumberOfTableDimensions','3');
            set_param([Block,'/',ParmName,' Table'],'BreakpointsForDimension3','Tmpbreakpoints');
        end

        h1=add_line(Block,[ParmName,' Table/1'],[ParmName,'/1']);
        set_param(h1,'Name',ParmName);

        if strcmp(EngTmpInpEnbl,'on')
            TableZName=['Name',num2str(TabNum(i)),'_z_3d'];
        else
            TableZName=['Name',num2str(TabNum(i)),'_z'];
        end

        set_param([Block,'/',ParmName,' Table'],'Table',TableZName,'BreakpointsForDimension1','rowbreakpoints','BreakpointsForDimension2','colbreakpoints');

        add_line(Block,[get_param(Block,'rowVarName'),'/1'],[ParmName,' Table/1']);
        add_line(Block,[get_param(Block,'colVarName'),'/1'],[ParmName,' Table/2']);
        if strcmp(EngTmpInpEnbl,'on')
            add_line(Block,[get_param(Block,'TmpVarName'),'/1'],[ParmName,' Table/3']);
        end
        set_param([Block,'/',ParmName,' Table'],'ExtrapMethod','Clip');
    end

end


function EnableEngTempInput(Block)

    EngTmpInpEnbl=strcmp(get_param(Block,'EngTmpInpEnbl'),'on');

    ContainersTmpInput={'TmpVarName','Tmpbreakpoints','Name1_z_3d','Name2_z_3d','Name3_z_3d','Name4_z_3d','Name5_z_3d','Name6_z_3d','Name7_z_3d','Name8_z_3d','Name9_z_3d','Name10_z_3d'};
    ContainersNoTmpInput={'Name1_z','Name2_z','Name3_z','Name4_z','Name5_z','Name6_z','Name7_z','Name8_z','Name9_z','Name10_z'};

    if EngTmpInpEnbl>0
        autoblksenableparameters(Block,ContainersTmpInput,ContainersNoTmpInput);
    else
        autoblksenableparameters(Block,ContainersNoTmpInput,ContainersTmpInput);
    end

end


function DeleteExcessLookups(Block,DeleteNames)


    for i=1:length(DeleteNames)
        OutName=DeleteNames{i};
        OutConn=autoblksgetblockconn(get_param([Block,'/',OutName],'handle'));
        phlu=get_param([Block,'/',OutConn.Inports.ConnBlkName],'porthandles');
        for j=1:length(phlu.Inport)
            lulinehdl=get_param(phlu.Inport(j),'Line');
            if lulinehdl~=-1
                delete_line(lulinehdl);
            end
        end
        delete_line(OutConn.Inports.LineHdl);
        delete_block(OutConn.Inports.ConnBlkHdl);
        delete_block(get_param([Block,'/',OutName],'handle'));
    end

end



function NameClash=CheckForNameClashes(Block)

    NameClash=false;
    MO=get_param(Block,'MaskObject');

    PotentialPortNames=[];

    k=1;
    for i=1:10
        if strcmp(get_param(Block,['Use',num2str(i)]),'on')&&strcmp(MO.Parameters.findobj('Name',['Use',num2str(i)]).Enabled,'on')
            PotentialPortNames{k}=get_param(Block,['Name',num2str(i)]);
            k=k+1;
        end
    end
    PotentialPortNames{k}=get_param(Block,'RowVarName');
    PotentialPortNames{k+1}=get_param(Block,'ColVarName');

    UniqueNames=unique(PotentialPortNames);

    if length(UniqueNames(:))<length(PotentialPortNames(:))
        NameClash=true;
        for i=1:length(UniqueNames)
            if sum(cell2mat(strfind(PotentialPortNames,UniqueNames{i})))>1
                break;
            end
        end
    end

end


function IconInfo=DrawCommands(Block)

    IconInfo=autoblksgetportlabels(Block);


    if strcmp(get_param(Block,'EngineType'),'Compression-ignition (CI)')
        IconInfo.ImageName='engine_mapped_core_ci_shared.png';
    else
        IconInfo.ImageName='engine_mapped_core_si_shared.png';
    end

    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,100,90,'white');
end



function SwitchInport(Block,PortName,UsePort)

    InportOption={'built-in/Ground',[PortName,' Ground'];...
    'built-in/Inport',PortName};
    if~UsePort
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'ShowName','off');
    else
        autoblksreplaceblock(Block,InportOption,2);
    end

end