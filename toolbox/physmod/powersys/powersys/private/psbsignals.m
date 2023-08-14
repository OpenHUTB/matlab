function psbsignals(varargin)







    Block=gcb;
    switch get_param(Block,'PlotAtSimulationStop')
    case 'off'
        variable=get_param([Block,'/StoreData/To Workspace'],'VariableName');
        evalin('base',['clear ',variable]);
        return
    end

    MaskObjects=Simulink.Mask.get(Block);
    OutputList=MaskObjects.getDialogControl('OutputList');

    if nargin==0
        offset=0;
    else
        offset=varargin{1};
    end

    NumberOfSignals=length(eval(get_param(Block,'sel')));
    SignalNames=OutputList.TypeOptions;

    if isempty(SignalNames)
        return
    end

    Hauteur=[250,350,500,600,500,500,600,600];
    Largeur=[400,400,400,400,700,700,700,700];
    H=Hauteur(min([8,NumberOfSignals]));
    L=Largeur(min([8,NumberOfSignals]));
    Lignes=min([4,NumberOfSignals]);
    Variable=get_param([Block,'/StoreData/To Workspace'],'VariableName');
    Mesurages=evalin('base',Variable,'[]');

    if isempty(Mesurages)
        return
    end

    if NumberOfSignals-offset<=8
        evalin('base',['clear ',Variable]);
    end

    if NumberOfSignals>4&NumberOfSignals<7
        Lignes=3;
    end


    fg=get(0,'Children');

    Colonnes=max([1,(NumberOfSignals>4)+1]);
    FigHandle=figure(...
    'Units','pixel',...
    'Position',[100+offset*5,75,L,H],...
    'Name',['Simulation result for : ',get_param(gcbh,'Name')],...
    'UserData',gcbh,...
    'NumberTitle','off',...
    'IntegerHandle','off',...
    'DeleteFcn','');

    for i=1:min([8,NumberOfSignals-offset])
        signal=strrep(SignalNames{i+offset},'_',' ');
        ud{i}.XYAxes=subplot(Lignes,Colonnes,i);

        ud{i}.XYLine=plot(1,0);
        ud{i}.XYXlabel=xlabel('');
        ud{i}.XYYlabel=ylabel('');
        ud{i}.XYTitle=title(signal);
        ud{i}.XData=Mesurages.time;
        ud{i}.YData=Mesurages.signals.values(:,i+offset);
        XDataMax=max(ud{i}.XData);
        YDataMax=max(abs(ud{i}.YData));
        if YDataMax==0||isempty(YDataMax);
            YDataMax=1;
        end
        set(ud{i}.XYAxes,'Xlim',[0,XDataMax],'Ylim',[-YDataMax-.1*YDataMax,YDataMax+.1*YDataMax]);
        set(ud{i}.XYLine,'Xdata',ud{i}.XData,'Ydata',ud{i}.YData,'LineStyle','-');
    end

    if NumberOfSignals-offset>8
        psbsignals(8+offset);
    end