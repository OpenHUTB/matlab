classdef Uplink<matlabshared.application.Component&...
    matlabshared.application.UITools&...
    matlabshared.application.ComponentBanner




    properties
        ShowUplinkLink=true;
        ShowTxEarth=true;
        ShowRxSatellite=true;
        ShowUplinkPropagation=true;
    end


    properties(Hidden)

hUplinkLink
hTxEarth
hRxSatellite
hUplinkPropagation
hShowUplinkLink
hShowTxEarth
hShowRxSatellite
hShowUplinkPropagation


hUplinkLinkFrequency
hUplinkLinkBandwidth
hUplinkLinkPolarization
hUplinkLinkBitRate
hUplinkLinkRequiredEbN0
hUplinkLinkImplementationLoss


hTxEarthLatitude
hTxEarthLongitude
hTxEarthAltitude
hTxEarthAmplifierPower
hTxEarthAmplifierBackoffLoss
hTxEarthAntennaDiameter
hTxEarthAntennaEfficiency
hTxEarthFeederLoss
hTxEarthRadomeLoss
hTxEarthMispointLoss
hTxEarthOtherLosses


hRxSatelliteLatitude
hRxSatelliteLongitude
hRxSatelliteAltitude
hRxSatelliteAntennaDiameter
hRxSatelliteAntennaEfficiency
hRxSatelliteRadomeLoss
hRxSatelliteFeederLoss
hRxSatelliteSystemTemperature
hRxSatelliteOtherLosses


hUplinkPropagationRainRate
hUplinkPropagationPolarizationTilt
hUplinkPropagationFogCloudTemperature
hUplinkPropagationFogCloudWaterDensity
hUplinkPropagationTemperature
hUplinkPropagationAtmPressure
hUplinkPropagationWaterVaporDensity
hUplinkPropagationOtherLosses

    end

    properties(SetAccess=protected,Hidden)
        Layout;
    end

    methods
        function this=Uplink(varargin)
            this@matlabshared.application.Component(varargin{:});
            update(this);
        end

        function name=getName(~)
            name=getString(message('comm_demos:LinkBudgetApp:Uplink'));
        end

        function tag=getTag(~)
            tag='uplink';
        end

        function update(this)
            model=this.Application.DataModel;
            updateWidgets(model.UplinkLink,this)
            updateWidgets(model.TxEarth,this)
            updateWidgets(model.RxSatellite,this)
            updateWidgets(model.UplinkPropagation,this)
        end

        function w=getWidget(this,type,tag)
            w=this.(['h',type,tag]);
        end
    end

    methods(Access=protected)
        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,varargin{:});

            createSegmentPanel(this,hFig,'UplinkLink');
            createSegmentPanel(this,hFig,'TxEarth');
            createSegmentPanel(this,hFig,'RxSatellite');
            createSegmentPanel(this,hFig,'UplinkPropagation');

            layout=matlabshared.application.layout.ScrollableGridBagLayout(hFig,...
            'VerticalWeights',[0,0,0,0,0,0,0,1],...
            'VerticalGap',3,...
            'HorizontalGap',3);

            labelProps={'Fill','Horizontal','TopInset',3,'MinimumHeight',17};
            add(layout,this.hShowUplinkLink,1,1,labelProps{:});
            add(layout,this.hUplinkLink,2,1,'Fill','Horizontal');
            add(layout,this.hShowTxEarth,3,1,labelProps{:});
            add(layout,this.hTxEarth,4,1,'Fill','Horizontal');
            add(layout,this.hShowRxSatellite,5,1,labelProps{:});
            add(layout,this.hRxSatellite,6,1,'Fill','Horizontal');
            add(layout,this.hShowUplinkPropagation,7,1,labelProps{:},'Anchor','NorthWest');
            add(layout,this.hUplinkPropagation,8,1,'Fill','Horizontal','Anchor','NorthWest');

            this.Layout=layout;
        end

        function createSegmentPanel(this,hFig,type)
            createToggle(this,hFig,['Show',type]);
            hPanel=uipanel(hFig,...
            'BorderType','none','Tag',type,'AutoResizeChildren','off');
            this.(['h',type])=hPanel;
            props=getPropertyNames(this.Application.DataModel.(type));
            layout=matlabshared.application.layout.GridBagLayout(hPanel,...
            'HorizontalGap',3,...
            'VerticalGap',3,...
            'VerticalWeights',[zeros(numel(props)-1,1);1],...
            'HorizontalWeights',[0,1]);
            labelProps={'Fill','Horizontal','MinimumHeight',17,'TopInset',3};

            for indx=1:numel(props)
                label=createLabelEditPair(this,hPanel,[type,props{indx}]);
                label.HorizontalAlignment='right';
                add(layout,label,indx,1,labelProps{:});
                add(layout,this.(['h',type,props{indx}]),indx,2,'Fill','Horizontal');
            end

            labelWidth=layout.getMinimumWidth(layout.Grid(:,1));
            for indx=1:numel(props)
                setConstraints(layout,indx,1,'MinimumWidth',labelWidth);
            end

            [~,height]=getMinimumSize(layout);



            layout.setConstraints(hPanel,'MinimumHeight',height,'MinimumWidth',labelWidth+80);
        end

        function str=getLabelString(~,str)

            if strncmp(str,'UplinkLink',10)
                str=str(11:end);
            elseif strncmp(str,'TxEarth',7)
                str=str(8:end);
            elseif strncmp(str,'RxSatellite',11)
                str=str(12:end);
            elseif strncmp(str,'UplinkPropagation',17)
                str=str(18:end);
            elseif strncmp(str,'Show',4)
                str=str(5:end);
            end
            str=[getString(message(['comm_demos:LinkBudgetApp:',str])),':'];
        end
    end

    methods(Hidden)
        function updateLayout(this)
            layout=this.Layout;
            nextRow=1;
            nextRow=insertPanel(this,layout,'UplinkLink',nextRow+1);
            nextRow=insertPanel(this,layout,'TxEarth',nextRow+1);
            nextRow=insertPanel(this,layout,'RxSatellite',nextRow+1);
            nextRow=insertPanel(this,layout,'UplinkPropagation',nextRow+1);
            layout.VerticalWeights=[zeros(nextRow-2,1);1];
            clean(layout);
        end

        function defaultEditboxCallback(this,h,~)

            clearAllMessages(this);
            prop=h.Tag;
            model=this.Application.DataModel;
            if strncmp(prop,'UplinkLink',10)
                prop(1:10)=[];
                type='UplinkLink';
            elseif strncmp(prop,'TxEarth',7)
                prop(1:7)=[];
                type='TxEarth';
            elseif strncmp(prop,'RxSatellite',9)
                prop(1:11)=[];
                type='RxSatellite';
            elseif strncmp(prop,'UplinkPropagation',17)
                prop(1:17)=[];
                type='UplinkPropagation';
            end
            value=this.strToNum(h.String);
            me=validateProperty(this,type,prop,value);
            if isempty(me)
                setProperty(model,type,prop,this.strToNum(h.String));
            else
                update(this);
                errorMessage(this,me.message,me.identifier);
            end
        end

        function me=validateProperty(~,~,~,value)
            me=[];
            if isempty(value)||~isscalar(value)||isnan(value)||isinf(value)||~isreal(value)
                me.message=getString(message('comm_demos:LinkBudgetApp:InvalidValue'));
                me.identifier='comm_demos:LinkBudgetApp:InvalidValue';
            end
        end
    end
end


