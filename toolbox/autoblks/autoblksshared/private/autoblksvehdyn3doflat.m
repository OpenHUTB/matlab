function[varargout]=autoblksvehdyn3doflat(varargin)



    block=varargin{1};
    maskMode=varargin{2};















    switch maskMode
    case 0














































































        ParamList={...
        'NF',[1,1],{'gt',0;'int',0};...
        'NR',[1,1],{'gt',0;'int',0};...
        'm',[1,1],{'gt',0};...
        'a',[1,1],{'gte',0};...
        'b',[1,1],{'gte',0};...
        'h',[1,1],{'gte',0};...
        'w',[1,2],{'gte',0};...
        'X_o',[1,1],{};...
        'xdot_o',[1,1],{};...
        'Cy_f',[1,1],{'gte',0};...
        'Cy_r',[1,1],{'gte',0};...
        'sigma_f',[1,1],{'gt',0};...
        'sigma_r',[1,1],{'gt',0};...
        'Y_o',[1,1],{};...
        'ydot_o',[1,1],{};...
        'Cd',[1,1],{'gte',0};...
        'Af',[1,1],{'gte',0};...
        'Cl',[1,1],{};...
        'Izz',[1,1],{'gt',0};...
        'Cpm',[1,1],{};...
        'r_o',[1,1],{};...
        'psi_o',[1,1],{};...
        'Pabs',[1,1],{'gte',0};...
        'Tair',[1,1],{'gte',0};...
        'g',[1,1],{'gte',0};...
        'mu',[1,1],{'gte',0};...
        'xdot_tol',[1,1],{'gt',0};...
        'Fznom',[1,1],{'gt',0};...
        'Fxtire_sat',[1,1],{'gt',0};...
        'Fytire_sat',[1,1],{'gt',0};...
        };

        LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
        {'alpha_r_brk',{}},'Cy_r_data',{};...
        {'beta_w',{}},'Cs',{};...
        {'beta_w',{}},'Cym',{}};

        autoblkscheckparams(block,'Vehicle Body Bicycle Model',ParamList,LookupTblList);

        varargout{1}=0;

    case 1

























        varargout{1}=0;

    case 2









        varargout{1}=0;

    case 3





















        [~]=vehdynlat3dof(block,4);
        varargout{1}=0;

    case 4






































        varargout{1}=0;

    case 5








        varargout{1}=0;
    case 8
        trackMode='Single (bicycle)';
        varargout{1}=DrawCommands(block,trackMode);

    otherwise
        varargout{1}=0;
    end
end












function IconInfo=DrawCommands(BlkHdl,trackMode)

    switch trackMode
    case 'Single (bicycle)'

        AliasNames={'delta_f','delta_f';...
        'Info','Info'};
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dofstrack.png';
    otherwise
        AliasNames={'delta_f','delta_f';...
        'Info','Info'};
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dofdtrack.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,0,'white');
end