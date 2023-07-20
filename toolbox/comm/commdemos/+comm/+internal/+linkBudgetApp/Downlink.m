classdef Downlink<matlabshared.application.Component&...
    matlabshared.application.UITools&...
    matlabshared.application.ComponentBanner

    properties
        ShowDownlinkLink=true;
        ShowTxSatellite=true;
        ShowRxEarth=true;
        ShowDownlinkPropagation=true;
    end


    properties(Hidden)




hDownlinkLink
hTxSatellite
hRxEarth
hDownlinkPropagation
hShowDownlinkLink
hShowTxSatellite
hShowRxEarth
hShowDownlinkPropagation


hDownlinkLinkFrequency
hDownlinkLinkBandwidth
hDownlinkLinkPolarization
hDownlinkLinkBitRate
hDownlinkLinkRequiredEbN0
hDownlinkLinkImplementationLoss


hTxSatelliteLatitude
hTxSatelliteLongitude
hTxSatelliteAltitude
hTxSatelliteAmplifierPower
hTxSatelliteAmplifierBackoffLoss
hTxSatelliteAntennaDiameter
hTxSatelliteAntennaEfficiency
hTxSatelliteFeederLoss
hTxSatelliteRadomeLoss
hTxSatelliteMispointLoss
hTxSatelliteOtherLosses


hRxEarthLatitude
hRxEarthLongitude
hRxEarthAltitude
hRxEarthAntennaDiameter
hRxEarthAntennaEfficiency
hRxEarthRadomeLoss
hRxEarthFeederLoss
hRxEarthSystemTemperature
hRxEarthOtherLosses


hDownlinkPropagationRainRate
hDownlinkPropagationPolarizationTilt
hDownlinkPropagationFogCloudTemperature
hDownlinkPropagationFogCloudWaterDensity
hDownlinkPropagationTemperature
hDownlinkPropagationAtmPressure
hDownlinkPropagationWaterVaporDensity
hDownlinkPropagationOtherLosses

    end

    properties(SetAccess=protected,Hidden)
        Layout;
    end

    methods
        function this=Downlink(varargin)
            this@matlabshared.application.Component(varargin{:});
            update(this);
        end

        function name=getName(~)
            name=getString(message('comm_demos:LinkBudgetApp:Downlink'));
        end

        function tag=getTag(~)
            tag='downlink';
        end

        function update(this)
            model=this.Application.DataModel;
            updateWidgets(model.DownlinkLink,this)
            updateWidgets(model.TxSatellite,this)
            updateWidgets(model.RxEarth,this)
            updateWidgets(model.DownlinkPropagation,this)
        end

        function w=getWidget(this,type,tag)
            w=this.(['h',type,tag]);
        end
    end

    methods(Access=protected)
        function hFig=createFigure(this,varargin)
            hFig=createFigure@matlabshared.application.Component(this,varargin{:});

            createSegmentPanel(this,hFig,'DownlinkLink');
            createSegmentPanel(this,hFig,'TxSatellite');
            createSegmentPanel(this,hFig,'RxEarth');
            createSegmentPanel(this,hFig,'DownlinkPropagation');

            layout=matlabshared.application.layout.ScrollableGridBagLayout(hFig,...
            'VerticalWeights',[0,0,0,0,0,0,0,1],...
            'VerticalGap',3,...
            'HorizontalGap',3);

            labelProps={'Fill','Horizontal','TopInset',3,'MinimumHeight',17};
            add(layout,this.hShowDownlinkLink,1,1,labelProps{:});
            add(layout,this.hDownlinkLink,2,1,'Fill','Horizontal');
            add(layout,this.hShowTxSatellite,3,1,labelProps{:});
            add(layout,this.hTxSatellite,4,1,'Fill','Horizontal');
            add(layout,this.hShowRxEarth,5,1,labelProps{:});
            add(layout,this.hRxEarth,6,1,'Fill','Horizontal');
            add(layout,this.hShowDownlinkPropagation,7,1,labelProps{:},'Anchor','NorthWest');
            add(layout,this.hDownlinkPropagation,8,1,'Fill','Horizontal','Anchor','NorthWest');

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

            if strncmp(str,'DownlinkLink',12)
                str=str(13:end);
            elseif strncmp(str,'TxSatellite',11)
                str=str(12:end);
            elseif strncmp(str,'RxEarth',7)
                str=str(8:end);
            elseif strncmp(str,'DownlinkPropagation',19)
                str=str(20:end);
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
            nextRow=insertPanel(this,layout,'DownlinkLink',nextRow+1);
            nextRow=insertPanel(this,layout,'TxSatellite',nextRow+1);
            nextRow=insertPanel(this,layout,'RxEarth',nextRow+1);
            nextRow=insertPanel(this,layout,'DownlinkPropagation',nextRow+1);
            layout.VerticalWeights=[zeros(nextRow-2,1);1];
            clean(layout);
        end

        function defaultEditboxCallback(this,h,~)

            clearAllMessages(this);
            prop=h.Tag;
            model=this.Application.DataModel;
            if strncmp(prop,'DownlinkLink',12)
                prop(1:12)=[];
                type='DownlinkLink';
            elseif strncmp(prop,'TxSatellite',11)
                prop(1:11)=[];
                type='TxSatellite';
            elseif strncmp(prop,'RxEarth',7)
                prop(1:7)=[];
                type='RxEarth';
            elseif strncmp(prop,'DownlinkPropagation',19)
                prop(1:19)=[];
                type='DownlinkPropagation';
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


