function waveformDB=plotCadenceExpressions()



    adeMgr=evalin('base','adeInfo.loadResult');

    rdb=adeMgr.adeRDB;
    resultsFolder=rdb.rawDir+"/psf";
    resultsTable=rdb.query();
    adeHistory=adeMgr.adeHistory;
    testName=rdb.tests.Test;
    sessionName=adeMgr.adeSession;
    outputTable=getOutputTable(adeHistory,sessionName);
    nCorners=numel(unique(resultsTable.Corner));

    for ti=1:numel(testName)


        waveTable=findWaveTable(testName(ti),resultsTable,outputTable);
        if~(isempty(waveTable))
            [exprcsvStruct,waveTable]=createEvalExprSkill(string(testName(ti)),waveTable,resultsFolder);



            waveformDBtest=findWaveformDB(exprcsvStruct,waveTable);


            waveformDBtest=movevars(waveformDBtest,'Output','After',width(waveformDBtest));
            waveformDBtest=movevars(waveformDBtest,'WaveType','After',width(waveformDBtest)-1);
            waveformDBtest=movevars(waveformDBtest,'xscale','After','xlabel');
            waveformDBtest=movevars(waveformDBtest,'yscale','After','ylabel');
            waveformDBtest=movevars(waveformDBtest,'type','After','yscale');
            waveformDBtest.TestName(:,1)=testName(ti);
            if(exist('waveformDB','var'))

                waveformDB=[waveformDB;waveformDBtest];
            else
                waveformDB=waveformDBtest;
            end
        else
            waveformDB=struct([]);
            waveformDB=struct2table(waveformDB);

        end
    end




    waveformDB=table2struct(waveformDB);
end

function waveTable=findWaveTable(testName,resultsTable,outputTable)

    resultsTableTest=resultsTable(strcmp(resultsTable.Test,testName),:);

    cadenceExpressions=unique(resultsTableTest(strcmp(resultsTableTest.Result,'wave'),:).Output);

    exprTable=outputTable(strcmp(outputTable.Test,testName)&strcmp(outputTable.Type,'expr'),:);

    if nnz(ismissing(exprTable.Name))~=height(exprTable)

        waveTable1=exprTable(matches(exprTable.Name,cadenceExpressions)|matches(exprTable.Output,cadenceExpressions),:);

        waveTable1(~ismember(waveTable1.Name,cadenceExpressions),:).Name=cadenceExpressions(~ismember(cadenceExpressions,waveTable1.Name));


        [~,ind]=ismember(cadenceExpressions,waveTable1.Name);
        waveTable=waveTable1(ind,:);


    else
        waveTable1=exprTable(matches(exprTable.Output,cadenceExpressions),:);
        waveTable1.Name=strings(height(waveTable1),1);

        waveTable1(~ismember(waveTable1.Name,cadenceExpressions),:).Name=cadenceExpressions(~ismember(cadenceExpressions,waveTable1.Name));


        [~,ind]=ismember(cadenceExpressions,waveTable1.Name);
        waveTable=waveTable1(ind,:);

    end



end

function outputTable=getOutputTable(historyName,adeSessionName)





    import cadence.utils.*




    view=skill('t','axlGetSessionViewName','t',adeSessionName);
    cell=skill('t','axlGetSessionCellName','t',adeSessionName);
    library=skill('t','axlGetSessionLibName','t',adeSessionName);

    sessionName=skill('t','maeOpenSetup','t',library,'t',cell,...
    't',view,...
    's','?histName','t',historyName,'s','?mode','t','r');

    csvFileName=[tempname,'.csv'];

    skill('t','axlOutputsExportToFile','t',sessionName,'t',char(csvFileName));
    pause(0.1);

    outputTable=readtable(csvFileName,'format','auto','VariableNamingRule','preserve','Delimiter',',');


    delete(csvFileName);
end

function[exprcsvStruct,exprTable]=createEvalExprSkill(testName,exprTable,resultsFolder)



    import cadence.utils.*


    fileName=[tempname,'.il'];
    fid=fopen(fileName,'w');


    fprintf(fid,"\n(defun getUnitsAndSweeps (wsq)");
    fprintf(fid,"\ndim = drWaveformGetDimension(wsq) \nreturnList = '()");
    fprintf(fid,"\nfor(x 1 dim-1 ;sweep for 1 less than dim");
    fprintf(fid,"\nsweepName = famGetSweepName(wsq)");
    fprintf(fid,"\nreturnList = append(returnList list(sweepName))");
    fprintf(fid,"\nsweepValue = car(famGetSweepValues(wsq))");
    fprintf(fid,"\nwsq = famValue(wsq sweepValue)");
    fprintf(fid,"\nxUnits = getq(drGetWaveformXVec(wsq) units)");
    fprintf(fid,"\nyUnits = getq(drGetWaveformYVec(wsq) units)");
    fprintf(fid,"\nxlabel = getq(drGetWaveformXVec(wsq) name)");
    fprintf(fid,"\nylabel = getq(drGetWaveformYVec(wsq) name)\n)");
    fprintf(fid,"\nunitsAndSweeps = append(list(xUnits xlabel yUnits ylabel) returnList)\n)");




    fprintf(fid,"\nopenResults("+'"'+char(resultsFolder)+"/"+char(testName)+'/psf")');

    numExpr=height(exprTable);


    for li=1:numExpr


        expressionName=string(exprTable.Name(li));








        exprcsvStruct(li).exprName=expressionName;
        expression4rmTable=exprTable.Output(li);
        exprcsvStruct(li).expression=expression4rmTable;
        exprcsvStruct(li).fileName=tempname;

        fprintf(fid,"\nmyWave="+expression4rmTable);

        fprintf(fid,"\nawvSaveToCSV(myWave "+'"'+string(exprcsvStruct(li).fileName)+'.csv")');
        fprintf(fid,"\nunitsAndSweeps = getUnitsAndSweeps(myWave)");



        fprintf(fid,"\nmyPort = outfile("""+string(exprcsvStruct(li).fileName)+"_US.csv"+'" "w")');
        fprintf(fid,"\nfprintf(myPort ""%%A"" unitsAndSweeps)");
        fprintf(fid,"\nclose(myPort)\n");
    end
    fclose(fid);

    pause(0.1);
    skill('t','load','t',char(fileName));

    pause(0.1);
    delete(char(fileName));

end

function waveformDBtable=findWaveformDB(exprcsvStruct,expressionTable)

    ci=1;
    nExpr=numel(exprcsvStruct);
    for iexpr=1:nExpr

        waveformDB=findWaveDbRows(exprcsvStruct(iexpr),expressionTable);

        if ci>1
            waveformDBtable=[waveformDBtable;waveformDB];
        else
            waveformDBtable=waveformDB;
        end
        ci=ci+1;
    end


end

function waveformDB=findWaveDbRows(exprcsvStruct,expressionTable)



    expressionName=exprcsvStruct.exprName;

    expression=exprcsvStruct.expression;
    csvFileName=exprcsvStruct.fileName;





    warning('OFF','MATLAB:table:ModifiedAndSavedVarnames');


    waveDb=readtable(csvFileName+".csv",'ReadVariableNames',false);



    fid=fopen(csvFileName+".csv");
    tline=fgetl(fid);

    if contains(tline,"ReImag")
        hsplit=split(tline,[" X,"," YRe,"," YReImag,",' X",',' YRe",',' YReImag",']);
        complexFlag=1;
        incrHeader=3;
    else
        hsplit=split(tline,[" X,"," Y,",' X",',' Y",']);
        complexFlag=0;
        incrHeader=2;
    end
    waveDb.Properties.VariableDescriptions=hsplit;

    unitsAndSweepsList=fileread(csvFileName+"_US.csv");


    unitsAndSweepsList=strip(unitsAndSweepsList,'(');
    unitsAndSweepsList=strip(unitsAndSweepsList,')');
    unitsAndSweepsSplit=split(unitsAndSweepsList,' ');
    nl=numel(unitsAndSweepsSplit);
    unitsAndSweeps=cell(1,nl);
    for fi=1:nl
        field=char(unitsAndSweepsSplit(fi));
        unitsAndSweeps{fi}=strip(field,'"');
    end

    waveHeaders=waveDb.Properties.VariableDescriptions;
    nh=numel(waveHeaders);
    nSweeps=numel(unitsAndSweeps)-4;


    headerNames={'x','xunit','xlabel','xscale','y','yunit','ylabel','yscale','type','WaveType',char(expressionName)};
    for si=1:nSweeps
        headerNames{end+1}=char(unitsAndSweeps(4+si));
    end


    ri=1;




    for hi=1:incrHeader:(nh-1)
        splitHeader=strsplit(char(waveHeaders(hi)),' ');

        if numel(splitHeader)<nSweeps
            splitHeader=split(waveHeaders(hi),[" ","=",",",")","("]);

        elseif(nnz(contains(splitHeader,'='))>0)
            splitHeader=split(waveHeaders(hi),[" ","=",",",")","("]);
        end
        waveformStruct(ri).x=waveDb{:,hi};
        waveformStruct(ri).xunit=unitsAndSweeps(1);
        xlabel=unitsAndSweeps(2);
        waveformStruct(ri).xlabel=formatLabel(xlabel,waveformStruct(ri).xunit);
        if complexFlag==1
            waveformStruct(ri).y=complex(waveDb{:,hi+1},waveDb{:,hi+2});
        else
            waveformStruct(ri).y=waveDb{:,hi+1};
        end
        waveformStruct(ri).yunit=unitsAndSweeps(3);
        ylabel=unitsAndSweeps(4);

        waveformStruct(ri).ylabel=formatLabel(ylabel,waveformStruct(ri).yunit);
        for si=1:nSweeps

            searchFieldName=unitsAndSweeps(4+si);

            if contains(searchFieldName,'.')
                structFieldName=strrep(searchFieldName,'.','_');
            elseif contains(searchFieldName,'/')
                structFieldName=strrep(searchFieldName,'/','_');
            else
                structFieldName=searchFieldName;
            end

            headIndex=find(contains(splitHeader,searchFieldName));



            sweepValue=splitHeader(headIndex(end)+1);




            if~(sum(isstrprop(sweepValue{1},'alpha'))>1)
                sweepValue=str2double(sweepValue);
            else
                sweepValue=strip(sweepValue,'"');
            end


            waveformStruct(ri).(char(structFieldName))=sweepValue;
        end
        ri=ri+1;
    end
    waveformDB=struct2table(waveformStruct,'AsArray',true);
    if(complexFlag==1)||(contains(unitsAndSweeps(2),'freq'))
        waveformDB.xscale(:,1)=cellstr('log');
        waveformDB.yscale(:,1)=cellstr('log');
    else
        waveformDB.xscale(:,1)=cellstr('linear');
        waveformDB.yscale(:,1)=cellstr('linear');
    end

    [rtype,WaveType]=findResultWaveType(string(expression),waveformDB.ylabel(1,1));
    waveformDB.type(:,1)=cellstr(rtype);
    waveformDB.WaveType(:,1)=cellstr(WaveType);
    waveformDB.Output(:,1)=cellstr(expressionName);

    delete(csvFileName+"_US.csv");
    delete(csvFileName+".csv");
end

function fmtLabel=formatLabel(label,unit)
    if label=="nil"
        label={''};
    end
    fmtLabel=cellstr([label{1},'(',unit{1},')']);
end

function[resultType,waveType]=findResultWaveType(expression,ylabel)


    if contains(expression,"VT",'Ignorecase',true)
        resultType='tran';
        waveType='VT';

    elseif contains(expression,"IT",'Ignorecase',true)
        resultType='tran';
        waveType='IT';

    elseif contains(expression,"VS",'Ignorecase',true)
        resultType='dc';
        waveType='VS';

    elseif contains(expression,"IS",'Ignorecase',true)
        resultType='dc';
        waveType='IS';

    elseif contains(expression,"VF",'Ignorecase',true)
        resultType='ac';
        waveType='VF';

    elseif contains(expression,"IF",'Ignorecase',true)
        resultType='ac';
        waveType='IF';

    elseif contains(expression,"result")
        exprsplit=strsplit(expression);
        idx=find(contains(exprsplit,"result"));
        resultType=exprsplit(idx(1)+1);

        if contains(resultType,"tran",'Ignorecase',true)
            resultType='tran';

            if contains(ylabel,'I')
                waveType='IT';
            else
                waveType='VT';
            end
        elseif contains(resultType,"DC",'Ignorecase',true)
            resultType='dc';
            if contains(ylabel,'I')
                waveType='IS';
            else
                waveType='VS';
            end
        elseif contains(resultType,"AC",'Ignorecase',true)
            resultType='ac';
            if contains(ylabel,'I')
                waveType='IF';
            else
                waveType='VF';
            end
        elseif contains(resultType,"stb",'Ignorecase',true)
            resultType='stb';
            if contains(ylabel,'I')
                waveType='IF';
            else
                waveType='VF';
            end
        end

    else
        resultType='Unknown';
        waveType='Unknown';
    end





























end













































































































































































