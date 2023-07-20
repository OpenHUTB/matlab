function varargout=autoblkssimpleengine(varargin)


    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end

end


function Initialization(Block)



    ParamList={'Sg',[1,1],{'gte',0.2;'lte',1.2};...
    'Lhv',[1,1],{'gt',0};...
    'BsfcAvg',[1,1],{'gte',100;'lte',2000}};


    LookupTblList={{'f_tqmax_n_bpt',{'gte',-17e3;'lte',17e3}},'f_tqmax',{'gte',-1e6;'lte',1e6}};

    autoblkscheckparams(Block,'Simple Engine',ParamList,LookupTblList);


end



function IconInfo=DrawCommands(Block)

    IconInfo=autoblksgetportlabels(Block);


    IconInfo.ImageName='engine_simple.png';



    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1.2,50,90,'white');


    IconInfo.position(2)=IconInfo.position(2)-20;
    IconInfo.position(4)=IconInfo.position(4)-20;

end

