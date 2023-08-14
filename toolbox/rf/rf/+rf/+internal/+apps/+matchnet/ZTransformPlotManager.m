
classdef ZTransformPlotManager<rf.internal.apps.matchnet.SinglePlotManager




    properties
        GreyLabel matlab.ui.control.Label
    end

    methods(Access=public)
        function this=ZTransformPlotManager(parent)
            this@rf.internal.apps.matchnet.SinglePlotManager(parent);
            this.PlotType='ZTransform';
        end


        function ui=makePlotOptionsUI(this,parent)
            ui=rf.internal.apps.matchnet.SmithZPlotOptions(parent,this.PlotParameterOptions);
            this.Listeners.ParameterUpdateListener=addlistener(ui,'ParameterOptionChanged',@(h,e)(this.updateParameterOptions(e.NewParameters)));
        end

        function setDefaultSelections(this)
            this.PlotParameterOptions={getString(message('rf:matchingnetworkgenerator:PathSL')),50};
        end

        function clearAxes(this)
            delete(this.myPlot.Children)
        end
    end

    methods(Access=protected,Static)
        function calculateFormattedPlotData(~)
        end
    end

    methods(Access=protected)
        function initializePlot(this)

            this.Parent.Figure.AutoResizeChildren='on';
            g=uigridlayout(this.Parent.Figure,...
            'RowHeight',{'1x','fit'},...
            'ColumnWidth',{'1x'},...
            'Visible',matlab.lang.OnOffSwitchState.off);


            this.myPlot=uipanel(g);
            this.myPlot.AutoResizeChildren=matlab.lang.OnOffSwitchState('off');
            this.myPlot.Layout.Row=1;
            this.myPlot.Layout.Column=1;
            this.setDefaultSelections();


            this.myPlotOptionsPanel=uipanel(g,'Title','Plot Options');
            this.myPlotOptionsPanel.Layout.Row=2;
            this.myPlotOptionsPanel.Layout.Column=1;
            this.myPlotOptionsUI=this.makePlotOptionsUI(this.myPlotOptionsPanel);

            this.GreyLabel=uilabel(g,'Text',...
            getString(message('rf:matchingnetworkgenerator:ImpedancePlotFailed')),...
            'FontSize',20,'WordWrap','on','FontColor',[0.5,0.5,0.5],...
            'HorizontalAlignment','center','Visible','off');
            this.GreyLabel.Layout.Row=1;
            this.GreyLabel.Layout.Column=1;

            g.Visible=matlab.lang.OnOffSwitchState.on;
        end

        function drawPlot(this)
            this.myPlot.Visible=matlab.lang.OnOffSwitchState.off;
            try
                if~isempty(this.PlotCircuits)
                    direction=this.PlotParameterOptions{1};
                    cktplot=find(strcmp(this.myPlotRawData(:,1),this.PlotCircuits{1}));
                    Nets=this.myPlotRawData{cktplot,4};
                    compval=this.myPlotRawData{cktplot,5};

                    f=this.myPlotRawData{cktplot,6};
                    Zin=cell2mat(this.myPlotRawData{cktplot,8});
                    Zl=cell2mat(this.myPlotRawData{cktplot,9});
                    Zo=this.PlotParameterOptions{2};
                    gamma_all=z2gamma([Zin,conj(Zl),conj(Zin),Zl],Zo);
                    if strcmpi(direction,getString(message('rf:matchingnetworkgenerator:PathSL')))
                        gammain=gamma_all(1);
                        gammal=gamma_all(2);
                        znew=Zin/Zo;
                        label1='z_in';
                        label2='z_out';

                        output=this.topologyToRfckt(Nets,compval,f,Zo);
                    elseif strcmpi(direction,getString(message('rf:matchingnetworkgenerator:PathLS')))
                        gammal=gamma_all(3);
                        gammain=gamma_all(4);
                        znew=Zl/Zo;
                        label1='z_out';
                        label2='z_in';

                        output=this.topologyToRfckt(flip(Nets),...
                        flip(compval),f,Zo);
                    end

                    path=zeros(size(output,1),100);
                    data_int=zeros(1,size(output,1));
                    for i=1:size(output,1)
                        if output(i,1)==1
                            tempz=linspace(znew,znew+output(i,2),100);
                            znew=znew+output(i,2);
                        elseif output(i,1)==2
                            ynew=(1/znew)+output(i,2);
                            temp=linspace((1/znew),ynew,100);
                            tempz=1./temp;
                            znew=1/ynew;
                        end
                        g=z2gamma(tempz,1);
                        path(i,:)=g;
                        data_int(i)=znew;
                    end
                    path=transpose(path);
                    path=path(:);
                    lgd=transpose("z"+arrayfun(@(x)internal.polariCommon.getUTFSubscriptNumber(x,'subscript'),(1:size(output,1))'));
                    data_int=[gammain,z2gamma(data_int(1:end-1),1),gammal];
                    data_int=repmat(data_int,2,1);
                    freq_int=f*ones(size(data_int,1),1);
                    freq=f*ones(size(path,1),1);
                    [freq,~,U]=engunits(freq);
                    xunit=strcat(U,'Hz');



                    switch length(output(:,1))
                    case 2
                        llabels=[label1,lgd(1:end-1),label2,'Matching path'];
                        hsm=smithplot(freq_int,data_int,'MarkerSize',10,...
                        'GridType','ZY','LineWidth',2,'Marker',{'o','o','o','none'},...
                        'LegendLabels',llabels,'TitleBottom',this.PlotCircuits{1},...
                        'Parent',this.myPlot);
                        hsm.add(freq,path);
                        for nlines=0:size(data_int,2)
                            linesinfo=hsm.currentlineinfo('gamma',llabels{end-nlines},...
                            'Freq',freq,xunit,'None','',Zin,Zo,Zl);
                            set(hsm.hDataLine(end-nlines),'UserData',linesinfo);
                        end
                    case 3
                        Q=this.myPlotRawData{cktplot,7};
                        llabels=["Loaded Q = "+num2str(Q),label1,lgd(1:end-1)...
                        ,label2,'Matching path'];
                        hsm=smithplot('Q',Q,'LegendLabels',llabels,...
                        'Marker',{'none','o','o','o','o','none'},'MarkerSize',10,...
                        'GridType','ZY','LineWidth',2,'TitleBottom',this.PlotCircuits{1},...
                        'Parent',this.myPlot);
                        hsm.add(freq_int,data_int);
                        hsm.add(freq,path);

                        for nlines=0:size(data_int,2)
                            linesinfo=hsm.currentlineinfo('gamma',llabels{end-nlines},...
                            'Freq',freq,xunit,'None','',Zin,Zo,Zl);
                            set(hsm.hDataLine(end-nlines),'UserData',linesinfo);
                        end

                    otherwise
                        error(message('rf:matchingnetworkgenerator:ImpedancePlotFailed'))
                    end
                    hsm.hAxes.Interactions=dataTipInteraction;
                end
                this.GreyLabel.Visible='off';
            catch
                this.GreyLabel.Visible='on';
            end
            this.myPlot.Visible=matlab.lang.OnOffSwitchState.on;
        end
    end

    methods(Static)

        function output=topologyToRfckt(net,values,f,Zo)
            EMPTY=0;
            SER_CAP=1;
            SER_INDCT=2;
            SHNT_CAP=3;
            SHNT_INDCT=4;




            output=zeros(numel(net),2);
            for j=1:length(net)
                switch net(j)
                case SER_CAP
                    xc=1/(values(j)*2*pi*f*Zo);
                    output(j,:)=[1,-1i*xc];
                case SER_INDCT
                    xl=(2*pi*f*values(j))/Zo;
                    output(j,:)=[1,1i*xl];
                case SHNT_CAP
                    bc=2*pi*f*values(j)*Zo;
                    output(j,:)=[2,1i*bc];
                case SHNT_INDCT
                    bl=Zo/(2*pi*f*values(j));
                    output(j,:)=[2,-1i*bl];
                case EMPTY

                otherwise

                    error(message('rf:matchingnetwork:UndefinedElement','smithp'));
                end
            end
            output(output(:,1)==0,:)=[];
        end
    end
end
