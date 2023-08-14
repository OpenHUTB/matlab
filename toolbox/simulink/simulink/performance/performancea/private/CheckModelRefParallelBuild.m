function[ResultDescription,ResultDetails]=CheckModelRefParallelBuild(system)






    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckModelRefParallelBuild');

    inputParams=mdladvObj.getInputParameters(currentCheck.getID);
    quickEstimation=inputParams{1}.value;
    overhead=inputParams{2}.value;


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});
    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckModelRefParallelBuildTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);


    resultLevel=0;


    workDir=mdladvObj.getWorkDir;

    if Pass
        try


            isSimulation=false;
            [buildTime,maxNumWorkers,~,~,~]=slprivate('estimateParBuildTime',model,str2double(overhead),quickEstimation,isSimulation);

            buildTime=buildTime';
            if isequal(buildTime,0)
                numModelrefsNeedBuild=0;
            else
                numModelrefsNeedBuild=length(buildTime);
            end
            numLocalCores=feature('numcores');

        catch me

            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(1);
            mdladvObj.setActionEnable(false);

            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,me.message,me.cause);
            return;
        end



        Pass=false;

        if numModelrefsNeedBuild<2
            resultLevel=3;
            Pass=true;
            result_text=ModelAdvisor.Text([Passed.emitHTML]);
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak]);
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NoParallelNeeded'));
            result_paragraph.addItem(result_text);
        else







            table=cell(4,4);

            table{1,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelControl');
            table{2,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PoolSize');
            table{3,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PCTLicense');
            table{4,2}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NoCores');


            optNumWorkers=findOptimalNumWorkers(buildTime,maxNumWorkers);


            numCoresOfThisMachine=feature('numcores');



            license('test','Distrib_Computing_Toolbox','enable');

            parallelToolBoxLicense=PCTInstalled&&PCTLicensed;


            if(parallelToolBoxLicense)
                try
                    parPool=gcp('nocreate');
                    if isempty(parPool)
                        parPoolSize=1;
                    else
                        parPoolSize=parPool.NumWorkers;
                    end
                catch
                    parPoolSize=1;
                end
            else
                parPoolSize=1;
            end


            parallelBuildControl=get_param(model,'EnableParallelModelReferenceBuilds');
            parallelBuildIsOn=strcmp(parallelBuildControl,'on');


            parPoolIsOpen=parPoolSize>1;


            license('test','Distrib_Computing_Toolbox','enable');
            parallelToolBoxLicense=license('test','Distrib_Computing_Toolbox');





            MDCSLicense=true;


            machineHasEnoughCore=numCoresOfThisMachine>=optNumWorkers;


            parPoolSizeIsEnough=parPoolSize>=optNumWorkers;




            if parallelBuildIsOn
                table{1,3}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:on');
                table{1,1}=utilGetStatusImgLink(1);
            else
                table{1,3}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:off');
                table{1,1}=utilGetStatusImgLink(-1);
            end

            table{2,3}=num2str(parPoolSize);
            if parPoolIsOpen
                table{2,1}=utilGetStatusImgLink(1);
            else
                table{2,1}=utilGetStatusImgLink(-1);
            end

            if(parallelToolBoxLicense)
                table{3,3}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PCTLicenseInstalled');
                table{3,1}=utilGetStatusImgLink(1);
            else
                table{3,3}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PCTLicenseNotInstalled');
                table{3,1}=utilGetStatusImgLink(-1);
            end

            table{4,3}=num2str(numCoresOfThisMachine);
            if numCoresOfThisMachine>=2
                table{4,1}=utilGetStatusImgLink(1);
            else
                table{4,1}=utilGetStatusImgLink(-1);
            end



            for i=1:4
                table{i,4}=table{i,3};
            end





            useParallelToolBox=(optNumWorkers<=numCoresOfThisMachine);

            msg=[];
            if(useParallelToolBox)

                if(parallelBuildIsOn&&parallelToolBoxLicense&&machineHasEnoughCore&&parPoolSizeIsEnough)
                    resultLevel=2;
                    msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg1');
                    table{2,4}=strcat('>=',num2str(optNumWorkers));
                    table{4,4}=strcat('>=',num2str(optNumWorkers));
                end
            else

                if parallelBuildIsOn&&MDCSLicense&&parPoolSizeIsEnough
                    resultLevel=2;
                    msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg2');
                    table{2,4}=strcat('>=',num2str(optNumWorkers));
                end
            end

            if(resultLevel==2)
                Pass=true;
                result_text=ModelAdvisor.Text([Passed.emitHTML]);
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak]);
                result_text=ModelAdvisor.Text(msg);
                result_paragraph.addItem(result_text);
            end


            n=1;
            if(resultLevel~=2)
                if(useParallelToolBox)
                    if(parallelBuildIsOn&&parallelToolBoxLicense)
                        if(~machineHasEnoughCore&&parPoolIsOpen)
                            resultLevel=1;
                            msg{n}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg3',num2str(optNumWorkers));
                            table{4,4}=strcat('>=',num2str(optNumWorkers));
                            table{4,1}=utilGetStatusImgLink(0);

                            n=n+1;
                        end

                        if(~parPoolSizeIsEnough&&parPoolIsOpen)
                            Pass=true;
                            resultLevel=1;
                            msg{n}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg4',num2str(optNumWorkers));
                            table{2,4}=strcat('>=',num2str(optNumWorkers));
                            table{2,1}=utilGetStatusImgLink(0);

                        end
                    end
                else
                    if parallelBuildIsOn&&MDCSLicense
                        if(~parPoolSizeIsEnough&&parPoolIsOpen)
                            resultLevel=1;
                            msg{n}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg5',num2str(optNumWorkers));
                            table{2,4}=strcat('>=',num2str(parPoolSize));
                            table{2,1}=utilGetStatusImgLink(0);
                        end
                    end
                end
            end

            if(resultLevel==1)
                Pass=true;
                n=length(msg);

                result_text=ModelAdvisor.Text([Warned.emitHTML]);
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

                for i=1:n
                    result_text=ModelAdvisor.Text(msg{i});
                    result_paragraph.addItem(result_text);
                    result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
                end
            end


            n=1;
            if(resultLevel==0)

                Pass=false;
                if~parallelBuildIsOn
                    msg{n}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg6');

                    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:on'));
                    link=utilCreateConfigSetHref(model,'EnableParallelModelReferenceBuilds');
                    text.setHyperlink(link);
                    table{1,4}=text;
                    table{1,1}=utilGetStatusImgLink(-1);
                    n=n+1;
                end

                if~parPoolIsOpen
                    msg{n}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg7');
                    table{2,4}='>=2';
                    table{2,1}=utilGetStatusImgLink(-1);
                    n=n+1;
                end

                if~parallelToolBoxLicense
                    msg{n}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg8');
                    table{3,4}=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg9');
                    table{3,1}=utilGetStatusImgLink(-1);
                end

                n=length(msg);
                result_text=ModelAdvisor.Text([Failed.emitHTML]);
                result_paragraph.addItem(result_text);

                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg10'));
                result_paragraph.addItem(result_text);

                result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

                for i=1:n
                    result_text=ModelAdvisor.Text(strcat(num2str(i),') ',msg{i}));
                    result_paragraph.addItem(result_text);
                    result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
                end

            end

            tableName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:MdlRefTabName');

            h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Severity');
            h2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Requirements');
            h3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActualValue');
            h4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedValue');

            heading={h1,h2,h3,h4};

            t3=utilDrawReportTable(table,tableName,{},heading);

            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg11'));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

            result_paragraph.addItem(t3.emitHTML);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        end

        if resultLevel>=2

            mdladvObj.setCheckResultStatus(true);
        else
            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(1-resultLevel);
        end



        if resultLevel<2



            advice=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg12'),{'bold','pass'});

            result_paragraph.addItem(advice);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);




            if resultLevel==0
                actBuildTime=buildTime(1,1);
            elseif resultLevel==1
                if useParallelToolBox
                    actBuildTime=buildTime(min(numCoresOfThisMachine,parPoolSize),1);
                else
                    actBuildTime=buildTime(parPoolSize,1);
                end
            end

            if(numCoresOfThisMachine<=maxNumWorkers)
                estBuildTime=buildTime(numCoresOfThisMachine,1);
                speedUp=actBuildTime/estBuildTime;

                speedUpStr=ModelAdvisor.Text(strcat('-- ',num2str(speedUp),'x'),{'bold','pass'});
                result_text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg13',num2str(numCoresOfThisMachine),speedUpStr.emitHTML);
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak]);


                estBuildTime=buildTime(maxNumWorkers,1);
                speedUp=actBuildTime/estBuildTime;
                speedUpStr=ModelAdvisor.Text(strcat('-- ',num2str(speedUp),'x'),{'bold','pass'});
                result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg14',num2str(maxNumWorkers),speedUpStr.emitHTML));
                result_paragraph.addItem(result_text);
                result_paragraph.addItem([ModelAdvisor.LineBreak]);
            end

        end

        if resultLevel<3
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelMsg15'));
            result_paragraph.addItem(result_text);
            result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

            fileName=createBarChart(maxNumWorkers,buildTime,numLocalCores,workDir);
            dataStr=cellfun(@num2str,num2cell(buildTime),'UniformOutput',false);
            imgstr=strcat(' <img src =','" ','file:///',fileName,'"','/>',...
            '<!--','buildTime@',strjoin(dataStr,':'),'-->');...
            result_text1=ModelAdvisor.Text(imgstr);
            result_paragraph.addItem(result_text1);













        end

    end

    ResultDescription{end+1}=result_paragraph;

    ResultDetails{end+1}='';


    if Pass
        baseLineAfter.time=baseLineBefore.time;
        baseLineAfter.check.passed='y';
    else
        baseLineAfter=utilGetBaselineAfter(mdladvObj,model,currentCheck);
        baseLineAfter.check.passed='n';
    end
    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);

end



function filePath=createBarChart(maxNumWorkers,buildTime,numLocalCores,workDir)


    speedFactor=buildTime(1,1)./buildTime(:,1);

    f=figure('visible','off');
    set(f,'color',[1,1,1]);

    CoresArraySize=maxNumWorkers;



    color_PCT='blue';
    color_MDCS='cyan';

    color_LOCALCPU='red';









    bar(speedFactor(1:CoresArraySize,1),'FaceColor',color_PCT);
    l_PCT=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PCTorMDCS');
    grid;
    hold on;


    temp_localCPU=zeros(1,CoresArraySize);
    l_LOCALCPU=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ThisCPU');
    if(numLocalCores<=CoresArraySize)
        temp_localCPU(numLocalCores)=speedFactor(numLocalCores,1);
    end
    bar(temp_localCPU,'FaceColor',color_LOCALCPU);
    hold on


    temp_MDCS=zeros(1,CoresArraySize);
    l_MDCS=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RequiresMDCS');
    if(numLocalCores<CoresArraySize)
        temp_MDCS(numLocalCores+1:CoresArraySize)=speedFactor(numLocalCores+1:CoresArraySize,1);
    end
    bar(temp_MDCS,'FaceColor',color_MDCS);

    lgnd=legend(l_PCT,l_LOCALCPU,l_MDCS);
    set(lgnd,'color','none');
    legend boxoff;



    TopTitle=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelChartTopTitle');
    SubTitle=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelChartSubTitle',floor(buildTime(1,1)));
    title({TopTitle,SubTitle},'Interpreter','none');
    xlabel(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelChartXLabel'));
    ylabel(DAStudio.message('SimulinkPerformanceAdvisor:advisor:ParallelChartYLabel'));

    posf=get(f,'Position');
    ax=gca;
    posa=get(ax,'Position');
    posl=get(lgnd,'Position');

    set(f,'Position',[posf(1),posf(2),posf(3),posf(4)+40]);
    set(ax,'Position',[posa(1),posa(2)+40/posf(4),posa(3),posa(4)-40/posf(4)]);
    set(lgnd,'Position',[posa(1),posa(2)-50/posf(4),posl(3),posl(4)]);

    fileName=fullfile(workDir,'bar.jpg');

    scrpos=get(f,'Position');
    newpos=scrpos/90;
    set(f,'PaperUnits','inches','PaperPosition',newpos);
    print(f,'-djpeg',fileName,'-r100');





    filePath=strcat(fileName);

    close(f);
end


function optNumWorkers=findOptimalNumWorkers(buildTime,maxNumWorkers)


    optNumWorkers=maxNumWorkers;
    for k=maxNumWorkers:-1:2
        if((buildTime(k-1,1)-buildTime(k,1))/buildTime(k-1,1))>0.1

            optNumWorkers=k;
            break;
        end
    end

end







function OK=PCTInstalled
    persistent PCT_INSTALLED
    if isempty(PCT_INSTALLED)
        PCT_INSTALLED=matlab.internal.parallel.isPCTInstalled();
    end
    OK=PCT_INSTALLED;
end

function OK=PCTLicensed



    OK=matlab.internal.parallel.isPCTLicensed();
end





