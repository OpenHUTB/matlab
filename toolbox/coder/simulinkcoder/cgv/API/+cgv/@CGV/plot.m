




















function[names,figures]=plot(dataSet,varargin)

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    names={};
    figures={};


    narginchk(1,3);

    p=inputParser;
    p.FunctionName='plot';
    p.addParameter('signals',[],@(x)iscellstr(x));



    p.parse(varargin{:});







    sdie=Simulink.sdi.Instance.engine;

    srcName=inputname(1);
    if isempty(srcName)
        DAStudio.error('RTW:cgv:ComplexName','','plot','');
    end
    if~Simulink.sdi.internal.Util.IsSDISupportedType(dataSet)
        DAStudio.error('RTW:cgv:UnsupportedDataType',srcName);
    end


    Run1ID=sdie.createRunFromNamesAndValues('Run 1',{srcName},{dataSet});

    if~isempty(p.Results.signals)
        for i=1:length(p.Results.signals)
            try
                DataObj=sdie.getSignal(p.Results.signals{i});
                if(DataObj.RunID~=Run1ID)
                    DAStudio.warning('RTW:cgv:SignalNameNotPresent',p.Results.signals{i});
                    continue;
                end
            catch
                DAStudio.warning('RTW:cgv:SignalNameNotPresent',p.Results.signals{i});
                continue;
            end


            names{end+1}=DataObj.DataSource;%#ok<AGROW>
            figures{end+1}=doPlot(DataObj,sdie);%#ok<AGROW>
        end
    else
        for i=1:sdie.getSignalCount(Run1ID)
            DataObj=sdie.getSignal(Run1ID,i);
            names{end+1}=DataObj.DataSource;%#ok<AGROW>
            figures{end+1}=doPlot(DataObj,sdie);%#ok<AGROW>
        end
    end

    function fh=doPlot(DataObj,sdie)

        lowerLeftX=20;
        lowerLeftY=50;

        lName=DataObj.DataSource;
        imageTitle=lName;
        fh=figure('Name',imageTitle,'OuterPosition',[lowerLeftX,lowerLeftY,800,600]);

        sh1=subplot(1,1,1);

        plotObject=Simulink.sdi.internal.Plot(sdie);
        plotObject.clearPlot();




        axisMin=real(min(double(DataObj.DataValues.Data)));
        axisMax=real(max(double(DataObj.DataValues.Data)));
        scaleAxes(sh1,axisMin,axisMax,'YLim',10);
        axisMin=real(min(double(DataObj.DataValues.Time)));
        axisMax=real(max(double(DataObj.DataValues.Time)));
        scaleAxes(sh1,axisMin,axisMax,'XLim',3);

        DataObj.LineDashed='-';
        DataObj.LineColor=[0,0,.9];
        plotObject.plotSignals(sh1,DataObj);

        signalLabel=DAStudio.message('RTW:cgv:SignalPlot');
        title(sh1,signalLabel);


        legend(sh1,lName);


        function scaleAxes(hndl,axisMin,axisMax,which,percent)
            axisDelta=abs(axisMax-axisMin);
            if axisDelta==0
                axisDelta=10;
            end
            axisLower=axisMin-(axisDelta*percent/100);
            axisUpper=axisMax+(axisDelta*percent/100);
            mode=[which,'Mode'];
            set(hndl,mode,'manual',which,[axisLower,axisUpper]);
