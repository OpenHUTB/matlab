function[varargout]=vehdyndriverlat(varargin)


    block=varargin{1};
    maskMode=varargin{2};
    simStopped=autoblkschecksimstopped(block);









    switch maskMode
    case 0
        vehdyndriverlat(block,1);
        vehdyndriverlat(block,4);
        vehdyndriverlat(block,5);
        vehdyndriverlat(block,7);
        if simStopped

            labelList={'EnblSteerOvr';'SteerOvrCmd';'SteerHld';'SteerZero'};
            checkboxList={'extSteerOvr';'extSteerHld';'extSteerZero'};
            idxx=1;
            for idx=1:length(checkboxList)
                if strcmp(get_param(block,checkboxList{idx}),'on')
                    SwitchPort(block,labelList{idxx},'Inport',[]);
                    if endsWith(checkboxList{idx},'Ovr')
                        idxx=idxx+1;
                        SwitchPort(block,labelList{idxx},'Inport',[]);

                    end
                else
                    SwitchPort(block,labelList{idxx},'Ground',[]);
                    if endsWith(checkboxList{idx},'Ovr')
                        idxx=idxx+1;
                        SwitchPort(block,labelList{idxx},'Ground',[]);

                    end

                end
                idxx=idxx+1;
            end
        end

        if strcmp(get_param(block,'cntrlTypeLat'),'Predictive')
            inList={'LatRef';'LatFdbk';'LatVelFdbk';'YawFdbk';'YawVelFdbk'};
            gndList={'RefPose';'LongRef';'YawRef';'LongFdbk';'CurrPose';'Curvature'};

            ParamList={...
            'a',[1,1],{'gte',0};...
            'b',[1,1],{'gte',0};...
            'm',[1,1],{'gt',0};...
            'I',[1,1],{'gt',0};...
            'Cy_f',[1,1],{'gte',0};...
            'Cy_r',[1,1],{'gte',0};...
            'theta',[1,1],{'gt',0;'lte',pi};...
            'tau',[1,1],{'gt',0};...
            'L',[1,1],{'gt',0};...
            'Ksteer',[1,1],{'gt',0};...
            };
            LookupTblList=[];
        else

            if strcmp(get_param(block,'vecPose'),'on')
                inList={'RefPose';'CurrPose'};
                gndList={'LongRef';'LatRef';'YawRef';'LongFdbk';'LatFdbk';'LatVelFdbk';'YawFdbk'};
            else
                inList={'LongRef';'LatRef';'YawRef';'LongFdbk';'LatFdbk';'YawFdbk'};
                gndList={'RefPose';'CurrPose';'LatVelFdbk'};
            end
            if simStopped
                for idx=1:length(inList)
                    SwitchPort(block,inList{idx},'Inport',[]);
                end
                for idx=1:length(gndList)
                    SwitchPort(block,gndList{idx},'Ground',[]);
                end
            end

            if strcmp(get_param(block,'dynamMode'),'on')

                ParamList={...
                'a',[1,1],{'gte',0};...
                'b',[1,1],{'gte',0};...
                'm',[1,1],{'gt',0};...
                'Cy_f',[1,1],{'gte',0};...
                'theta',[1,1],{'gt',0;'lte',pi};...
                'Ksteer',[1,1],{'gt',0};...
                'PositionGainF',[1,1],{'gte',0};...
                'PositionGainR',[1,1],{'gte',0};...
                'YawRateGain',[1,1],{'gte',0};...
                'DelayGain',[1,1],{'gte',0}...
                };
                LookupTblList=[];
                inList={'Curvature';'YawVelFdbk'};
                gndList={};
            else

                ParamList={...
                'a',[1,1],{'gte',0};...
                'b',[1,1],{'gte',0};...
                'theta',[1,1],{'gt',0;'lte',pi};...
                'Ksteer',[1,1],{'gt',0};...
                'PositionGainF',[1,1],{'gte',0};...
                'PositionGainR',[1,1],{'gte',0};...
                };
                LookupTblList=[];
                inList={};
                gndList={'Curvature';'YawVelFdbk'};
            end
        end
        if simStopped
            for idx=1:length(inList)
                SwitchPort(block,inList{idx},'Inport',[]);
            end
            for idx=1:length(gndList)
                SwitchPort(block,gndList{idx},'Ground',[]);
            end
        end


        autoblkscheckparams(block,'Lateral Driver Model',ParamList,LookupTblList);
        varargout{1}=0;
    case 1
        if strcmp(get_param(block,'cntrlTypeLat'),'Predictive')

            autoblksenableparameters(block,[],[],{'PredGroup','VehGroup'},{'StanGroup'});
            set_param(block,'vecPose','off');
            if simStopped
                set_param([block,'/LateralType'],'LabelModeActiveChoice','0');
            end
        else
            autoblksenableparameters(block,[],[],{'StanGroup'},{'PredGroup'});
            if simStopped
                set_param([block,'/LateralType'],'LabelModeActiveChoice','1');
            end
            vehdyndriverlat(block,2);
            vehdyndriverlat(block,3);
        end
        varargout{1}=0;
    case 2
        if simStopped
            if strcmp(get_param(block,'vecPose'),'on')
                set_param([block,'/Pose Routing'],'LabelModeActiveChoice','1');
            else
                set_param([block,'/Pose Routing'],'LabelModeActiveChoice','0');
            end
        end
        varargout{1}=0;
    case 3
        if simStopped
            if strcmp(get_param(block,'cntrlTypeLat'),'Stanley')
                if strcmp(get_param(block,'dynamMode'),'on')
                    autoblksenableparameters(block,{'m','Cy_f','YawRateGain','DelayGain'},{'Cy_r','I'},[],[]);
                    set_param([block,'/LateralType/Stanley/Steer Response'],'LabelModeActiveChoice','1');
                else
                    autoblksenableparameters(block,[],{'m','Cy_f','I','YawRateGain','DelayGain','Cy_r'},[],[]);
                    set_param([block,'/LateralType/Stanley/Steer Response'],'LabelModeActiveChoice','0');
                end
            end
        end
        varargout{1}=0;
    case 4
        if simStopped
            inputUnits=get_param(block,'angUnits');
            try
                if strcmp(inputUnits,'inherit')
                    error(message('autoblks_shared:autoerrDriver:invalidAngUnits'));
                else
                    [~]=autoblksunitconv(1,'rad',inputUnits);
                    tempUnit=[inputUnits,'/s'];
                    set_param([block,'/Coordinates'],'yawRateUnit',tempUnit);
                    tempUnit=[inputUnits,'/m'];
                    set_param([block,'/Coordinates'],'curvUnit',tempUnit);
                end
            catch
                error(message('autoblks_shared:autoerrDriver:invalidAngUnits'));
            end
        end
        varargout{1}=0;
    case 5







        varargout{1}=0;
    case 7
        if strcmp(get_param(block,'steerOut'),'on')
            inputUnits=get_param(block,'angUnits');
            autoblksenableparameters(block,{'Ksteer'},[],[],[]);
            set_param([block,'/LateralType/MacAdam/SteerUnit'],'Unit',inputUnits);
            set_param([block,'/LateralType/Stanley/SteerUnit'],'Unit',inputUnits);
            set_param([block,'/External Action Routing/SteerOvrCmd'],'Unit',inputUnits);
            set_param([block,'/LateralType/MacAdam/BaseUnit'],'Unit','rad');
            set_param([block,'/LateralType/Stanley/BaseUnit'],'Unit','rad');
        else
            autoblksenableparameters(block,[],{'Ksteer'},[],[],'false');
            set_param([block,'/LateralType/MacAdam/SteerUnit'],'Unit','1');
            set_param([block,'/LateralType/Stanley/SteerUnit'],'Unit','1');
            set_param([block,'/External Action Routing/SteerOvrCmd'],'Unit','1');
            set_param([block,'/LateralType/MacAdam/BaseUnit'],'Unit','1');
            set_param([block,'/LateralType/Stanley/BaseUnit'],'Unit','1');

        end
        varargout{1}=0;
    case 8
        varargout{1}=DrawCommands(block);
    otherwise
        varargout{1}=0;
    end
end

function IconInfo=DrawCommands(BlkHdl)


    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='driverlat.png';

    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,15,90,'white');
end
function SwitchPort(Block,PortName,UsePort,Param)

    InportOption={'built-in/Constant',[PortName,'Constant'];...
    'built-in/Inport',PortName;...
    'simulink/Sinks/Terminator',[PortName,'Terminator'];...
    'simulink/Sinks/Out1',PortName;...
    'built-in/Ground',[PortName,'Ground']};
    switch UsePort
    case 'Constant'
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'Value',Param);
    case 'Terminator'
        autoblksreplaceblock(Block,InportOption,3);
    case 'Outport'
        autoblksreplaceblock(Block,InportOption,4);
    case 'Inport'
        autoblksreplaceblock(Block,InportOption,2);
    case 'Ground'
        autoblksreplaceblock(Block,InportOption,5);
    end

    InportNames={'VelRef';'RefPose';'LongRef';'LatRef';'YawRef';'EnblSteerOvr';'SteerOvrCmd';'SteerHld';'SteerZero';'Curvature';'VelFdbk';'CurrPose';'LongFdbk';'LatFdbk';'LatVelFdbk';'YawFdbk';'YawVelFdbk'};
    OutportNames={'Info';'SteerCmd'};
    FoundInNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
    [~,PortI]=intersect(InportNames,FoundInNames);
    FoundOutNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortO]=intersect(OutportNames,FoundOutNames);
    PortI=sort(PortI);
    PortO=sort(PortO);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end
    for i=1:length(PortO)
        set_param([Block,'/',OutportNames{PortO(i)}],'Port',num2str(i));
    end
end