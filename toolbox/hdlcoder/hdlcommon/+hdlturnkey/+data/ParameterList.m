


classdef ParameterList<hdlturnkey.data.ParameterListBase


    properties
        DynamicParameterList=[];
    end

    properties(Access=protected)
        hRD=[];
    end

    methods

        function obj=ParameterList(hRD)

            obj.DynamicParameterList=hdlturnkey.data.DynamicParameterList();
            obj.hRD=hRD;
        end

        function paramCell=getParameterCellFormat(obj)



            paramLength=obj.ParameterIDMap.length+obj.DynamicParameterList.ParameterIDMap.length;
            if paramLength==0
                paramCell={};
                return;
            end
            paramCell=cell(1,paramLength*2);
            paramIDList=obj.getAllParameterIDList;
            for ii=1:paramLength
                paramID=paramIDList{ii};
                paramCell{ii*2-1}=paramID;
                paramCell{ii*2}=obj.getParameterValue(paramID);
            end
        end

        function setParameterCellFormat(obj,paramCell)




            if strcmp(paramCell{1},'HDLVerifierJTAGAXI')
                paramCell{1}='HDLVerifierAXI';
                if strcmp(paramCell{2},'on')
                    paramCell{2}='JTAG';
                end
            end


            obj.validateInputParamCell(paramCell);

            try


                paramCellBackup=obj.getParameterCellFormat;

                for ii=1:2:length(paramCell)
                    paramID=paramCell{ii};

                    if~(obj.ParameterIDMap.isKey(paramID)||obj.DynamicParameterList.ParameterIDMap.isKey(paramID))
                        error(message('hdlcommon:plugin:CellParameterInvalid',paramID));
                    end
                    paramValue=paramCell{ii+1};
                    paramValueInternal=obj.getParameterValue(paramID);
                    if~strcmp(paramValue,paramValueInternal)
                        obj.setParameterValue(paramID,paramValue);
                    end
                end
            catch ME

                obj.setParameterCellFormat(paramCellBackup);
                rethrow(ME);
            end
        end

        function status=isParameterEqual(obj,paramCell)

            status=true;
            obj.validateInputParamCell(paramCell);


            paramStruct=[];
            paramIDList=obj.getAllParameterIDList;
            for ii=1:length(paramIDList)
                paramID=paramIDList{ii};
                hParameter=obj.getParameterObject(paramID);
                paramStruct.(paramID)=hParameter.DefaultValue;
            end


            for ii=1:2:length(paramCell)
                paramID=paramCell{ii};
                if~obj.ParameterIDMap.isKey(paramID)
                    status=false;
                    return;
                end
                paramValue=paramCell{ii+1};
                paramValueDefault=paramStruct.(paramID);
                if~strcmp(paramValue,paramValueDefault)
                    paramStruct.(paramID)=paramValue;
                end
            end



            for ii=1:length(paramIDList)
                paramID=paramIDList{ii};
                paramValueInternal=obj.getParameterValue(paramID);
                paramValueStruct=paramStruct.(paramID);
                if~strcmp(paramValueInternal,paramValueStruct)
                    status=false;
                    return;
                end
            end
        end

        function paramStruct=getParameterStructFormat(obj)



            paramStruct=[];
            paramIDList=obj.getAllParameterIDList;
            for ii=1:length(paramIDList)
                paramID=paramIDList{ii};
                paramStruct.(paramID)=obj.getParameterValue(paramID);
            end
        end

        function tablesetting=drawGUITable(obj)



            tablesetting=hdlturnkey.data.paramTableInitFormat;


            paramNumber=length(obj.getAllParameterIDList);
            tableRowNum=paramNumber;
            tableColumnNum=length(tablesetting.ColHeader);
            tablesetting.Size=[tableRowNum,tableColumnNum];


            tdata=cell(tableRowNum,tableColumnNum);


            for ii=1:paramNumber
                paramID=obj.getAllParameterIDList{ii};
                tdata=obj.drawGUITableRow(tdata,ii,paramID);
            end

            tablesetting.Data=tdata;
        end

        function tdata=drawGUITableRow(obj,tdata,rowIdx,paramID)


            colIdx=0;
            hParameter=obj.getParameterObject(paramID);

            colIdx=colIdx+1;
            tdParamItem=[];
            tdParamItem.Type='edit';
            tdParamItem.Editable=false;
            tdParamItem.Value=hParameter.DisplayName;
            tdata{rowIdx,colIdx}=tdParamItem;

            colIdx=colIdx+1;
            tdParamItem=[];
            if~isempty(hParameter.Choice)
                tdParamItem.Type='combobox';
                tdParamItem.Entries=hParameter.Choice;

                cmpresult=strcmp(hParameter.Value,hParameter.Choice);
                idxList=0:length(hParameter.Choice)-1;
                parameterIdx=idxList(cmpresult);
                tdParamItem.Value=parameterIdx;
            else
                tdParamItem.Type='edit';
                tdParamItem.Editable=true;
                tdParamItem.Value=hParameter.Value;
            end
            tdata{rowIdx,colIdx}=tdParamItem;
        end

        function setGUITable(obj,rowIdx,colIdx,newValue)


            paramIDList=obj.getAllParameterIDList;
            paramID=paramIDList{rowIdx+1};
            hParameter=obj.getParameterObject(paramID);


            currentParamValue=hParameter.Value;


            try
                if colIdx==1
                    paramChoice=hParameter.Choice;
                    if~isempty(paramChoice)
                        newIndex=newValue+1;
                        newParamValue=paramChoice{newIndex};
                    else
                        downstream.tool.checkNonASCII(newValue,hParameter.DisplayName);
                        newParamValue=newValue;
                    end
                end
                obj.setParameterValue(paramID,newParamValue);

            catch ME

                obj.setParameterValue(paramID,currentParamValue);
                obj.drawGUITable();
                rethrow(ME);
            end
        end

        function parseGUITable(obj,tablesetting)



            tsize=tablesetting.Size;
            paramNumber=length(obj.getAllParameterIDList);
            tableRowNum=paramNumber;
            if~isequal(tsize(1),tableRowNum)
                error(message('hdlcommon:workflow:TableSizeMismatch'));
            end


            tdata=tablesetting.Data;

            for ii=1:paramNumber
                paramID=obj.getAllParameterIDList{ii};
                obj.parseGUITableRow(tdata,ii,paramID);
            end
        end

        function parseGUITableRow(obj,tdata,rowIdx,paramID)


            colIdx=0;
            hParameter=obj.getParameterObject(paramID);


            colIdx=colIdx+1;
            tdParamItem=tdata{rowIdx,colIdx};
            paramNameGUI=tdParamItem.Value;

            if~strcmpi(paramNameGUI,hParameter.DisplayName)
                error(message('hdlcommon:workflow:TablePortNameMismatch',paramNameGUI,hParameter.DisplayName));
            end


            colIdx=colIdx+1;
            tdParamItem=tdata{rowIdx,colIdx};
            if~isempty(hParameter.Choice)
                paramValueIdxGUI=tdParamItem.Value+1;
                paramValueChoiceGUI=tdParamItem.Entries;
                paramValueStrGUI=paramValueChoiceGUI{paramValueIdxGUI};
            else
                paramValueStrGUI=tdParamItem.Value;
            end

            hParameter.Value=paramValueStrGUI;
        end

        function value=getTableCellGUIValue(obj,rowIdx,colIdx)
            paramIDList=obj.getAllParameterIDList;
            paramID=paramIDList{rowIdx+1};
            hParameter=obj.getParameterObject(paramID);

            if colIdx==0
                value=hParameter.DisplayName;
            else
                value=hParameter.Value;
            end
        end

        function isa=isParameterTableEmpty(obj)
            isa=obj.ParameterIDMap.isempty;
        end

        function isa=isParameterlistMember(obj,paramName)
            isa=~isempty(find(ismember(obj.getParameterCellFormat,paramName),1));
        end

        function hParameter=getParameterObject(obj,parameterID)
            if obj.ParameterIDMap.isKey(parameterID)
                hParameter=obj.getParameterObjectInternal(parameterID);
            elseif obj.DynamicParameterList.ParameterIDMap.isKey(parameterID)
                hParameter=obj.DynamicParameterList.getParameterObjectInternal(parameterID);
            else
                error(message('hdlcommon:plugin:InvalidParameterID',parameterID));
            end
        end

        function hParameter=getParameterObjectFromName(obj,parameterName)
            if obj.ParameterNameMap.isKey(parameterName)
                hParameter=obj.ParameterNameMap(parameterName);
            elseif obj.DynamicParameterList.ParameterNameMap.isKey(parameterName)
                hParameter=obj.ParameterNameMap(parameterName);
            else
                error(message('hdlcommon:plugin:InvalidParameterID',parameterName));
            end
        end


        function isa=isStaticParameter(obj,parameterID)
            if obj.ParameterIDMap.isKey(parameterID)
                isa=true;
            else
                isa=false;
            end
        end

        function list=getAllParameterIDList(obj)

            list=[obj.ParameterIDList,obj.DynamicParameterList.ParameterIDList];
        end

        function refreshParameterList(obj)
            obj.hRD.refreshParameterListInternal;
        end

        function setParameterValue(obj,parameterID,parameterValue)

            obj.setParameterValueInternal(parameterID,parameterValue);



            if(obj.isStaticParameter(parameterID))
                obj.refreshParameterList;
            end
        end

    end

end


