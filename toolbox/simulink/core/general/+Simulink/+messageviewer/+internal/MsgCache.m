



classdef MsgCache<handle

    properties(Hidden)

        m_Diagnostics;
    end


    methods(Access='public',Hidden=true)

        function obj=MsgCache()
            obj.m_Diagnostics=[];
        end

        function push(this,aRecord)
            if isempty(this.m_Diagnostics)
                this.m_Diagnostics=aRecord;
            else
                this.m_Diagnostics(end+1)=aRecord;
            end
        end

        function clear(this,aSLMsgViewerList)
            iDiagnosticIndicesToClear=[];


            for i=1:length(this.m_Diagnostics)

                for j=1:length(aSLMsgViewerList)
                    if this.canFlush(aSLMsgViewerList(j),this.m_Diagnostics(i).ModelName)
                        aSLMsgViewerList(j).processRecordDV(this.m_Diagnostics(i));
                    end
                end

                iDiagnosticIndicesToClear(end+1)=i;%#ok<AGROW>

            end


            this.m_Diagnostics(iDiagnosticIndicesToClear)=[];
        end

        function bResult=canFlush(~,aDvInstance,aModelName)
            bResult=false;

            if strcmp(aDvInstance.m_ModelName,slmsgviewer.m_DefaultModelName)
                bResult=true;
            end

            if strcmp(aDvInstance.m_ModelName,aModelName)
                bResult=true;
            end

            aRefComponentList=aDvInstance.m_RefComponentList;

            for i=1:length(aRefComponentList)
                if strcmp(aRefComponentList(i),aModelName)
                    bResult=true;
                end
            end
        end
    end
end
