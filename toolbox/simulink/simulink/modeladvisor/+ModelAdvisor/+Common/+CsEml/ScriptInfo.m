
classdef ScriptInfo<handle

    methods

        function this=ScriptInfo(irScript)
            scriptPath=irScript.ScriptPath;
            if scriptPath(1)=='#'
                sid=scriptPath(2:end);
                this.m_Path=string(sid);
                sfObject=ModelAdvisor.Common.CsEml.Utilities.getStateflowObjectFromSid(sid);
                switch class(sfObject)
                case 'Stateflow.EMChart'
                    this.m_Type=ModelAdvisor.Common.CsEml.ScriptType.EMChart;
                    this.m_Code=string(irScript.ScriptText);
                case 'Stateflow.EMFunction'
                    this.m_Type=ModelAdvisor.Common.CsEml.ScriptType.EMFunction;
                    this.m_Code=string(irScript.ScriptText);
                case 'Stateflow.State'
                    this.m_Type=ModelAdvisor.Common.CsEml.ScriptType.State;
                    this.m_Code=string(sfObject.LabelString);
                case 'Stateflow.Transition'
                    this.m_Type=ModelAdvisor.Common.CsEml.ScriptType.Transition;
                    this.m_Code=string(sfObject.LabelString);
                otherwise
                    this.m_Type='<unknown>';
                    this.m_Code='<unknown>';
                end
            else
                this.m_Path=string(scriptPath);
                this.m_Type=ModelAdvisor.Common.CsEml.ScriptType.File;
                this.m_Code=string(irScript.ScriptText);
            end

            lfs=strfind(this.m_Code,newline);
            if~strcmp(this.m_Code,'<unknown>')
                this.m_Lines=[1,lfs+1;lfs,this.m_Code.strlength]';
                if this.m_Lines(end,1)>this.m_Lines(end,2)
                    this.m_Lines=this.m_Lines(1:end-1,:);
                end
            end

        end

        function path=getPath(this)
            path=this.m_Path;
        end

        function type=getType(this)
            type=this.m_Type;
        end

        function code=getCode(this)
            code=this.m_Code;
        end

        function lineNumber=getLineNumberFromPosition(this,position)
            lineNumber=find(...
            position>=this.m_Lines(:,1)&...
            position<=this.m_Lines(:,2));
        end

        function[lineStart,lineEnd]=getLinePosition(this,lineNumber)
            lineStart=this.m_Lines(lineNumber,1);
            lineEnd=this.m_Lines(lineNumber,2);
        end

    end

    properties
        m_Path;
        m_Type;
        m_Code;
        m_Lines;
    end

end

