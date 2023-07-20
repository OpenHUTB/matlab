classdef(Hidden=true)CoSimSignalSpreadSheetSource<handle

    properties
        dlgSource=[]
        portHandles=[]
        portType=''

        spreadsheetRowObjs=[]
        selectedRow=[]
    end

    properties(Constant)
        inport_fields={'ExtrapolationMethod','ExtrapolationCoefficient','CompensationMethod','CompensationCoefficient','DetectSignalJumpAndReset','EnableInterpolation'};
        inport_fieldDefs={'LinearExtrapolation','1','BuiltIn','1','false','false'};
    end

    methods(Access=public)
        function this=CoSimSignalSpreadSheetSource(dlgSource,blockName,portType)
            this.dlgSource=dlgSource;
            ph=get_param(blockName,'PortHandles');
            if strcmp(portType,'input')
                this.portHandles=ph.Inport;
            elseif strcmp(portType,'output')
                this.portHandles=ph.Outport;
            else
                assert(false,'Unknown cosim port type');
            end
            this.portType=portType;

            for i=1:length(this.portHandles)
                rowObj=Simulink.cosimservice.internal.CoSimSignalSpreadSheetListItem(this.dlgSource,this,i,this.portHandles(i),portType);
                this.spreadsheetRowObjs=[this.spreadsheetRowObjs,rowObj];
            end
        end

        function children=getChildren(this)
            children=this.spreadsheetRowObjs;
        end

        function ret=handleSelectionChanged(this,tag,sels,dlg)

            if strcmp(this.portType,'input')
                if length(sels)==1
                    this.selectedRow=sels{1};
                else
                    this.selectedRow=[];
                end
                this.updateInputAdvanceButtonState(dlg);
            end
            ret=true;
        end

        function updateInputAdvanceButtonState(this,dlg)
            if strcmp(this.portType,'input')
                tag_prefix='cosimsignal_';
                if~isempty(this.selectedRow)


                    isValid=strcmp(this.selectedRow.inputConfig.requestCompensation,'Always')||...
                    (strcmp(this.selectedRow.inputConfig.requestCompensation,'Auto')&&...
                    strcmp(this.selectedRow.inputConfig.canInsertSignalCouplingElement,'on'));
                    dlg.setEnabled([tag_prefix,'inputAdvancedButton'],isValid);
                else
                    dlg.setEnabled([tag_prefix,'inputAdvancedButton'],false);
                end
            end
        end

        function config=getPortCoSimSignalConfiguration(~,portHandle)
            config.isContinuousQuantity=get_param(portHandle,'CoSimSignalIsContinuousQuantity');
        end

        function config=getInportCoSimSignalConfiguration(this,portHandle)
            assert(strcmp(this.portType,'input'));

            port=get_param(portHandle,'Object');

            config.canInsertSignalCouplingElement=port.CoSimCanInsertCompensationBlock;

            config.requestCompensation=port.CoSimSignalCompensationMode;

            valStr=port.CoSimSignalCompensationConfig;
            valStruct=[];
            if~isempty(valStr)
                try
                    valStruct=jsondecode(valStr);
                catch

                end
            end

            for i=1:numel(this.inport_fields)
                if isfield(valStruct,this.inport_fields{i})
                    config.(this.inport_fields{i})=valStruct.(this.inport_fields{i});
                else
                    config.(this.inport_fields{i})=this.inport_fieldDefs{i};
                end
            end
        end

        function setInportCoSimSignalConfiguration(this,portHandle,config)
            assert(strcmp(this.portType,'input'));


            valStruct=[];
            for i=1:numel(this.inport_fields)
                if~strcmp(config.(this.inport_fields{i}),this.inport_fieldDefs{i})
                    valStruct.(this.inport_fields{i})=config.(this.inport_fields{i});
                end
            end

            valStr=jsonencode(valStruct);
            if strcmp(valStr,'[]')||strcmp(valStr,'{}')
                valStr='';
            end


            port=get_param(portHandle,'Object');
            port.CoSimSignalCompensationConfig=valStr;


            port.CoSimSignalCompensationMode=config.requestCompensation;
        end

        function applyAllConfiguration(this)
            assert(strcmp(this.portType,'input'));


            for i=1:length(this.portHandles)
                this.setInportCoSimSignalConfiguration(this.portHandles(i),this.spreadsheetRowObjs(i).inputConfig);
            end
        end
    end
end


