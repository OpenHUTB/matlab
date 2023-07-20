

classdef System<simulinkcoder.internal.wizard.QuestionBase
    methods
        function obj=System(env)
            id='System';
            topic=message('RTW:wizard:Topic_System').getString;
            obj@simulinkcoder.internal.wizard.QuestionBase(id,topic,env);

            obj.getAndAddOption(env,'System_Model');
            obj.getAndAddOption(env,'System_Subsystem');
            obj.getAndAddOption(env,'System_SubsystemSelector');
            obj.setDefaultValue('System_Model',true);
            obj.HintMessage=[...
            message(obj.Hint_Message_Id).getString,'<p> </p><div class="warning">'...
            ,env.Gui.getWarningImage,' '...
            ,message('RTW:wizard:SubsystemBuildWarning').getString,'</div>'];
        end
        function onChange(obj)
            env=obj.Env;
            if env.getOptionAnswer('System_Subsystem')
                useTree=true;
                v=env.getSubsystemNode(useTree);
                o=env.getOptionObj('System_SubsystemSelector');
                if length(v)==1
                    o.Type='text';
                    o.Value=message('RTW:wizard:Option_System_EmptySubsystem').getString;
                    modelOption=env.getOptionObj('System_Model');
                    modelOption.setAnswer(true);
                    subsystemOption=env.getOptionObj('System_Subsystem');
                    subsystemOption.setAnswer(false);
                    subsystemOption.HasSubsystem=false;
                    obj.TrailTable.HeadingMessage=message('RTW:wizard:Option_System_EmptySubsystem').getString;
                    obj.TrailTable.Content='';
                else
                    obj.TrailTable=[];
                    if useTree
                        o.Type='tree';
                    else
                        o.Type='combobox';
                    end
                    o.Value=v;
                    if isnumeric(o.Answer)&&o.Answer==-1
                        if length(o.Value)>1
                            o.setAnswer(o.Value(2).Id);
                        end
                    end
                end
            elseif env.getOptionAnswer('System_Model')
                env.SourceSubsystemHandle=[];
            end
        end
        function onNext(obj)
            env=obj.Env;
            modelOption=env.getOptionAnswer('System_Model');
            if~modelOption
                a=env.getOptionAnswer('System_SubsystemSelector');
                subsysName=getfullname(a{end});
                [mExc,isCompatiable]=env.subsysIsQuickStartCompatible(env.ModelName,subsysName);
                if isCompatiable

                    obj.Options{2}.NextQuestion_Id='Flavor';
                else

                    obj.Options{2}.NextQuestion_Id='System';
                    gui=env.Gui;
                    gui.send_command('openMessageBox',sprintf('%s\n',mExc.message));
                end
            end
            onNext@simulinkcoder.internal.wizard.QuestionBase(obj);
        end
        function preShow(obj)
            preShow@simulinkcoder.internal.wizard.QuestionBase(obj);

            env=obj.Env;
            if~isempty(env.SourceSubsystem)
                o=env.getOptionObj('System_Model');
                o.setAnswer(false);
                o=env.getOptionObj('System_Subsystem');
                o.setAnswer(true);
                o=env.getOptionObj('System_SubsystemSelector');
                o.setAnswer(Simulink.ID.getSID(env.SourceSubsystem));
                obj.onChange();
            end
        end
        function out=getSummary(obj)
            env=obj.Env;
            out=[message('RTW:wizard:QuestionSummary_System').getString,': '];
            if env.isSubsystemBuild
                out=[out,env.SourceSubsystem];
            else
                out=[out,env.ModelName];
            end
        end
    end
end


