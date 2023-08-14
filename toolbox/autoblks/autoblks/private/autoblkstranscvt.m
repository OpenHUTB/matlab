function[varargout]=autoblkstranscvt(varargin)





    varargout{1}=0;

    Block=varargin{1};
    maskMode=varargin{2};




    if maskMode==0

        CtrlConfigs={'autolibtranscvtcommon/Integrated Controller','Integrated Controller';...
        'autolibtranscvtcommon/External Controller','External Controller'};
        switch get_param(Block,'CtrlType')
        case 'Ideal integrated controller'
            autoblksreplaceblock(Block,CtrlConfigs,1);
        case 'External control'
            autoblksreplaceblock(Block,CtrlConfigs,2);
        end


        ParamList={...
        'rp_max',[1,1],{'gt','rp_min';'lt',10};...
        'rs_max',[1,1],{'gt','rs_min';'lt',10};...
        'rp_min',[1,1],{'gt',0;'lt',10};...
        'rs_min',[1,1],{'gt',0;'lt',10};...
        'rgap',[1,1],{'gt',0;'lt',10};...
        'thetaWedge',[1,1],{'gt',0;'lt',90};...
        'J_pri',[1,1],{'gt',0};...
        'J_sec',[1,1],{'gt',0};...
        'm_b',[1,1],{'gt',0};...
        'b_pri',[1,1],{'gt',0};...
        'b_sec',[1,1],{'gt',0};...
        'b_b',[1,1],{'gt',0};...
        'F_ax',[1,1],{'gt',0};...
        'J_fwd',[1,1],{'gt',0};...
        'J_rev',[1,1],{'gt',0};...
        'mu_static',[1,1],{'gt',0;'gte','mu_kin'};...
        'mu_kin',[1,1],{'gt',0;'lte','mu_static'};...
        'eta_fwd',[1,1],{'gt',0;'lte',1};...
        'eta_rev',[1,1],{'gt',0;'lte',1};...
        'N_rev',[1,1],{'gt',0};...
        'tau_s',[1,1],{'gt',0};...
        'N_o',[1,1],{'gt',0};...
        'eta_o',[1,1],{'gt',0;'lte',1};...
        };
        autoblkscheckparams(Block,ParamList);
        varargout{1}={};
    end

    if maskMode==2
        varargout{1}=DrawCommands(Block);
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'Input Spd','SpdIn';'Input Trq','TrqIn';...
    'Output Spd','SpdOut';'Output Trq','TrqOut';...
    'Input Torque','TrqIn';'Tout','TrqOut';...
    'Tin','TrqIn'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='transmission_cvt.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,80,'white');
end