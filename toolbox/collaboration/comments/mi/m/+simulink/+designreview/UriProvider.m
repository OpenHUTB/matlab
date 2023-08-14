classdef(Hidden)UriProvider<handle






    methods(Static,Access=public)

        function uri=getTargetUri(editor)
            if isempty(editor)
                return;
            end

            selection=editor.getSelection;
            if(selection.size>0)
                if strcmp(editor.getType,'StateflowDI:Editor')
                    sb=selection.front;
                    root=sfroot;
                    element=root.find('id',sb.backendId);
                    modelAndSid=Simulink.ID.getStateflowSID(element);
                    sidAndSfId=extractAfter(modelAndSid,':');
                    sid=extractBefore(sidAndSfId,':');
                    sfId=extractAfter(sidAndSfId,':');
                    uri=['stateflow:',sfId,':simulink:',sid];
                else
                    sb=selection.front;
                    uri=Simulink.ID.getSID(sb.handle);
                    uri=['simulink:',get_param(uri,'SID')];
                end
            end
        end

        function ret=isStateflowUri(targetUri)
            ret=false;
            if(startsWith(targetUri,'stateflow:'))
                ret=true;
            end
        end

    end
end
