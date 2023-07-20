
































function[matchNames,matchFigures,mismatchNames,mismatchFigures]=compare(dataSet1,dataSet2,varargin)

    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    narginchk(2,8);
    nargoutchk(0,4);


    matchNames={};
    matchFigures={};
    mismatchNames={};
    mismatchFigures={};



    p=inputParser;
    p.FunctionName='compare';
    p.addParameter('plot','none',@(x)ischar(x)&&any(strcmpi(x,{'match','mismatch','all','none'})));
    p.addParameter('signals',[],@(x)iscellstr(x));
    p.addParameter('toleranceFile',[],@(x)ischar(x));



    p.parse(varargin{:});






    switch lower(p.Results.plot)
    case 'none'
        plotMatches=false;
        plotMismatches=false;
    case 'all'
        plotMatches=true;
        plotMismatches=true;
    case 'match'
        plotMatches=true;
        plotMismatches=false;
    case 'mismatch'
        plotMatches=false;
        plotMismatches=true;
    otherwise


        plotMatches=false;
        plotMismatches=false;
    end

    srcName1=inputname(1);
    if isempty(srcName1)
        DAStudio.error('RTW:cgv:ComplexName','1','compare','1');
    end
    srcName2=inputname(2);
    if isempty(srcName2)
        DAStudio.error('RTW:cgv:ComplexName','2','compare','2');
    end
    if~Simulink.sdi.internal.Util.IsSDISupportedType(dataSet1)
        DAStudio.error('RTW:cgv:NoSignals',srcName1);
    end
    if~Simulink.sdi.internal.Util.IsSDISupportedType(dataSet2)
        DAStudio.error('RTW:cgv:NoSignals',srcName2);
    end


    sdie=Simulink.sdi.Instance.engine;


    Run1ID=sdie.createRunFromNamesAndValues('Run 1',{srcName1},{dataSet1});
    Run2ID=sdie.createRunFromNamesAndValues('Run 2',{srcName2},{dataSet2});

    if sdie.getSignalCount(Run1ID)==0
        if isempty(srcName1)
            srcName1='dataSet1';
        else
            srcName1=['''',srcName1,''''];
        end
        DAStudio.error('RTW:cgv:NoSignals',srcName1);
    end

    if sdie.getSignalCount(Run2ID)==0
        if isempty(srcName2)
            srcName2='dataSet2';
        else
            srcName2=['''',srcName2,''''];
        end
        DAStudio.error('RTW:cgv:NoSignals',srcName2);
    end

    if~isempty(p.Results.signals)
        list1=cgv.CGV.dataSrcsList(sdie,Run1ID);
        list2=cgv.CGV.dataSrcsList(sdie,Run2ID);
        fullList=[list1,list2];
        for i=1:length(p.Results.signals)
            if~ismember(p.Results.signals{i},fullList)
                DAStudio.warning('RTW:cgv:SignalNameNotPresent',p.Results.signals{i});
            end
        end
    end

    if~isempty(p.Results.toleranceFile)
        try
            sdie.restoreTolerances(Run1ID,p.Results.toleranceFile);
        catch ME
            newExc=MException('RTW:cgv:InvalidToleranceFile','%s',...
            DAStudio.message('RTW:cgv:InvalidToleranceFile',fullfile(p.Results.toleranceFile)));
            throw(newExc);
        end
    end




    compRunID=Simulink.sdi.internal.compareRunsWithTolerance(sdie.sigRepository,Run1ID,Run2ID);
    sdie.setDiffRunResult(compRunID);

    count=sdie.DiffRunResult.count;
    for i=1:count
        DiffObj=sdie.DiffRunResult.getResultByIndex(i);



        if isempty(DiffObj.signal1Obj)||isempty(DiffObj.signal2Obj)
            continue;
        end


        if~isempty(p.Results.signals)&&...
            ~any(strcmp(DiffObj.signal1Obj.DataSource,p.Results.signals))&&...
            ~any(strcmp(DiffObj.signal2Obj.DataSource,p.Results.signals))
            continue;
        end
        DiffObj.signal1Obj.LineDashed='-';
        DiffObj.signal1Obj.LineColor=[0,0,.9];
        if~isempty(DiffObj.signal2Obj)
            DiffObj.signal2Obj.LineDashed='-';

            rgb=[175,115,0];
            divisor=[256,256,256];
            fraction=bsxfun(@rdivide,rgb,divisor);
            DiffObj.signal2Obj.LineColor=fraction;
        end
        if(DiffObj.Match)
            matchNames{end+1}=DiffObj.signal1Obj.DataSource;%#ok<AGROW>
            if plotMatches
                matchFigures{end+1}=doPlot(DiffObj,sdie);%#ok<AGROW>
            end
        else
            mismatchNames{end+1}=DiffObj.signal1Obj.DataSource;%#ok<AGROW>
            if plotMismatches
                mismatchFigures{end+1}=doPlot(DiffObj,sdie);%#ok<AGROW>
            end
        end
    end

    function fh=doPlot(DiffObj,sdie)

        lowerLeftX=20;
        lowerLeftY=50;

        lName=DiffObj.signal1Obj.DataSource;
        if DiffObj.Match==0
            rName=DiffObj.signal2Obj.DataSource;
            imageTitle=[lName,', ',rName];
        else
            imageTitle=lName;
        end
        fh=figure('Name',imageTitle,'OuterPosition',[lowerLeftX,lowerLeftY,800,600]);

        signals2PlotList(1)=DiffObj.signal1Obj;
        if DiffObj.Match==0
            sh1=subplot(3,1,[1,2]);
            sh2=subplot(3,1,3);
            signals2PlotList(end+1)=DiffObj.signal2Obj;
        else
            sh1=subplot(1,1,1);
        end

        plotObject=Simulink.sdi.internal.Plot(sdie);
        plotObject.clearPlot();

        axisMin=min(double([DiffObj.signal1Obj.DataValues.Data',DiffObj.signal2Obj.DataValues.Data']));
        axisMax=max(double([DiffObj.signal1Obj.DataValues.Data',DiffObj.signal2Obj.DataValues.Data']));
        scaleAxes(sh1,axisMin,axisMax,'YLim',10);

        plotObject.plotSignals(sh1,signals2PlotList);

        signalLabel=DAStudio.message('RTW:cgv:SignalPlot');
        title(sh1,signalLabel);


        sig1='sig1';
        if DiffObj.Match==0
            sig2='sig2';
            legend(sh1,[sig1,': ',lName],[sig2,': ',rName]);
            axisMin=min(DiffObj.Diff.Time);
            axisMax=max(DiffObj.Diff.Time);
        else
            legend(sh1,lName);
            axisMin=min(DiffObj.signal1Obj.DataValues.Time);
            axisMax=max(DiffObj.signal1Obj.DataValues.Time);
        end

        scaleAxes(sh1,axisMin,axisMax,'XLim',3);

        if DiffObj.Match==0


            plotObject.plotDiff(sh2,DiffObj.Diff,DiffObj.Tol);



            scaleAxes(sh2,axisMin,axisMax,'XLim',3);

            absData=[abs(DiffObj.Diff.Data)',DiffObj.Tol.Data'];
            axisMin=min(absData);
            axisMax=max(absData);
            scaleAxes(sh2,axisMin,axisMax,'YLim',10);


            differenceLabel=DAStudio.message('RTW:cgv:NumericDifference');
            title(sh2,differenceLabel);

            legend(sh2,['abs(',sig1,' - ',sig2,')'],DAStudio.message('RTW:cgv:AppliedTolerance'));

        end

        function scaleAxes(hndl,axisMin,axisMax,which,percent)
            axisDelta=abs(axisMax-axisMin);
            if axisDelta==0
                axisDelta=10;
            end
            axisLower=axisMin-(axisDelta*percent/100);
            axisUpper=axisMax+(axisDelta*percent/100);
            mode=[which,'Mode'];
            set(hndl,mode,'manual',which,[axisLower,axisUpper]);
