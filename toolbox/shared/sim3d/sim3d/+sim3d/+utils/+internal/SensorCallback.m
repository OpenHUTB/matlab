classdef SensorCallback




    methods(Static=true,Hidden=true)
        function addSensorTag(blk)



            if~bdIsLibrary(bdroot(blk))
                Mdl=bdroot(blk);
                sensorType='Sim3dSensor';
                sensorId=get_param(blk,'sensorId');
                ID=get_param(blk,'ID');
                switch sim3d.utils.internal.SensorCallback.getStatus(blk,sensorType,sensorId,ID)
                case 'AddDefault'
                    sensorTag=sim3d.utils.SimPool.next(Mdl,blk,sensorType);
                    set_param(blk,'ID',sensorTag.ID,'sensorId',sensorTag.ID);
                case 'AddNew'
                    sim3d.utils.SimPool.add(Mdl,blk,sensorType,str2double(sensorId));
                case 'Refresh'
                    sim3d.utils.SimPool.remove(Mdl,blk,sensorType,ID);
                    sim3d.utils.SimPool.add(Mdl,blk,sensorType,sensorId);
                    set_param(blk,'sensorName',[sensorType,sensorId],'ID',sensorId);
                case 'Skip'
                case 'Error'
                    error('ID %s is used in %s',sensorId,sim3d.utils.SimPool.getActorBlock(blk,sensorType,[sensorType,sensorId]));
                case 'Invalid'
                    error('ID %s is invalid ',sensorId);
                otherwise
                    error('%s is not valid case',sim3d.utils.internal.SensorCallback.getStatus(sensorType,sensorId,ID));
                end
            end
        end
        function out=getStatus(blk,sensorType,sensorId,ID)
            sensorTag=[sensorType,ID];
            sensorBlk=sim3d.utils.SimPool.getActorBlock(blk,'Sim3dSensor',sensorTag);
            if strcmp(sensorId,'0')&&isempty(ID)

                out='AddDefault';
            elseif strcmp(ID,sensorId)


                if isempty(sensorBlk)

                    out='AddNew';
                elseif strcmp(blk,sensorBlk)

                    out='Skip';
                else

                    out='Refresh';
                end
            else

                poolBlk=sim3d.utils.SimPool.getActorBlock(blk,'Sim3dSensor',[sensorType,sensorId]);
                if isempty(poolBlk)&&~strcmp(sensorId,'0')
                    out='Refresh';
                elseif strcmp(blk,poolBlk)

                    out='Skip';
                elseif str2double(sensorId)<=0
                    out='Invalid';
                else

                    out='Error';
                end
            end
        end
        function copyCallback(blk)
            if bdIsLibrary(bdroot(blk))
                return
            end

            UpdateDropdowns(blk);
            set_param(blk,'sensorId','0','ID','');
            currVehTag=get_param(blk,'vehTag');
            SimVeh=sim3d.utils.SimPool.getActorList(bdroot(blk),'SimulinkVehicle');
            Custom=sim3d.utils.SimPool.getActorList(bdroot(blk),'Custom');
            list=unique(sort([SimVeh,Custom]));
            if strcmp(currVehTag,'Scene Origin')&&~isempty(list)
                set_param(blk,'vehTag',list{1});
            end
        end
        function DestroyCallback(blk)
            lib=strsplit(blk,'/');
            if~strcmp(lib{1},'built-in')
                sim3d.utils.internal.SensorCallback.preDeleteCallback(blk)
            end
        end
        function preDeleteCallback(blk)
            if~bdIsLibrary(bdroot(blk))
                Mdl=bdroot(blk);
                ID=uint8(str2double(get_param(blk,'ID')));
                sim3d.utils.SimPool.remove(Mdl,blk,'Sim3dSensor',ID);
            end
        end
        function loadCallback(blk)
            sim3d.utils.internal.SensorCallback.addSensorTag(blk);
        end
        function nameChangeCallback(blk)
            sim3d.utils.internal.SensorCallback.addSensorTag(blk);
        end
        function postSaveCallback(blk)
            sim3d.utils.internal.SensorCallback.addSensorTag(blk);
        end
        function UndoDeleteCallback(blk)
            sim3d.utils.internal.SensorCallback.addSensorTag(blk);
        end

        function RemoveBuses(prefix)

            busVars=evalin('base',sprintf("who('%s*')",prefix));
            busVars="'"+busVars+"'";



            if~isempty(busVars)
                expr="clear "+strjoin(busVars);
                evalin('base',expr);
            end
        end

        function openFcnCallback(blk)
            UpdateDropdowns(blk);
            open_system(gcbh,'mask');

            blk_name=get_param(gcb,'Name');
            if strcmp(blk_name,'Simulation 3D Scene Configuration')
                SrcSelection=get_param(blk,'ProjectFormat');
                if strcmp(SrcSelection,'Unreal Editor')
                    if strcmp(computer('arch'),'win64')
                        p=System.Diagnostics.Process.GetProcessesByName('UE4Editor');
                    elseif strcmp(computer('arch'),'glnxa64')

                        p.Length=~(system("ps -C UE4Editor"));

                    end
                    maskObj=get_param(blk,'MaskObject');
                    opueBtn=maskObj.getDialogControl('OpenUEBtn');
                    ueproj=maskObj.getParameter('UEProjPath');

                    expression='([a-zA-Z0-9\s_\\.\-\(\):])+(.uproject)$';
                    FoundMatch=regexp(ueproj.Value,expression,'once');

                    if isempty(FoundMatch)||p.Length
                        opueBtn.Enabled='off';
                    else
                        opueBtn.Enabled='on';
                    end

                end
            end
        end
    end
end
