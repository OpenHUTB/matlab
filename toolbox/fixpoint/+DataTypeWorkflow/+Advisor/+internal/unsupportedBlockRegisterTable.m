



classdef unsupportedBlockRegisterTable<handle
    properties(Constant=true)



        repTable=containers.Map({'Simulink.Trigonometry.others',...
        'Simulink.Trigonometry.atan2','Simulink.Trigonometry.sin',...
        'Simulink.Trigonometry.cos','Simulink.Trigonometry.sincos',...
        'Simulink.DiscreteStateSpace','Simulink.DiscreteZeroPole',...
        'Simulink.MagnitudeAngleToComplex'},...
        {{'simulink/Lookup Tables','1-D Lookup Table','simulink',...
        ['simulink/Lookup Tables','/','1-D Lookup Table']},...
        {'simulink/Lookup Tables','2-D Lookup Table','simulink',...
        ['simulink/Lookup Tables','/','2-D Lookup Table']},...
        {fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model']),'FPA_sincos_subsystem_template',...
        fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model/FPA_sincos_subsystem_template.slx']),...
        'FPA_sincos_subsystem_template/Sine'},...
        {fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model']),'FPA_sincos_subsystem_template',...
        fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model/FPA_sincos_subsystem_template.slx']),...
        'FPA_sincos_subsystem_template/Cosine'},...
        {fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model']),'FPA_sincos_subsystem_template',...
        fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model/FPA_sincos_subsystem_template.slx']),...
        'FPA_sincos_subsystem_template/SinCos'},...
        {fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model']),'FPA_wired_subsystem_template',...
        fullfile([matlabroot,'/toolbox/fixpoint/fpca/Model/FPA_wired_subsystem_template.mdl']),...
        'FPA_wired_subsystem_template/Wired_Subsystem_For_Discrete_State_Space'},...
        {'simulink/Discrete','Discrete Transfer Fcn','simulink',...
        'simulink/Discrete/Discrete Transfer Fcn'},...
        {'simulink/Math Operations','MagnitudeAngleToComplex','simulink',...
        'simulink/Math Operations/MagnitudeAngleToComplex'}});
        fpaWiredSubsysTempMdlName='Fixed_Point_Advisor_Replace_Unsupported_Block';
    end
    properties
block
origBlkSSID
origBlkClass
repDir
repBlk
repSubSys
loadSysName
srcBlk
    end
    methods

        function obj=unsupportedBlockRegisterTable(blk)
            obj.block=blk;
            obj.origBlkSSID=Simulink.ID.getSID(blk.Handle);
            obj.origBlkClass=class(blk);
            [repDir,repBlk,loadSysName,srcBlk]=getRepDir(obj);
            obj.repDir=repDir;
            obj.repBlk=repBlk;
            obj.loadSysName=loadSysName;
            obj.srcBlk=srcBlk;
        end
        function[repDir,repBlk,loadSysName,srcBlk]=getRepDir(obj)
            key=obj.origBlkClass;
            if isprop(obj.block,'Operator')
                tmpOperator=obj.block.Operator;
                if~isempty(setdiff(tmpOperator,{'atan2','sin','cos','sincos'}))
                    key=[key,'.','others'];
                else
                    key=[key,'.',obj.block.Operator];
                end
            end
            if obj.repTable.isKey(key)
                value=obj.repTable(key);
                repDir=value{1};
                repBlk=value{2};
                loadSysName=value{3};
                srcBlk=value{4};
            else
                repDir='';
                repBlk='';
                loadSysName='';
                srcBlk='';
            end
        end



        function[repViewText,repText]=setActions(obj)
            useCordicTxt='';
            actionCordicTxt='';
            repBlkTxt='';
            if strcmp(obj.origBlkClass,'Simulink.Trigonometry')
                if supportCordic(obj)
                    useCordicTxt=[DAStudio.message('SimulinkFixedPoint:fpca:MSGCORDIC'),' / '];
                    actionCordicTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGSetCORDIC'));
                    curBlkNameEncode=modeladvisorprivate('HTMLjsencode',obj.block.getFullName,'encode');
                    actionCordicTxt.setHyperlink(['matlab: fpcadvisorprivate utilSetTriCordic ','''',curBlkNameEncode{:},'''']);
                    actionCordicTxt=[actionCordicTxt.emitHTML,' / '];
                end
                repBlkTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGSLTri'));
                actionRepBlkTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGContextReplaceSLTri'));
            elseif strcmp(obj.origBlkClass,'Simulink.MagnitudeAngleToComplex')
                useCordicTxt=DAStudio.message('SimulinkFixedPoint:fpca:MSGCORDIC');
                actionCordicTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGSetCORDIC'));
                curBlkNameEncode=modeladvisorprivate('HTMLjsencode',obj.block.getFullName,'encode');
                actionCordicTxt.setHyperlink(['matlab: fpcadvisorprivate utilSetTriCordic ','''',curBlkNameEncode{:},'''']);
                actionCordicTxt=[actionCordicTxt.emitHTML];
            elseif strcmp(obj.origBlkClass,'Simulink.DiscreteZeroPole')
                repBlkTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGSLDZP'));
                actionRepBlkTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGContextReplaceSLDZP'));
            else
                repBlkTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGSLDSS'));
                actionRepBlkTxt=ModelAdvisor.Text(DAStudio.message('SimulinkFixedPoint:fpca:MSGContextReplaceSLDSS'));
            end
            if isempty(repBlkTxt)
                repViewText=useCordicTxt;
                repText=actionCordicTxt;
            else
                origBlkFullName=modeladvisorprivate('HTMLjsencode',obj.block.getFullName,'encode');
                origBlkFullName=[origBlkFullName{:}];
                repBlkTxt.setHyperlink(['matlab: fpcadvisorprivate utilCreateParameterizedReplaceSubSys ','''',origBlkFullName,'''',' ','''true''']);
                actionRepBlkTxt.setHyperlink(['matlab: fpcadvisorprivate utilReplaceBlock ','''',obj.origBlkSSID,'''']);
                repViewText=[useCordicTxt,repBlkTxt.emitHTML];
                repText=[actionCordicTxt,actionRepBlkTxt.emitHTML];
            end
        end

        function addBlk(obj)
            obj.repSubSys=[obj.fpaWiredSubsysTempMdlName,'/',utilDisplayShortBlockPath(obj.block.getFullName,1)];
            try
                close_system(obj.fpaWiredSubsysTempMdlName,0);
            catch
            end

            new_system(obj.fpaWiredSubsysTempMdlName,'Model');
            if~strcmp(obj.loadSysName,'simulink')
                try
                    close_system(obj.repBlk,0);
                catch
                end
            end
            load_system(obj.loadSysName);
            add_block(obj.srcBlk,obj.repSubSys);
            if~strcmp(obj.loadSysName,'simulink')
                close_system(obj.repBlk);
            end
        end

        function[isSupportCordic,isCordicValue]=supportCordic(obj)

            isSupportCordic=false;
            isCordicValue=false;


            if isprop(obj.block,'ApproximationMethod')
                isSupportCordic=true;
                tmpMethods=obj.block.ApproximationMethod;
                if strcmp(tmpMethods,'CORDIC')
                    isCordicValue=true;
                end

            end

            if isprop(obj.block,'Operator')

                tmpOperator=obj.block.Operator;
                if isempty(setdiff(tmpOperator,{'atan2','sin','cos','sincos','cos + jsin'}))
                    isSupportCordic=true;
                else

                    isSupportCordic=false;

                    isCordicValue=false;
                end
            end
        end
    end
end



