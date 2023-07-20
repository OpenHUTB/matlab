classdef AutoTimescaleDlg<handle

















    properties(SetObservable)

        UserData=[];

        isCurrentTimeScaleValid(1,1)logical=false;

        isValueChangeValid(1,1)logical=false;

        TableData=[];

        HdlTimeUnit(1,1)int16{mustBeReal}=0;
    end

    methods
        function this=AutoTimescaleDlg(dialog,newScaleFactor,portSampleTimes,hdlPrecision,isPushButton,varargin)
            if isempty(varargin)
                currentScaleFactor=newScaleFactor;
                currentScaleFactorIsValid=true;
            else
                currentScaleFactor=varargin{1};
                currentScaleFactorIsValid=varargin{2};
            end

            numPorts=length(portSampleTimes);
            this.UserData.Ports=cell(1,numPorts);
            portNames=textscan(dialog.Block.PortPaths,'%s','Delimiter',';');
            for m=1:numPorts
                port.Name=portNames{1}{m};
                port.SampleTime=portSampleTimes(m);
                port.UseSlTime=true;
                this.UserData.Ports{m}=port;
            end

            isVivado=isa(dialog,'hdllinkddg.CoSimBlockDialogXSI');




            if~isVivado

                clkData=dialog.ClockTableSource.GetSourceData;
                numClks=size(clkData,1);
                this.UserData.SlClks=cell(1,numClks);
                for idx=1:numClks
                    clk.Name=clkData{idx,1};
                    clk.UseSlTime=true;
                    clk.SampleTime=evalin('base',clkData{idx,3});
                    this.UserData.SlClks{idx}=clk;
                end


                try
                    tmp=textscan(dialog.Block.HdlClocks,'%s','Delimiter',';');
                    this.UserData.HdlClks=cell(1,numel(tmp{:}));
                    for m=1:numel(tmp{:})
                        rparse=textscan(tmp{1}{m},'%s %f %s');
                        hdlUnitValue=getHdlTimeUnitValue(hdlPrecision,[rparse{3}{1}]);
                        clk2.Name=[rparse{1}{:}];
                        clk2.UseSlTime=false;
                        clk2.SampleTime=rparse{2}*hdlUnitValue;
                        this.UserData.HdlClks{m}=clk2;
                    end
                catch ME %#ok<NASGU> 

                    this.UserData.HdlClks=cell(1,0);
                end


            else

                this.UserData.SlClks=cell(1,0);


                clkData=dialog.ClockResetTableSource.GetSourceData;
                numClks=size(clkData,1);
                this.UserData.HdlClks=cell(1,numClks);
                for idx=1:numClks
                    clk.Name=clkData{idx,1};
                    clk.UseSlTime=false;
                    clk.SampleTime=evalin('base',clkData{idx,3});
                    this.UserData.HdlClks{idx}=clk;
                end
            end

            maxAllowedTicks=2^31-1;
            this.UserData.TimeScale=currentScaleFactor;
            this.UserData.DefaultTimeScale=newScaleFactor;
            this.UserData.Precision=hdlPrecision;
            this.UserData.MaxHdlTime=maxAllowedTicks*hdlPrecision;
            this.UserData.MaskHandle=dialog;

            this.UserData.isPushButton=isPushButton;
            this.UserData.ParentDialog=dialog;
            this.HdlTimeUnit=getHdlTimeUnitEnumInt(dialog.TimingMode);
            this.UserData.HdlTimeUnit=this.HdlTimeUnit;
            this.isCurrentTimeScaleValid=currentScaleFactorIsValid;
            this.isValueChangeValid=true;

            this.UserData.UsedPorts=[this.UserData.HdlClks,this.UserData.SlClks,this.UserData.Ports];
            row=numel(this.UserData.UsedPorts);
            this.TableData=cell(row,3);

            for m=1:row
                UseSlTime=this.UserData.UsedPorts{m}.UseSlTime;
                this.TableData{m,1}=l_CreateTableEditCell(this.UserData.UsedPorts{m}.Name,false);
                this.TableData{m,2}=l_CreateTableEditCell('',~UseSlTime);
                this.TableData{m,3}=l_CreateTableEditCell('',UseSlTime);
            end
        end
    end

    methods
        function set.isCurrentTimeScaleValid(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isCurrentTimeScaleValid')
            value=logical(value);
            obj.isCurrentTimeScaleValid=value;
        end

        function set.isValueChangeValid(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isValueChangeValid')
            value=logical(value);
            obj.isValueChangeValid=value;
        end

        function set.HdlTimeUnit(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','HdlTimeUnit')
            value=round(value);
            obj.HdlTimeUnit=value;
        end
    end

    methods(Hidden)

        dlgStruct=getDialogSchema(this,dummy)
        onApply(this,dialog)
        onCancel(this,~)
        onHelp(~,~)
        onOK(this,dialog)
        onRestore(this,dialog)
    end
end

function hdlTimeUnitValue=getHdlTimeUnitValue(precision,hdlTimeUnit)
    switch(hdlTimeUnit)
    case 'Tick'
        hdlTimeUnitValue=precision;
    case 'fs'
        hdlTimeUnitValue=1e-15;
    case 'ps'
        hdlTimeUnitValue=1e-12;
    case 'ns'
        hdlTimeUnitValue=1e-9;
    case 'ms'
        hdlTimeUnitValue=1e-6;
    case 'us'
        hdlTimeUnitValue=1e-3;
    case 's'
        hdlTimeUnitValue=1;
    otherwise
        error(message('HDLLink:AutoTimescale:InvalidTimeUnit'));
    end
end

function hdlTimeUnitEnumInt=getHdlTimeUnitEnumInt(hdlTimeUnitValue)
    tuvmap=containers.Map({'Tick','fs','ps','ns','us','ms','s'},{-1,0,1,2,3,4,5});
    hdlTimeUnitEnumInt=tuvmap(hdlTimeUnitValue);
end

function widget=l_CreateTableEditCell(value,Enabled)
    widget.Type='edit';
    widget.Value=value;
    widget.Enabled=Enabled;
end

