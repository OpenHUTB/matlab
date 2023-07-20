function[varargout]=autoblkscoreengemissionlookup(varargin)






    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        varargout{1}=Initialization(Block);
    case 'TableInit'
        varargout{1}=TableInit(Block);
    end

end


function M=Initialization(Block)


    autoblksgetmaskparms(Block,{'MassFracNames'},true);
    MassFracNames=cellstr(MassFracNames);


    BlkOptions={'autolibcoreengcommon/Mapped Emissions Lookup Tables','Mapped Emissions Lookup Tables';...
    'autolibcoreengcommon/No Emissions Lookup','No Emissions Lookup'};

    if~isempty(MassFracNames)
        autoblksreplaceblock(Block,BlkOptions,1);
    else
        autoblksreplaceblock(Block,BlkOptions,2);
    end

    M=1;

end


function M=TableInit(Block)

    autoblksgetmaskparms(Block,{'MassFracNames'},true);
    MassFracNames=cellstr(MassFracNames);




    MappedCoreBlkName=[Block,'/Mapped Core Engine'];
    MuxBlkName=[Block,'/Mux'];

    CheckTbl={'UnbrndFuelMassFrac',6;...
    'COMassFrac',7;...
    'NOxMassFrac',8;...
    'CO2MassFrac',9;...
    'PmMassFrac',10};


    [OnNames,OnIdx,M.MassFracIdx]=intersect(CheckTbl(:,1),MassFracNames,'stable');
    [OffNames,OffIdx]=setxor(CheckTbl(:,1),MassFracNames,'stable');
    M.NumMassFrac=length(OnIdx);


    SelectedSpecies={};
    for i=1:size(CheckTbl,1)
        SpeciesCheckbox=get_param(MappedCoreBlkName,['Use',num2str(CheckTbl{i,2})]);
        if strcmp(SpeciesCheckbox,'on')
            SelectedSpecies=[SelectedSpecies,CheckTbl{i,1}];
        end
    end

    if length(intersect(SelectedSpecies,OnNames))~=length(OnNames)||length(OnNames)~=length(SelectedSpecies)

        MuxPortHdls=find_system(Block,'FindAll','on','FollowLinks','on','LookUnderMasks','on',...
        'SearchDepth',1,'Parent',MuxBlkName,'PortType','inport');
        LineHdls=cell2mat(get_param(MuxPortHdls,'Line'));
        for i=1:length(LineHdls)
            if ishandle(LineHdls(i))
                delete_line(LineHdls(i))
            end
        end


        set_param(MuxBlkName,'Inputs',num2str(length(OnIdx)));


        for i=1:length(OnNames)
            set_param(MappedCoreBlkName,['Use',num2str(CheckTbl{OnIdx(i),2})],'on');
        end

        for i=1:length(OffNames)
            set_param(MappedCoreBlkName,['Use',num2str(CheckTbl{OffIdx(i),2})],'off');
        end


        for i=1:length(OnNames)
            add_line(Block,['Mapped Core Engine/',num2str(i)],['Mux/',num2str(i)])
        end

    end

end
