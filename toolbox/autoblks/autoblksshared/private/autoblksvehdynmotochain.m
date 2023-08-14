function[varargout]=autoblksvehdynmotochain(varargin)



    block=varargin{1};
    callID=varargin{2};

    if callID==0


        ParamList={...
        'SprktFrIyy',[1,1],{'gt',0.;'lte',0.1};...
        'SprktRrIyy',[1,1],{'gt',0.;'lte',1};...
        'WhlRrIyy',[1,1],{'gt',0;'lte',50};...
        'SprktFrR',[1,1],{'gt',0.;'lte',1};...
        'SprktRrR',[1,1],{'gt',0.;'lte',2};...
        'WhlRrR',[1,1],{'gt',0;'lte',10};...
        'ArmRrLen',[1,1],{'gt',0;'lte',50};...
        'SprktFrPxz',[1,2],{'gte',-2.;'lte',2};...
        'WhlDmpK',[1,1],{'gte',0;'lte',1e10};...
        'WhlDmpC',[1,1],{'gte',0.;'lte',1e8};...
        'WhlDmpAng0',[1,1],{'gte',-1e6;'lte',1e6};...
        };

        autoblkscheckparams(block,'Motorcycle chain',ParamList);

        varargout{1}={};

    elseif callID==5


        IconInfo=autoblksgetportlabels(block,{});
        IconInfo.ImageName='vehicle_dynamics_motoChain.png';
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,70,'white');
        varargout{1}=IconInfo;

    elseif callID==6

        beta=InitialConditionsInitialize(block);

        varargout{1}={beta};

    else

        varargout{1}={};

    end



end


function beta=InitialConditionsInitialize(Block)

    autoblksgetmaskparms(Block,{'SprktFrPxz'},true);

    if SprktFrPxz(1)==0&&SprktFrPxz(2)==0
        beta=0;
    else
        beta=-atan(SprktFrPxz(2)/SprktFrPxz(1));
    end

end


