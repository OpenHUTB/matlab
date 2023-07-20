




classdef IOInfo
    properties
        Inputs;
        Outputs;
        Parameters;
    end

    methods

        function this=IOInfo
            this.Inputs=containers.Map('KeyType','char','ValueType','any');
            this.Outputs=containers.Map('KeyType','char','ValueType','any');
            this.Parameters=containers.Map('KeyType','char','ValueType','any');
        end

        function addData(this,data)
            if data.isInput
                m=this.Inputs;
            elseif data.isOutput
                m=this.Outputs;
            else
                m=this.Parameters;
            end

            m(data.Name)=data;%#ok<NASGU>
        end

        function val=getInput(this,varName)
            val=[];
            if isKey(this.Inputs,varName)
                val=this.Inputs(varName);
            end
        end

        function val=getOutput(this,varName)
            val=[];
            if isKey(this.Outputs,varName)
                val=this.Outputs(varName);
            end
        end

        function val=getParameter(this,varName)
            val=[];
            if isKey(this.Parameters,varName)
                val=this.Parameters(varName);
            end
        end
    end
end
