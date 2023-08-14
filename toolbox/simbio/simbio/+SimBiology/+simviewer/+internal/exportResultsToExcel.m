function exportResultsToExcel(sbioAppData)












    [fname,dname]=uiputfile(getFileFilter(),'Select Excel File to Save Results',sbioAppData.LastDirectory);

    if fname~=0
        try

            msgId='MATLAB:xlswrite:AddSheet';
            warningState=warning('QUERY',msgId);
            warning('off',msgId);

            c=onCleanup(@()warning(warningState.state,msgId));


            outputFile=fullfile(dname,fname);
            sbioAppData.LastDirectory=dname;


            prepFileForWrite(outputFile);


            if ispc
                writeSimulationData(sbioAppData,outputFile);
            end


            p=sbioAppData.Sliders;

            if~isempty(p)
                names={p.Name};
                values=[p.Value];

                writeData(outputFile,'Parameters',names,values,'A2');
            end


            d=sbioAppData.Doses;

            if~isempty(d)
                headings={'Name','Target','Time','Amount','Rate','Interval','Repeat'};
                values={};
                for i=1:length(d)
                    dose=d(i);
                    type=dose.Type;
                    if strcmp(type,'schedule')
                        [time,amount,rate]=getSchedule(dose);


                        if~isempty(time)
                            next={dose.Name,dose.Target,time{1},amount{1},rate{1},'',''};
                            values(end+1,:)=next;%#ok<*AGROW>
                        end

                        for j=2:length(time)
                            next={'','',time{j},amount{j},rate{j},'',''};
                            values(end+1,:)=next;
                        end
                    else

                        next={dose.Name,dose.Target,dose.StartTime,dose.Amount,dose.Rate,dose.Interval,dose.Repeat};
                        values(end+1,:)=next;
                    end
                end

                writeData(outputFile,'Doses',headings,values,'A2');
            end


            s=sbioAppData.Statistics;

            if~isempty(s)
                headings={'Name','Expression','Value'};

                names={s.Name};
                expr={s.OriginalExpression};
                values=[s.Value];
                values=num2cell(values);
                data=[names',expr',values'];

                writeData(outputFile,'Statistics',headings,data,'A2');
            end


            if~ispc
                writeSimulationData(sbioAppData,outputFile);
            end


            if ispc
                cleanupExcel(outputFile);
            end



            if ispc||ismac
                SimBiology.simviewer.internal.uiController([],[],'openFile',outputFile);
            end

        catch msg
            errordlg(msg.message,'Data Export Error');
        end
    end


    function[time,amount,rate]=getSchedule(dose)

        time=dose.Time;
        amount=dose.Amount;
        rate=dose.Rate;
        maxLength=max(max(length(time),length(amount)),length(rate));

        if length(time)~=maxLength
            newTime=num2cell(zeros(1,maxLength));
            newTime(1:length(time))=num2cell(time);
            time=newTime;
        else
            time=num2cell(time);
        end

        if length(amount)~=maxLength
            newAmount=num2cell(zeros(1,maxLength));
            newAmount(1:length(amount))=num2cell(amount);
            amount=newAmount;
        else
            amount=num2cell(amount);
        end

        if length(rate)~=maxLength
            newRate=num2cell(zeros(1,maxLength));
            newRate(1:length(rate))=num2cell(rate);
            rate=newRate;
        else
            rate=num2cell(rate);
        end


        function writeData(outputFile,section,headings,value,location)

            if ispc
                xlswrite(outputFile,headings,section);
                xlswrite(outputFile,value,section,location);
            else

                if isa(value,'double')
                    value=num2cell(value);
                end
                cellVal=[headings;value];

                fid=fopen(outputFile,'a');

                if(fid==-1)
                    errorMsg=sprintf('Cannot open file: %s. Permission denied.',outputFile);
                    errordlg(errorMsg,'Cannot Open File');
                    return;
                end


                fprintf(fid,'%s\n',section);




                for i=1:size(cellVal,1)
                    for j=1:size(cellVal,2)

                        val=cellVal{i,j};
                        format='%s';
                        if isa(val,'double')
                            format='%g';
                        end
                        if j==size(cellVal,2)
                            format=[format,'\n'];
                        else
                            format=[format,','];
                        end
                        fprintf(fid,format,val);
                    end
                end


                fprintf(fid,'\n');


                fclose(fid);
            end


            function prepFileForWrite(fullfile)



                try
                    if~ispc
                        fid=fopen(fullfile,'w');
                        c=onCleanup(@()fclose(fid));
                        if(fid==-1)
                            errorMsg=sprintf('Cannot open file: %s. Permission denied.',fullfile);
                            errordlg(errorMsg,'Cannot Open File');
                            return;
                        end
                    else
                        if exist(fullfile,'file')==2
                            sbiogate('projecthandler','deleteFile',{fullfile});
                        end
                    end
                catch
                    errorMsg=sprintf('Cannot open file: %s.',fullfile);
                    errordlg(errorMsg,'Cannot Open File');
                end


                function writeSimulationData(sbioAppData,outputFile)
                    data=sbioAppData.LastDataRun;
                    [t,x,names]=getdata(data);
                    writeData(outputFile,'Data',{'Time',names{:}},[t,x],'A2');



                    function cleanupExcel(fullfile)


                        try
                            objExcel=actxserver('Excel.Application');
                        catch
                            return;
                        end


                        c=onCleanup(@()closeExcelObjs(objExcel));
                        objExcel.Workbooks.Open(fullfile);


                        try

                            [~,sheetNames]=xlsfinfo(fullfile);
                            index=find(ismember(sheetNames,'Data'));

                            for i=1:index-1

                                sheetName=sheetNames{i};
                                objExcel.ActiveWorkbook.Worksheets.Item(sheetName).Delete;
                            end
                        catch
                        end

                        objExcel.ActiveWorkbook.Save;




                        sheets=objExcel.ActiveWorkbook.Sheets;
                        sheets.Item(1).Activate;


                        function closeExcelObjs(objExcel)
                            objExcel.ActiveWorkbook.Save;
                            objExcel.ActiveWorkbook.Close;
                            objExcel.Quit;
                            objExcel.delete;


                            function out=getFileFilter()
                                if~ispc
                                    out='*.csv';
                                else
                                    out={'*.xls;*xlsx'};
                                end

