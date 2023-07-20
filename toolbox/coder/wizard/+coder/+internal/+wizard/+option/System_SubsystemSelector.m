

classdef System_SubsystemSelector<coder.internal.wizard.OptionBase
    properties
RootNode
    end
    methods
        function obj=System_SubsystemSelector(env)
            id='System_SubsystemSelector';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Flavor';
            obj.Type='combobox';
            obj.Value={};
            obj.Indent=1;
            obj.RootNode=env.ModelName;
            obj.DepInfo=struct('Option','System_Subsystem','Value',true);
            obj.OptionMessage=[...
            '<div>',message(['RTW:wizard:Option_',id]).getString,'<span id="selected_subsystem"></span></div>'];
            obj.HasHintMessage=false;
        end
        function onNext(obj)
            env=obj.Env;
            a=env.getOptionAnswer('System_SubsystemSelector');
            env.SourceSubsystemHandle=get_param(Simulink.ID.getFullName(a{end}),'handle');
            if strcmp(env.SourceSubsystem,env.ModelName)
                env.SourceSubsystem='';
            end
            if ismember(env.SourceSubsystem,env.RefBlocks)
                env.ModelName=env.SourceSubsystem;
                env.BuildMode=coder.internal.wizard.BuildMode.MODELREFBUILD;
                load_system(env.ModelName);
            else
                env.BuildMode=coder.internal.wizard.BuildMode.SUBSYSTEMBUILD;
            end
        end
        function setAnswer(obj,a)
            if isempty(a)
                return;
            end
            try
                blkName=get_param(a,'Name');
            catch
                return;
            end
            obj.Answer=[blkName,getTreePath(a)];
            function out=getTreePath(blk)
                out={blk};
                while(1)
                    p=get_param(blk,'Parent');
                    if isempty(p)
                        return;
                    end
                    out=[Simulink.ID.getSID(p),out];%#ok<AGROW>
                    blk=p;
                end
            end
        end
    end
end


