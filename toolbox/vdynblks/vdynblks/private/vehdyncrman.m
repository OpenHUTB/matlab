function[varargout]=vehdyncrman(varargin)




    block=varargin{1};
    maskMode=varargin{2};
    simStopped=autoblkschecksimstopped(block);









    switch maskMode
    case 0


        if simStopped
            inputUnits=get_param(block,'xdotUnit');
            try
                if strcmp(inputUnits,'inherit')
                    error(message('autoblks_shared:autoerrDriver:invalidUnits'));
                else
                    [~]=autoblksunitconv(1,'m/s',inputUnits);
                end
            catch
                error(message('autoblks_shared:autoerrDriver:invalidUnits'));
            end

        end

        ParamList={...
        't_start',[1,1],{'gte',0};...
        };
        LookupTblList=[];



        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'Manuever Block',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'Manuever Block',ParamList);
        end
        [varargout{1},varargout{2},varargout{3},varargout{4}]=vehdyncrman(block,6);
    case 1















        varargout{1}=[];

    case 2



        varargout{1}=[];

    case 3

        varargout{1}=[];
    case 4





    case 6
        paramstruct=autoblkscheckparams(block,'block',{'vehW',[1,1],{'gt',0};'X_o',[1,1],{};'Y_o',[1,1],{};'R',[1,1],{'neq',0};'steerDir',[1,1],{}});
        if boolean(paramstruct.steerDir)
            R=-paramstruct.R;
        else
            R=paramstruct.R;
        end
        [LPos,RPos,LNames,RNames]=vdyndlccones('Constant Radius',paramstruct.vehW,paramstruct.X_o,paramstruct.Y_o,R);
        if simStopped
            if strcmp(get_param(block,'use3DCones'),'on')
                set_param([block,'/Cones'],'LabelModeActiveChoice','1');
            else
                set_param([block,'/Cones'],'LabelModeActiveChoice','0');
            end
            set_param([block,'/Cones/sim3d Cones/Left Cones'],'ActorTag',LNames);
            set_param([block,'/Cones/sim3d Cones/Right Cones'],'ActorTag',RNames);
        end
        varargout{1}=LPos;
        varargout{2}=RPos;
        varargout{3}=LNames;
        varargout{4}=RNames;
    case 8
        varargout{1}=DrawCommands(block);
    otherwise
        varargout{1}=[];

    end

end


function IconInfo=DrawCommands(~)














    IconInfo=[];
end