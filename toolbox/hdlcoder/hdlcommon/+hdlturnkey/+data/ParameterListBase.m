


classdef ParameterListBase<handle


    properties(Access=protected)


        ParameterIDList={};


        ParameterIDMap=[];
        ParameterNameMap=[];
    end

    properties(Hidden=true,Constant)

        ParameterExampleStr='hRD.addParameter(''ParameterID'', ''DutPath'', ''DisplayName'', ''Dut Path'', ''ParameterValue'', ''Rx'', ''ParameterType'', hdlcoder.ParameterType.Dropdown, ''ParameterChoice'', {''Rx'', ''Tx''})';

    end

    methods

        function obj=ParameterListBase()

            obj.clearParameterList;
        end

        function addParameter(obj,varargin)














            p=inputParser;
            p.addParameter('ParameterID','');
            p.addParameter('DefaultValue','');

            p.addParameter('DisplayName','');
            p.addParameter('ParameterType',hdlcoder.ParameterType.Edit);
            p.addParameter('Choice',{});
            p.addParameter('ValidationFcn',[]);

            p.parse(varargin{:});
            inputArgs=p.Results;

            parameterID=inputArgs.ParameterID;
            parameterValue=inputArgs.DefaultValue;
            parameterName=inputArgs.DisplayName;
            parameterType=inputArgs.ParameterType;
            parameterChoice=inputArgs.Choice;
            parameterValidationFnc=inputArgs.ValidationFcn;



            hdlturnkey.plugin.validateStringProperty(...
            parameterID,'ParameterID',obj.ParameterExampleStr);
            downstream.tool.checkNonASCII(parameterID,'ParameterID');
            hdlturnkey.plugin.validateRequiredProperty(...
            parameterID,'ParameterID',obj.ParameterExampleStr);

            try
                tempStruct.(parameterID)=0;%#ok<STRNU>
            catch ME
                error(message('hdlcommon:plugin:InvalidIDName',parameterID));
            end


            hdlturnkey.plugin.validateStringProperty(...
            parameterValue,'DefaultValue',obj.ParameterExampleStr);
            downstream.tool.checkNonASCII(parameterValue,'DefaultValue');
            hdlturnkey.plugin.validateRequiredProperty(...
            parameterValue,'DefaultValue',obj.ParameterExampleStr);


            hdlturnkey.plugin.validateStringProperty(...
            parameterName,'DisplayName',obj.ParameterExampleStr);


            if~isa(parameterType,'hdlcoder.ParameterType')
                error(message('hdlcommon:plugin:InvalidParameterType'));
            end


            hParameter=hdlturnkey.data.Parameter();
            hParameter.ID=parameterID;
            hParameter.Value=parameterValue;
            hParameter.DefaultValue=parameterValue;
            hParameter.ValidationFcn=parameterValidationFnc;
            if isempty(parameterName)
                hParameter.DisplayName=hParameter.ID;
            else
                hParameter.DisplayName=parameterName;
            end


            hParameter.ParameterType=parameterType;
            if parameterType==hdlcoder.ParameterType.Dropdown
                if isempty(parameterChoice)
                    error(message('hdlcommon:plugin:InvalidParameterChoice'));
                else
                    hdlturnkey.plugin.validateCellProperty(...
                    parameterChoice,'Choice',obj.ParameterExampleStr);
                    hdlturnkey.plugin.validatePropertyValue(...
                    parameterValue,'DefaultValue',parameterChoice);


                    hParameter.Choice=parameterChoice;
                end
            elseif parameterType==hdlcoder.ParameterType.Edit
                if~isempty(parameterChoice)
                    error(message('hdlcommon:plugin:InvalidParameterChoiceNotEmpty'));
                end
            end



            obj.addParameterObject(hParameter);
        end


        function removeParameter(obj,varargin)








            p=inputParser;
            p.addParameter('ParameterID','');

            p.parse(varargin{:});
            inputArgs=p.Results;

            parameterID=inputArgs.ParameterID;
            parameterName=obj.getParameterDisplayName(parameterID);

            if obj.ParameterIDMap.isKey(parameterID)

                obj.ParameterIDList(ismember(obj.ParameterIDList,parameterID))=[];

                paramIDMap=obj.ParameterIDMap;
                remove(paramIDMap,parameterID);

                paramNameMap=obj.ParameterNameMap;
                remove(paramNameMap,parameterName);
            end
        end

        function clearParameterList(obj)
            obj.ParameterIDList={};
            obj.ParameterIDMap=containers.Map();
            obj.ParameterNameMap=containers.Map();
        end

    end

    methods(Access=protected)

        function validateInputParamCell(~,paramCell)



            exampleStr='{''ParameterID1'', ''ParameterValue1''}';
            hdlturnkey.plugin.validateCellProperty(...
            paramCell,'paramCell',exampleStr);


            cellLength=length(paramCell);
            if mod(cellLength,2)~=0
                error(message('hdlcommon:plugin:CellParameterInPair',exampleStr));
            end

        end

        function validateParamIDExist(obj,parameterID)

            if~(obj.ParameterIDMap.isKey(parameterID)||obj.DynamicParameterList.ParameterIDMap.isKey(parameterID))
                error(message('hdlcommon:plugin:InvalidParameterID',parameterID));
            end
        end

        function addParameterObject(obj,hParameter)

            parameterID=hParameter.ID;
            if obj.ParameterIDMap.isKey(parameterID)
                error(message('hdlcommon:plugin:DuplicateParameterID',parameterID));
            end
            parameterName=hParameter.DisplayName;
            if obj.ParameterNameMap.isKey(parameterName)
                error(message('hdlcommon:plugin:DuplicateParameterName',parameterName));
            end
            obj.ParameterIDMap(parameterID)=hParameter;
            obj.ParameterNameMap(parameterName)=hParameter;
            obj.ParameterIDList{end+1}=parameterID;
        end

        function hParameter=getParameterObjectInternal(obj,parameterID)
            hParameter=obj.ParameterIDMap(parameterID);
        end
        function hParameter=getParameterObjectFromNameInternal(obj,parameterName)
            hParameter=obj.ParameterNameMap(parameterName);
        end

        function list=getParameterIDList(obj)

            list=obj.ParameterIDList;
        end

        function parameterValue=getParameterValue(obj,parameterID)
            obj.validateParamIDExist(parameterID);
            hParameter=obj.getParameterObject(parameterID);
            parameterValue=hParameter.Value;
        end
        function parameterName=getParameterDisplayName(obj,parameterID)
            obj.validateParamIDExist(parameterID);
            hParameter=obj.getParameterObject(parameterID);
            parameterName=hParameter.DisplayName;
        end
        function parameterID=getParameterID(obj,parameterName)
            if obj.ParameterNameMap.isKey(parameterName)
                hParameter=obj.getParameterObjectFromName(parameterName);
                parameterID=hParameter.ID;
            else
                error(message('hdlcommon:plugin:InvalidParameterID',parameterName));
            end
        end

        function setParameterValueInternal(obj,parameterID,parameterValue)
            obj.validateParamIDExist(parameterID);
            hParameter=obj.getParameterObject(parameterID);
            if~isempty(hParameter.Choice)
                hdlturnkey.plugin.validatePropertyValue(...
                parameterValue,'parameterValue',hParameter.Choice);
            end

            hParameter.validateParameterValue(parameterValue);
            hParameter.Value=parameterValue;
        end

    end

end


