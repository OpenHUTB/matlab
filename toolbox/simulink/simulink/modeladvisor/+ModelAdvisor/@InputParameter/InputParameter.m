classdef(CaseInsensitiveProperties=true)InputParameter<dynamicprops&matlab.mixin.Copyable

    properties(SetAccess=public,Hidden=true)
        Default='';
        Visible=true;
    end

    properties(SetAccess=public)
        Name='';
        Value={};
        Enable=true;
        Entries={};
        Description='';
        TableSetting=[];
        Type='String';
        RowSpan=[];
        ColSpan=[];
    end

    methods

        function InputParameter=InputParameter()
mlock
        end

        function setColSpan(inputParamObj,value)
            inputParamObj.ColSpan=value;
        end

        function setRowSpan(inputParamObj,value)
            inputParamObj.RowSpan=value;
        end

        function set.ColSpan(inputParamObj,value)

            if(isnumeric(value)&&length(value)==2&&value(1)>0&&value(2)>0)||...
                isempty(value)
                inputParamObj.ColSpan=value;
            else
                DAStudio.error('Simulink:tools:MAInvalidParam','integer');
            end
        end

        function set.RowSpan(inputParamObj,value)
            if isnumeric(value)&&length(value)==2&&value(1)>0&&value(2)>0||...
                isempty(value)
                inputParamObj.RowSpan=value;
            else
                DAStudio.error('Simulink:tools:MAInvalidParam','integer');
            end
        end

        function set.Type(inputParamObj,value)
            [~,InputParamTypes]=enumeration('ModelAdvisor.ModelAdvisorInputParamTypeEnum');
            [ismemberflag,idx]=ismember(lower(value),lower(InputParamTypes));
            if ismemberflag
                inputParamObj.Type=InputParamTypes{idx};
            else
                cell2table(InputParamTypes)
                DAStudio.error('ModelAdvisor:engine:MAInvalidInputParamType');
            end
        end

        function set.Enable(obj,value)
            obj.Enable=boolean(value);
        end

        function set.Visible(obj,value)
            obj.Visible=boolean(value);
        end

    end

    methods(Hidden=true)
        function success=importXML(this,XMLString)
            xmlFileName=tempname;
            fid=fopen(xmlFileName,'w');
            fprintf(fid,'%s\n','<?xml version="1.0" encoding="utf-8"?>');
            fprintf(fid,'%s\n','<MAConfiguration Version="1.0">');
            fprintf(fid,'%s\n','<CheckCellArray>');
            fprintf(fid,'%s\n','  <Check>');
            fprintf(fid,'%s\n','    <ID>dummyCheckID</ID>');
            fprintf(fid,'%s\n','      <InputParameters>');
            fprintf(fid,'%s\n',XMLString);
            fprintf(fid,'%s\n','      </InputParameters>');
            fprintf(fid,'%s\n','  </Check>');
            fprintf(fid,'%s\n','</CheckCellArray>');
            fprintf(fid,'%s\n','</MAConfiguration>');
            fclose(fid);
            try
                xmlInfo=Advisor.Utils.importEditTimeXML(xmlFileName);
                this.Value=xmlInfo.CheckCellArray{1}.InputParameters{1}.Value;
                success=true;
                delete(xmlFileName);
            catch
                success=false;
                delete(xmlFileName);
            end
        end







        function xmlString=exportXML(this)
            import matlab.io.xml.dom.*
            if strcmp(this.Type,'BlockType')
                docNode=Document('InputParameter');
                docRootNode=docNode.getDocumentElement;
                docRootNode.setAttribute('Name',this.Name);
                docRootNode.setAttribute('Type',this.Type);

                ValueElement=docNode.createElement('Value');
                ValueLength=size(this.Value);
                ValueLength=ValueLength(1);
                for i=1:ValueLength
                    thisElement=docNode.createElement('BlockType');
                    thisElement.appendChild(docNode.createTextNode(this.Value{i,1}));
                    if~isempty(this.Value{i,2})
                        thisElement.setAttribute('MaskType',this.Value{i,2});
                    end
                    ValueElement.appendChild(thisElement);
                end
                docRootNode.appendChild(ValueElement);
                xmlFileName=tempname;
                xmlwrite(xmlFileName,docNode);
                xmlString=fileread(xmlFileName);
                delete(xmlFileName);
                xmlString=xmlString(strfind(xmlString,'<InputParameter'):end);
            else
                xmlString='';
            end
        end

        function objStruct=toStruct(this)
            objStruct=struct('Name','','Index',0,'Type','','Visible','','Entries','','Value','','RowSpan','','ColSpan','','Enable',true);
            fields=fieldnames(objStruct);
            for i=1:numel(fields)
                if strcmp(fields{i},'Entries')&&strcmp(this.type,'PushButton')
                    objStruct.entries=[];
                elseif strcmp(fields{i},'Index')
                    objStruct.index=i;
                else
                    objStruct.(fields{i})=this.(fields{i});
                end
            end
        end

    end
end
