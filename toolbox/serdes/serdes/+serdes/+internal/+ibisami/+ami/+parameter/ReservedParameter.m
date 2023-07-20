classdef ReservedParameter<serdes.internal.ibisami.ami.parameter.AmiParameter&...
    serdes.internal.ibisami.ami.SerDesNode





    properties(SetAccess=protected)


AllowedTypes
AllowedUsages
AllowedFormats
        DirectionTx=true;
        DirectionRx=true;
        EarliestRequiredVersion=6.1;
        IncludeInInit=false;
        CreateMWSVariables=false;
        ShowInDlg=false;
    end
    methods

        function parameter=ReservedParameter(varargin)

            parameter=parameter@serdes.internal.ibisami.ami.SerDesNode(varargin{:});
            parameter=parameter@serdes.internal.ibisami.ami.parameter.AmiParameter(varargin{:});
            parameter.NameLocked=true;
        end
    end
    methods
        function copiedParam=copy(param)




            copiedParam=serdes.internal.ibisami.ami.parameter.AmiParameter.getReservedParameter(param.NodeName);
            copiedParam.Description=param.Description;
            copiedParam.Usage=param.Usage.copy;
            copiedParam.Type=param.Type.copy;
            copiedParam.Format=param.Format.copy;
            copiedParam.CurrentValue=param.CurrentValue;
            copiedParam.NameLocked=param.NameLocked;
            copiedParam.Hidden=param.Hidden;
            copiedParam.New=param.New;
        end
    end
    methods(Access=protected)

        function ok=validateType(parameter,type)
            if isempty(parameter.AllowedTypes)
                ok=true;
            else
                if any(strcmp(type.Name,parameter.AllowedTypes))
                    ok=true;
                else
                    warning(message('serdes:ibis:NotAllowed',type.Name,"Type",parameter.NodeName))
                    ok=false;
                end
            end
        end
        function ok=validateUsage(parameter,usage)
            if isempty(parameter.AllowedUsages)
                ok=true;
            else
                if any(strcmp(usage.Name,parameter.AllowedUsages))
                    ok=true;
                else
                    warning(message('serdes:ibis:NotAllowed',usage.Name,"Usage",parameter.NodeName))
                    ok=false;
                end
            end
        end
        function ok=validateFormat(parameter,format)
            if isempty(parameter.AllowedFormats)
                ok=true;
            else
                if any(strcmp(format.Name,parameter.AllowedFormats))
                    ok=true;
                else
                    warning(message('serdes:ibis:NotAllowed',format.Name,"Format",parameter.NodeName))
                    ok=false;
                end
            end
        end
        function vName=validName(~,nodeName)

            if nodeName~=""&&...
                ~serdes.internal.ibisami.ami.parameter.AmiParameter.isReservedParameterName(nodeName)
                warning(message('serdes:ibis:NotReservedParameter',nodeName))
            end
            vName=nodeName;
        end
    end
end

