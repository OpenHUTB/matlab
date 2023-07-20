function[varargout]=vehdynsteeringmapped(varargin)


    varargout{1}=0;
    block=varargin{1};
    maskMode=varargin{2};
    spdDpd=get_param(block,'SpdDpd');
    maskObj=Simulink.Mask.get(block);


    switch maskMode
    case 'Main'
        Main;
    case 'SpdDpdCallback'
        SpdDpdCallback;
    case 'DrawCommands'
        varargout{1}=DrawCommands(block);
    case 'IndexandCfactorOptions'
        IandCOptions;
    otherwise
        varargout{1}=0;
    end
    function Main








        InportOption={'built-in/Ground','Ground';...
        'built-in/Inport','VehSpd'};
        EffctOptions={'vehdynlibsteeringcommon/Mapped','Mapped';...
        'vehdynlibsteeringcommon/MappedRackConstant','MappedRackConstant';...
        'vehdynlibsteeringcommon/MappedRackLUT','MappedRackLUT'};
        if strcmp(spdDpd,'on')
            set_param([block,'/LookupGain'],'tbl','SpdFctTbl');
            set_param([block,'/LookupGain'],'bpts','VehSpdBpts');
            autoblksreplaceblock(block,InportOption,2);
        else
            set_param([block,'/LookupGain'],'tbl','ones(1,2)');
            set_param([block,'/LookupGain'],'bpts','[-5000 5000]');
            NewBlkHdl=autoblksreplaceblock(block,InportOption,1);
            set_param(NewBlkHdl,'ShowName','off');
        end

        IndexType=get_param(block,'IndexType');
        if strcmp(IndexType,'Steering wheel angle')
            autoblksreplaceblock(block,EffctOptions,1);
        else
            GrType=get_param(block,'GrType');
            if strcmp(GrType,'Constant')
                autoblksreplaceblock(block,EffctOptions,2);
            else
                autoblksreplaceblock(block,EffctOptions,3);
            end
        end
    end
    function SpdDpdCallback
        if strcmp(spdDpd,'on')
            maskObj.getParameter('SpdFctTbl').Visible='on';
            maskObj.getParameter('VehSpdBpts').Visible='on';
            maskObj.getParameter('SpdFctTbl').Enabled='on';
            maskObj.getParameter('VehSpdBpts').Enabled='on';
        else
            maskObj.getParameter('SpdFctTbl').Visible='off';
            maskObj.getParameter('VehSpdBpts').Visible='off';
            maskObj.getParameter('SpdFctTbl').Enabled='off';
            maskObj.getParameter('VehSpdBpts').Enabled='off';
        end
    end
    function IandCOptions
        IndexType=get_param(block,'IndexType');
        if strcmp(IndexType,'Steering wheel angle')
            maskObj.getParameter('GrType').Visible='off';
            maskObj.getParameter('GrType').Enabled='off';
            maskObj.getParameter('RackDispBpts').Visible='off';
            maskObj.getParameter('RackDispBpts').Enabled='off';
            maskObj.getParameter('StrgAngBpts').Visible='on';
            maskObj.getParameter('StrgAngBpts').Enabled='on';
            maskObj.getParameter('Gr').Visible='off';
            maskObj.getParameter('Gr').Enabled='off';
            maskObj.getParameter('GrTbl').Visible='off';
            maskObj.getParameter('GrTbl').Enabled='off';
        else
            maskObj.getParameter('GrType').Visible='on';
            maskObj.getParameter('GrType').Enabled='on';
            GrType=get_param(block,'GrType');
            maskObj.getParameter('RackDispBpts').Visible='on';
            maskObj.getParameter('RackDispBpts').Enabled='on';
            if strcmp(GrType,'Constant')
                maskObj.getParameter('Gr').Visible='on';
                maskObj.getParameter('Gr').Enabled='on';
                maskObj.getParameter('GrTbl').Visible='off';
                maskObj.getParameter('GrTbl').Enabled='off';
                maskObj.getParameter('StrgAngBpts').Visible='off';
                maskObj.getParameter('StrgAngBpts').Enabled='off';
            else
                maskObj.getParameter('Gr').Visible='off';
                maskObj.getParameter('Gr').Enabled='off';
                maskObj.getParameter('GrTbl').Visible='on';
                maskObj.getParameter('GrTbl').Enabled='on';
                maskObj.getParameter('StrgAngBpts').Visible='on';
                maskObj.getParameter('StrgAngBpts').Enabled='on';
            end
        end
    end

    function IconInfo=DrawCommands(Block)


        AliasNames={};
        IconInfo=autoblksgetportlabels(Block,AliasNames);


        IconInfo.ImageName='steermap.png';

        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,50,'white');
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
    if nargout==0
        clear varargout;
    end
end