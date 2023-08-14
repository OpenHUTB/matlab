classdef Task_Help<simulinkcoder.internal.codeperspectivetask.BaseTask




    properties(Constant)
        ID='CodePerspectiveHelp'
    end

    methods
        function obj=Task_Help
        end
    end
    methods
        function result=turnOn(obj,editor,minimize)


            if nargin<3
                minimize=true;
            end

            cp=simulinkcoder.internal.CodePerspective.getInstance;
            help=cp.help;
            src=simulinkcoder.internal.util.getSource(editor);
            studio=src.studio;

            cmp=studio.getComponent(help.comp,help.id);
            if isempty(cmp)||~cmp.isVisible

                help.show(studio,minimize);
            else

                obj.reset(studio);
            end


            pref=simulinkcoder.internal.CodePerspectivePreference;
            pref.helpOn=true;

            result=true;
        end

        function turnOff(~,editor)


            src=simulinkcoder.internal.util.getSource(editor);
            studio=src.studio;

            cp=simulinkcoder.internal.CodePerspective.getInstance;
            help=cp.help;
            cmpName=help.comp;
            id=help.id;
            comp=studio.getComponent(cmpName,id);
            if~isempty(comp)&&comp.isVisible
                studio.hideComponent(comp);
            end

            pref=simulinkcoder.internal.CodePerspectivePreference;
            pref.helpOn=false;

        end

        function launchHelp(~,input)



            cp=simulinkcoder.internal.CodePerspective.getInstance;
            cp.help.show(input)
        end

        function bool=isAutoOn(obj,input)


            if~isAutoOn@simulinkcoder.internal.codeperspectivetask.BaseTask(obj,input)
                bool=false;
                return;
            end

            pref=simulinkcoder.internal.CodePerspectivePreference;
            bool=pref.helpOn;

            src=simulinkcoder.internal.util.getSource(input);

            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(src.modelH);
            if(strcmp(mappingType,'AutosarTarget')&&~isempty(modelMapping)&&modelMapping.IsSubComponent)
                bool=false;
            end

        end

        function status=getStatus(~,input)


            src=simulinkcoder.internal.util.getSource(input);
            studio=src.studio;

            cp=simulinkcoder.internal.CodePerspective.getInstance;
            help=cp.help;
            cmpName=help.comp;
            id=help.id;
            comp=studio.getComponent(cmpName,id);

            status=~isempty(comp)&&comp.isVisible;
        end

        function turnOffByCodePerspective(obj,input)


            status=obj.getStatus(input);

            obj.turnOff(input);

            pref=simulinkcoder.internal.CodePerspectivePreference;
            pref.helpOn=status;
        end

        function reset(obj,studio)
            src=simulinkcoder.internal.util.getSource(studio);
            mdl=src.modelH;
            cp=simulinkcoder.internal.CodePerspective.getInstance();
            [~,type]=cp.getInfo(mdl);
            help=cp.help;
            help.refresh(src.modelH,type);
        end
    end
end



