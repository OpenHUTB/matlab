classdef MessageDiverter<handle
    methods
        function obj=MessageDiverter(testHarnessModelName,subsystemModelName)
            obj.m_TestHarnessModelName=testHarnessModelName;
            obj.m_SubsystemModelName=subsystemModelName;
        end

        function result=process(this,msgObject)
            result=msgObject;

            if(strcmp(msgObject.Severity,'WARNING'))
                this.m_NumWarnings=this.m_NumWarnings+1;
            elseif(strcmp(msgObject.Severity,'INFO'))
                this.m_NumInfos=this.m_NumInfos+1;
            elseif(strcmp(msgObject.Severity,'ERROR'))
                this.m_NumErrors=this.m_NumErrors+1;
            end
        end

        function delete(obj)
            if(0~=obj.m_NumErrors)
                if(1==obj.m_NumErrors)
                    Simulink.dv.UpdateStatusBar(obj.m_SubsystemModelName,DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_ONEERROR',1));
                else
                    Simulink.dv.UpdateStatusBar(obj.m_SubsystemModelName,DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_NERRORS',obj.m_NumErrors));
                end
            elseif(0~=obj.m_NumWarnings)
                if(1==obj.m_NumWarnings)
                    Simulink.dv.UpdateStatusBar(obj.m_SubsystemModelName,DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_ONEWARNING',1));
                else
                    Simulink.dv.UpdateStatusBar(obj.m_SubsystemModelName,DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_NWARNINGS',obj.m_NumWarnings));
                end
            elseif(0~=obj.m_NumInfos)
                Simulink.dv.UpdateStatusBar(obj.m_SubsystemModelName,DAStudio.message('Simulink:SLMsgViewer:STATUSBAR_VIEWDIAGNOSTICS'));
            else
                Simulink.dv.UpdateStatusBar(obj.m_SubsystemModelName,'');
            end
        end
    end

    properties
        m_TestHarnessModelName='';
        m_SubsystemModelName='';
        m_NumErrors=0;
        m_NumWarnings=0;
        m_NumInfos=0;
    end
end