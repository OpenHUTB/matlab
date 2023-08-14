


classdef Spreadsheet<handle
    properties(Access=private)
DlgSource
M3IPort
ModelName
    end

    methods
        function obj=Spreadsheet(m3iPort,mdlName,dlg)
            obj.DlgSource=dlg;
            obj.M3IPort=m3iPort;
            obj.ModelName=mdlName;
        end

        function aChildren=getChildren(this)

            this.DlgSource.UserData.m_Children=[];
            if autosar.api.Utils.isNvPort(this.M3IPort)
                comSpecInfoObj=this.M3IPort.Info;
                comSpecPropName='ComSpec';
            else
                comSpecInfoObj=this.M3IPort.info;
                comSpecPropName='comSpec';
            end


            validComSpecs=[];
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            for idx=1:comSpecInfoObj.size()
                if comSpecInfoObj.at(idx).(comSpecPropName).isvalid()&&...
                    comSpecInfoObj.at(idx).DataElements.isvalid()&&...
                    this.isMapped(comSpecInfoObj.at(idx).DataElements.Name,modelMapping)
                    validComSpecs=[validComSpecs,idx];%#ok<AGROW>
                end
            end

            aChildren=autosar.ui.comspec.SpreadsheetRow.empty(length(validComSpecs),0);
            dataDictionary=get_param(this.ModelName,'DataDictionary');

            for idx=1:length(validComSpecs)

                comSpecIdx=validComSpecs(idx);
                aChildren(idx)=autosar.ui.comspec.SpreadsheetRow(...
                comSpecInfoObj.at(comSpecIdx),dataDictionary);
            end
            this.DlgSource.UserData.m_Children=aChildren;
        end

        function aResolved=resolveSourceSelection(~,aSelections,~,~)
            aResolved=aSelections;
        end

        function mapped=isMapped(this,deName,modelMapping)
            mapped=false;

            switch this.M3IPort.MetaClass.qualifiedName
            case{'Simulink.metamodel.arplatform.port.DataReceiverPort',...
                'Simulink.metamodel.arplatform.port.NvDataReceiverPort'}
                slPorts=modelMapping.Inports;
            case{'Simulink.metamodel.arplatform.port.DataSenderPort',...
                'Simulink.metamodel.arplatform.port.NvDataSenderPort'}
                slPorts=modelMapping.Outports;
            case{'Simulink.metamodel.arplatform.port.DataSenderReceiverPort',...
                'Simulink.metamodel.arplatform.port.NvDataSenderReceiverPort'}
                slPorts=[modelMapping.Inports,modelMapping.Outports];
            otherwise
                assert(false,'Unexpected port type %s',this.M3IPort.MetaClass.qualifiedName);
            end
            for ii=1:length(slPorts)
                slPortMapping=slPorts(ii).MappedTo;
                if strcmp(this.M3IPort.Name,slPortMapping.Port)&&...
                    strcmp(deName,slPortMapping.Element)&&...
                    ~ismember(slPortMapping.DataAccessMode,...
                    autosar.mm.sl2mm.ComSpecBuilder.DataAccessModesWithoutComSpec)
                    mapped=true;
                end
            end
        end
    end
end



