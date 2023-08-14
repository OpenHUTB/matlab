function[outputStruct,SIMetrixVoltages,SIMetrixCurrents,SIMetrixTime,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissValid,qossValid]=compareSIMetrixWithSimscape(SimscapeFile,SPICEFile,...
    subcircuitName,subcircuitDetails,test,structArrayIndex,SPICETool,SPICEPath,relTol,absTol,vnTol,absErrTol,relErrTol,file2header_IdVgstj27,file2_IdVgstj27,file3header_IdVgstj27,file3_IdVgstj27,...
    file4header_IdVgstj27,file4_IdVgstj27,file2header_IdVgstj75,file2_IdVgstj75,file3header_IdVgstj75,file3_IdVgstj75,file4header_IdVgstj75,file4_IdVgstj75,file2header_IdVds,file2_IdVds,...
    file3header_IdVds,file3_IdVds,file4header_IdVds,file4_IdVds,file2header_Qiss,file2_Qiss,file3header_Qiss,file3_Qiss,file4header_Qiss,file4_Qiss,file2header_Qoss,file2_Qoss,file3header_Qoss,file3_Qoss,file4header_Qoss,file4_Qoss,...
    file2header_Breakdown,file2_Breakdown,file3header_Breakdown,file3_Breakdown,file4header_Breakdown,file4_Breakdown)





































































    if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds))&&(isempty(file2_Qiss))&&(isempty(file2_Qoss))&&(isempty(file2_Breakdown)))

        if exist(SPICEPath,"file")
            [filepath,name,ext]=fileparts(SPICEPath);
            if strcmp(name,"Sim")&&strcmp(ext,".exe")


                SIMetrixCommand=""""+SPICEPath+""" ";
            elseif strcmp(name,"SIMetrix")&&strcmp(ext,".exe")


                SPICEPath=fullfile(filepath,"Sim.exe");
                SIMetrixCommand=""""+SPICEPath+""" ";
            else

                pm_error("physmod:ee:SPICE2sscvalidation:SPICEPathError");
                SIMetrixCommand=string.empty;
            end
        else

            pm_error("physmod:ee:SPICE2sscvalidation:SPICEPathError");
            SIMetrixCommand=string.empty;
        end


        tempDir=tempname;
        mkdir(tempDir);
        dirname=convertCharsToStrings(tempDir);
        finishup2=onCleanup(@()myCleanupFun2(dirname));
    end
    netlistFile=strings(1,length(test(structArrayIndex).stepValues));
    SIMetrixCurrents=cell(1,length(test(structArrayIndex).stepValues));
    SIMetrixVoltages=cell(1,length(test(structArrayIndex).stepValues));
    SIMetrixTime=cell(1,length(test(structArrayIndex).stepValues));
    if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvdst5")||(test(structArrayIndex).name=="idvgst6tj27")||...
        (test(structArrayIndex).name=="idvgst6tj75")||(test(structArrayIndex).name=="idvdst6")||(test(structArrayIndex).name=="idvgst3")||(test(structArrayIndex).name=="idvdst3")||...
        (test(structArrayIndex).name=="idvgst4")||(test(structArrayIndex).name=="idvdst4")



        if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
            for stepValueIndex=1:length(test(structArrayIndex).stepValues)
                netlistFile(stepValueIndex)=ee.internal.validation.mosfet.createSPICEToolNetlist(stepValueIndex,SPICETool,dirname,SPICEFile,subcircuitName,subcircuitDetails,test,structArrayIndex,...
                relTol,absTol,vnTol);
                result=system(char(SIMetrixCommand+strcat(dirname+"/"+netlistFile(stepValueIndex))));
                if result~=0
                    pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
                end
            end
        end


        for stepValueIndex=1:length(test(structArrayIndex).stepValues)
            if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
                netlistoutFile="testNetlist"+subcircuitName+"_"+stepValueIndex+".out";
                fid=fopen((dirname+"/"+netlistoutFile),"r");
                A=split(fileread((dirname+"/"+netlistoutFile)),newline);



                B=regexp(A,"Tabulated Vectors");
                linenumber=find(~cellfun(@isempty,B));
                if(isempty(linenumber))
                    pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
                end
                C=regexp(A,"Analysis statistics");
                linenumber1=find(~cellfun(@isempty,C));
                if(isempty(linenumber1))
                    pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
                end



                for lineIndex=1:linenumber(1)-1
                    fgetl(fid);
                end




                fidfile1write=fopen((dirname+"/"+"file1.txt"),"w");
                for lineIndex=1:(linenumber1-linenumber(1)-1)
                    fprintf(fidfile1write,fgetl(fid));
                    fprintf(fidfile1write,"\n");
                end




                fidfile1read=fopen((dirname+"/"+"file1.txt"),"r");
                A=split(fileread((dirname+"/"+"file1.txt")),newline);
                B=regexp(A,"^Time");
                linenumber2=find(~cellfun(@isempty,B));
                for lineIndex=1:linenumber2(1)-1
                    fgetl(fidfile1read);
                end
                fidheaderfile2write=fopen((dirname+"/"+"file2header.txt"),"w");
                fprintf(fidheaderfile2write,fgetl(fidfile1read));
                fidfile2write=fopen((dirname+"/"+"file2.txt"),"w");
                for lineIndex=1:(linenumber2(2)-linenumber2(1)-1)
                    fprintf(fidfile2write,fgetl(fidfile1read));
                    fprintf(fidfile2write,"\n");
                end
                fidheaderfile3write=fopen((dirname+"/"+"file3header.txt"),"w");
                fprintf(fidheaderfile3write,fgetl(fidfile1read));
                fidfile3write=fopen((dirname+"/"+"file3.txt"),"w");
            end
            if(test(structArrayIndex).name=="idvgst3")||(test(structArrayIndex).name=="idvdst3")||(test(structArrayIndex).name=="idvgst4")||(test(structArrayIndex).name=="idvdst4")
                while~feof(fidfile1read)
                    fprintf(fidfile3write,fgetl(fidfile1read));
                    fprintf(fidfile3write,"\n");
                end
                fidheaderfile2read=fopen((dirname+"/"+"file2header.txt"),"r");
                headerNames2=textscan(fidheaderfile2read," %s %s %s %s %s ",1,"Delimiter","\t");
                headernum2=regexp(char(headerNames2{2}),"\d+","match");
                headernum3=regexp(char(headerNames2{3}),"\d+","match");
                headernum4=regexp(char(headerNames2{4}),"\d+","match");
                headernum5=regexp(char(headerNames2{5}),"\d+","match");
                fidheaderfile3read=fopen((dirname+"/"+"file3header.txt"),"r");
                headerNames3=textscan(fidheaderfile3read," %s %s %s ",1,"Delimiter","\t");
                headernumb2=regexp(char(headerNames3{2}),"\d+","match");
                headernumb3=regexp(char(headerNames3{3}),"\d+","match");
                fclose(fid);
                fclose(fidfile1write);
                fclose(fidfile1read);
                fclose(fidfile2write);
                fclose(fidheaderfile2write);
                fclose(fidheaderfile2read);
                fclose(fidfile3write);
                fclose(fidheaderfile3write);
                fclose(fidheaderfile3read);
                file2Data=readtable((dirname+"/"+"file2.txt"),"Delimiter","\t");
                file3Data=readtable((dirname+"/"+"file3.txt"),"Delimiter","\t");
                SIMetrixVoltages{stepValueIndex}(str2double(char(headernumb3)),:)=(table2array(file3Data(:,3))).';
                SIMetrixVoltages{stepValueIndex}(str2double(char(headernumb2)),:)=(table2array(file3Data(:,2))).';
                SIMetrixVoltages{stepValueIndex}(str2double(char(headernum5)),:)=(table2array(file2Data(:,5))).';
                SIMetrixCurrents{stepValueIndex}(str2double(char(headernum4)),:)=(table2array(file2Data(:,4))).';
                SIMetrixCurrents{stepValueIndex}(str2double(char(headernum3)),:)=(table2array(file2Data(:,3))).';
                SIMetrixCurrents{stepValueIndex}(str2double(char(headernum2)),:)=(table2array(file2Data(:,2))).';
                SIMetrixTime{stepValueIndex}=(table2array(file3Data(:,1))).';
            end
            if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvdst5")||(test(structArrayIndex).name=="idvgst6tj27")||...
                (test(structArrayIndex).name=="idvgst6tj75")||(test(structArrayIndex).name=="idvdst6")
                if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
                    for lineIndex=1:(linenumber2(3)-linenumber2(2)-1)
                        fprintf(fidfile3write,fgetl(fidfile1read));
                        fprintf(fidfile3write,"\n");
                    end
                    fidheaderfile4write=fopen((dirname+"/"+"file4header.txt"),"w");
                    fprintf(fidheaderfile4write,fgetl(fidfile1read));
                    fidfile4write=fopen((dirname+"/"+"file4.txt"),"w");
                    while~feof(fidfile1read)
                        fprintf(fidfile4write,fgetl(fidfile1read));
                        fprintf(fidfile4write,"\n");
                    end
                end
                if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
                    fidheaderfile2read=fopen((dirname+"/"+"file2header.txt"),"r");
                else
                    if(test(structArrayIndex).name=="idvgst5tj27")
                        fidheaderfile2read=fopen((file2header_IdVgstj27),"r");
                    end
                    if(test(structArrayIndex).name=="idvgst5tj75")
                        fidheaderfile2read=fopen((file2header_IdVgstj75),"r");
                    end
                    if(test(structArrayIndex).name=="idvdst5")
                        fidheaderfile2read=fopen((file2header_IdVds),"r");
                    end
                end
                headerNames2=textscan(fidheaderfile2read," %s %s %s %s %s ",1,"Delimiter","\t");
                headernum2=regexp(char(headerNames2{2}),"\d+","match");
                headernum3=regexp(char(headerNames2{3}),"\d+","match");
                headernum4=regexp(char(headerNames2{4}),"\d+","match");
                headernum5=regexp(char(headerNames2{5}),"\d+","match");
                if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
                    fidheaderfile3read=fopen((dirname+"/"+"file3header.txt"),"r");
                else
                    if(test(structArrayIndex).name=="idvgst5tj27")
                        fidheaderfile3read=fopen((file3header_IdVgstj27),"r");
                    end
                    if(test(structArrayIndex).name=="idvgst5tj75")
                        fidheaderfile3read=fopen((file3header_IdVgstj75),"r");
                    end
                    if(test(structArrayIndex).name=="idvdst5")
                        fidheaderfile3read=fopen((file3header_IdVds),"r");
                    end
                end
                headerNames3=textscan(fidheaderfile3read," %s %s %s %s %s ",1,"Delimiter","\t");
                headernumb2=regexp(char(headerNames3{2}),"\d+","match");
                headernumb3=regexp(char(headerNames3{3}),"\d+","match");
                headernumb4=regexp(char(headerNames3{4}),"\d+","match");
                headernumb5=regexp(char(headerNames3{5}),"\d+","match");
                if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
                    fidheaderfile4read=fopen((dirname+"/"+"file4header.txt"),"r");
                else
                    if(test(structArrayIndex).name=="idvgst5tj27")
                        fidheaderfile4read=fopen((file4header_IdVgstj27),"r");
                    end
                    if(test(structArrayIndex).name=="idvgst5tj75")
                        fidheaderfile4read=fopen((file4header_IdVgstj75),"r");
                    end
                    if(test(structArrayIndex).name=="idvdst5")
                        fidheaderfile4read=fopen((file4header_IdVds),"r");
                    end
                end
                if(test(structArrayIndex).name=="idvgst6tj27")||(test(structArrayIndex).name=="idvgst6tj75")||(test(structArrayIndex).name=="idvdst6")
                    headerNames4=textscan(fidheaderfile4read," %s %s %s %s %s ",1,"Delimiter","\t");
                    headernumbe2=regexp(char(headerNames4{2}),"\d+","match");
                    headernumbe3=regexp(char(headerNames4{3}),"\d+","match");
                    headernumbe4=regexp(char(headerNames4{4}),"\d+","match");
                    headernumbe5=regexp(char(headerNames4{5}),"\d+","match");
                end
                if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvdst5")
                    headerNames4=textscan(fidheaderfile4read," %s %s %s ",1,"Delimiter","\t");
                    headernumbe2=regexp(char(headerNames4{2}),"\d+","match");
                    headernumbe3=regexp(char(headerNames4{3}),"\d+","match");
                end
                if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
                    fclose(fid);
                    fclose(fidfile1write);
                    fclose(fidfile1read);
                    fclose(fidfile2write);
                    fclose(fidheaderfile2write);
                    fclose(fidheaderfile2read);
                    fclose(fidfile3write);
                    fclose(fidheaderfile3write);
                    fclose(fidheaderfile3read);
                    fclose(fidfile4write);
                    fclose(fidheaderfile4write);
                    fclose(fidheaderfile4read);
                else
                    fclose(fidheaderfile2read);
                    fclose(fidheaderfile3read);
                    fclose(fidheaderfile4read);
                end
                if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds)))
                    file2Data=readtable((dirname+"/"+"file2.txt"),"Delimiter","\t");
                    file3Data=readtable((dirname+"/"+"file3.txt"),"Delimiter","\t");
                    file4Data=readtable((dirname+"/"+"file4.txt"),"Delimiter","\t");
                else
                    if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst5tj75")
                        file2Data=readtable((file2_IdVgstj27),"Delimiter","\t");
                        file3Data=readtable((file3_IdVgstj27),"Delimiter","\t");
                        file4Data=readtable((file4_IdVgstj27),"Delimiter","\t");
                    end
                    if(test(structArrayIndex).name=="idvgst5tj75")
                        file2Data=readtable((file2_IdVgstj75),"Delimiter","\t");
                        file3Data=readtable((file3_IdVgstj75),"Delimiter","\t");
                        file4Data=readtable((file4_IdVgstj75),"Delimiter","\t");
                    end
                    if(test(structArrayIndex).name=="idvdst5")
                        file2Data=readtable((file2_IdVds),"Delimiter","\t");
                        file3Data=readtable((file3_IdVds),"Delimiter","\t");
                        file4Data=readtable((file4_IdVds),"Delimiter","\t");
                    end
                end
                if(test(structArrayIndex).name=="idvgst6tj27")||(test(structArrayIndex).name=="idvgst6tj75")||(test(structArrayIndex).name=="idvdst6")
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumbe5)),:)=(table2array(file4Data(:,5))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumbe4)),:)=(table2array(file4Data(:,4))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumbe3)),:)=(table2array(file4Data(:,3))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumbe2)),:)=(table2array(file4Data(:,2))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumb5)),:)=(table2array(file3Data(:,5))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumb4)),:)=(table2array(file3Data(:,4))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernumb3)),:)=(table2array(file3Data(:,3))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernumb2)),:)=(table2array(file3Data(:,2))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum5)),:)=(table2array(file2Data(:,5))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum4)),:)=(table2array(file2Data(:,4))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum3)),:)=(table2array(file2Data(:,3))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum2)),:)=(table2array(file2Data(:,2))).';
                    SIMetrixTime{stepValueIndex}=(table2array(file4Data(:,1))).';
                end
                if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvdst5")
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumbe3)),:)=(table2array(file4Data(:,3))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumbe2)),:)=(table2array(file4Data(:,2))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumb5)),:)=(table2array(file3Data(:,5))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumb4)),:)=(table2array(file3Data(:,4))).';
                    SIMetrixVoltages{stepValueIndex}(str2double(char(headernumb3)),:)=(table2array(file3Data(:,3))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernumb2)),:)=(table2array(file3Data(:,2))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum5)),:)=(table2array(file2Data(:,5))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum4)),:)=(table2array(file2Data(:,4))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum3)),:)=(table2array(file2Data(:,3))).';
                    SIMetrixCurrents{stepValueIndex}(str2double(char(headernum2)),:)=(table2array(file2Data(:,2))).';
                    SIMetrixTime{stepValueIndex}=(table2array(file4Data(:,1))).';
                end
            end
        end
    end

    if(test(structArrayIndex).name=="qisst5")||(test(structArrayIndex).name=="qosst5")||(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qosst6")||...
        (test(structArrayIndex).name=="qisst3")||(test(structArrayIndex).name=="qosst3")||(test(structArrayIndex).name=="qisst4")||(test(structArrayIndex).name=="qosst4")



        if((isempty(file2_Qiss))&&(isempty(file2_Qoss)))
            netlistFile=ee.internal.validation.mosfet.createSPICEToolNetlist(1,SPICETool,dirname,SPICEFile,subcircuitName,subcircuitDetails,test,structArrayIndex,relTol,absTol,vnTol);
            netlistoutFile="testNetlist"+subcircuitName+"_1"+".out";
            result=system(char(SIMetrixCommand+strcat(dirname+"/"+netlistFile)));
            if result~=0
                pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
            end


            fid=fopen((dirname+"/"+netlistoutFile),"r");
            A=split(fileread((dirname+"/"+netlistoutFile)),newline);



            B=regexp(A,"Tabulated Vectors");
            linenumber=find(~cellfun(@isempty,B));
            if(isempty(linenumber))
                pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
            end
            C=regexp(A,"Analysis statistics");
            linenumber1=find(~cellfun(@isempty,C));
            if(isempty(linenumber1))
                pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
            end



            for lineIndex=1:linenumber(1)-1
                fgetl(fid);
            end




            fidfile1write=fopen((dirname+"/"+"file1.txt"),"w");
            for lineIndex=1:(linenumber1-linenumber(1)-1)
                fprintf(fidfile1write,fgetl(fid));
                fprintf(fidfile1write,"\n");
            end




            fidfile1read=fopen((dirname+"/"+"file1.txt"),"r");
            A=split(fileread((dirname+"/"+"file1.txt")),newline);
            B=regexp(A,"^Time");
            linenumber2=find(~cellfun(@isempty,B));
            for lineIndex=1:linenumber2(1)-1
                fgetl(fidfile1read);
            end
            fidheaderfile2write=fopen((dirname+"/"+"file2header.txt"),"w");
            fprintf(fidheaderfile2write,fgetl(fidfile1read));
            fidfile2write=fopen((dirname+"/"+"file2.txt"),"w");
            for lineIndex=1:(linenumber2(2)-linenumber2(1)-1)
                fprintf(fidfile2write,fgetl(fidfile1read));
                fprintf(fidfile2write,"\n");
            end
            fidheaderfile3write=fopen((dirname+"/"+"file3header.txt"),"w");
            fprintf(fidheaderfile3write,fgetl(fidfile1read));
            fidfile3write=fopen((dirname+"/"+"file3.txt"),"w");
        end
        if(test(structArrayIndex).name=="qisst5")||(test(structArrayIndex).name=="qosst5")||(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qosst6")
            if((isempty(file2_Qiss))&&(isempty(file2_Qoss)))
                for lineIndex=1:(linenumber2(3)-linenumber2(2)-1)
                    fprintf(fidfile3write,fgetl(fidfile1read));
                    fprintf(fidfile3write,"\n");
                end
                fidheaderfile4write=fopen((dirname+"/"+"file4header.txt"),"w");
                fprintf(fidheaderfile4write,fgetl(fidfile1read));
                fidfile4write=fopen((dirname+"/"+"file4.txt"),"w");
                while~feof(fidfile1read)
                    fprintf(fidfile4write,fgetl(fidfile1read));
                    fprintf(fidfile4write,"\n");
                end
            end
            if((isempty(file2_Qiss))&&(isempty(file2_Qoss)))
                fidheaderfile2read=fopen((dirname+"/"+"file2header.txt"),"r");
            else
                if(test(structArrayIndex).name=="qisst5")
                    fidheaderfile2read=fopen((file2header_Qiss),"r");
                elseif(test(structArrayIndex).name=="qosst5")
                    fidheaderfile2read=fopen((file2header_Qoss),"r");
                end
            end
            if((isempty(file2_Qiss))&&(isempty(file2_Qoss)))
                fidheaderfile3read=fopen((dirname+"/"+"file3header.txt"),"r");
            else
                if(test(structArrayIndex).name=="qisst5")
                    fidheaderfile3read=fopen((file3header_Qiss),"r");
                elseif(test(structArrayIndex).name=="qosst5")
                    fidheaderfile3read=fopen((file3header_Qoss),"r");
                end
            end
            headerNames3=textscan(fidheaderfile3read," %s %s %s %s %s ",1,"Delimiter","\t");
            headernumb5=regexp(char(headerNames3{5}),"\d+","match");
            if((isempty(file2_Qiss))&&(isempty(file2_Qoss)))
                fidheaderfile4read=fopen((dirname+"/"+"file4header.txt"),"r");
            else
                if(test(structArrayIndex).name=="qisst5")
                    fidheaderfile4read=fopen((file4header_Qiss),"r");
                elseif(test(structArrayIndex).name=="qosst5")
                    fidheaderfile4read=fopen((file4header_Qoss),"r");
                end
            end
            headerNames4=textscan(fidheaderfile4read," %s %s %s %s ",1,"Delimiter","\t");
            headernumbe2=regexp(char(headerNames4{2}),"\d+","match");
            headernumbe3=regexp(char(headerNames4{3}),"\d+","match");
            headernumbe4=regexp(char(headerNames4{4}),"\d+","match");
            if((isempty(file2_Qiss))&&(isempty(file2_Qoss)))
                fclose(fid);
                fclose(fidfile1write);
                fclose(fidfile1read);
                fclose(fidfile2write);
                fclose(fidheaderfile2write);
                fclose(fidheaderfile2read);
                fclose(fidfile3write);
                fclose(fidheaderfile3write);
                fclose(fidheaderfile3read);
                fclose(fidfile4write);
                fclose(fidheaderfile4write);
                fclose(fidheaderfile4read);
            else
                fclose(fidheaderfile2read);
                fclose(fidheaderfile3read);
                fclose(fidheaderfile4read);
            end
            if((isempty(file2_Qiss))&&(isempty(file2_Qoss)))
                file3Data=readtable((dirname+"/"+"file3.txt"),"Delimiter","\t");
                file4Data=readtable((dirname+"/"+"file4.txt"),"Delimiter","\t");
            else
                if(test(structArrayIndex).name=="qisst5")
                    file3Data=readtable((file3_Qiss),"Delimiter","\t");
                    file4Data=readtable((file4_Qiss),"Delimiter","\t");
                elseif(test(structArrayIndex).name=="qosst5")
                    file3Data=readtable((file3_Qoss),"Delimiter","\t");
                    file4Data=readtable((file4_Qoss),"Delimiter","\t");
                end
            end
            if(test(structArrayIndex).name=="qisst5")
                SIMetrixVoltages{1}(str2double(char(headernumb5)),:)=(table2array(file3Data(:,5))).';
                SIMetrixTime{1}=(table2array(file4Data(:,1))).';
            end
            if(test(structArrayIndex).name=="qosst5")
                SIMetrixVoltages{1}(str2double(char(headernumbe2)),:)=(table2array(file4Data(:,2))).';
                SIMetrixTime{1}=(table2array(file4Data(:,1))).';
            end
            if(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qosst6")
                SIMetrixVoltages{1}(str2double(char(headernumbe3)),:)=(table2array(file4Data(:,3))).';
                SIMetrixVoltages{1}(str2double(char(headernumbe4)),:)=(table2array(file4Data(:,4))).';
                SIMetrixTime{1}=(table2array(file4Data(:,1))).';
            end
        end

        if(test(structArrayIndex).name=="qisst3")||(test(structArrayIndex).name=="qosst3")||...
            (test(structArrayIndex).name=="qisst4")||(test(structArrayIndex).name=="qosst4")
            while~feof(fidfile1read)
                fprintf(fidfile3write,fgetl(fidfile1read));
                fprintf(fidfile3write,"\n");
            end
            fidheaderfile2read=fopen((dirname+"/"+"file2header.txt"),"r");
            headerNames2=textscan(fidheaderfile2read," %s %s %s %s %s ",1,"Delimiter","\t");
            headernum3=regexp(char(headerNames2{3}),"\d+","match");
            headernum5=regexp(char(headerNames2{5}),"\d+","match");
            fidheaderfile3read=fopen((dirname+"/"+"file3header.txt"),"r");
            headerNames3=textscan(fidheaderfile3read," %s %s ",1,"Delimiter","\t");
            headernumb2=regexp(char(headerNames3{2}),"\d+","match");
            fclose(fid);
            fclose(fidfile1write);
            fclose(fidfile1read);
            fclose(fidfile2write);
            fclose(fidheaderfile2write);
            fclose(fidheaderfile2read);
            fclose(fidfile3write);
            fclose(fidheaderfile3write);
            fclose(fidheaderfile3read);
            file2Data=readtable((dirname+"/"+"file2.txt"),"Delimiter","\t");
            file3Data=readtable((dirname+"/"+"file3.txt"),"Delimiter","\t");
            SIMetrixCurrents{1}(str2double(char(headernum3)),:)=(table2array(file2Data(:,3))).';
            SIMetrixVoltages{1}(str2double(char(headernumb2)),:)=(table2array(file3Data(:,2))).';
            SIMetrixVoltages{1}(str2double(char(headernum5)),:)=(table2array(file2Data(:,5))).';
            SIMetrixTime{1}=(table2array(file3Data(:,1))).';
        end
    end

    if(test(structArrayIndex).name=="breakdownt5")||(test(structArrayIndex).name=="breakdownt6")||(test(structArrayIndex).name=="breakdownt3")||(test(structArrayIndex).name=="breakdownt4")



        if(isempty(file2_Breakdown))
            netlistFile=ee.internal.validation.mosfet.createSPICEToolNetlist(1,SPICETool,dirname,SPICEFile,subcircuitName,subcircuitDetails,test,structArrayIndex,relTol,absTol,vnTol);
            netlistoutFile="testNetlist"+subcircuitName+"_1"+".out";
            result=system(char(SIMetrixCommand+strcat(dirname+"/"+netlistFile)));
            if result~=0
                pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
            end


            fid=fopen((dirname+"/"+netlistoutFile),"r");
            A=split(fileread((dirname+"/"+netlistoutFile)),newline);



            B=regexp(A,"Tabulated Vectors");
            linenumber=find(~cellfun(@isempty,B));
            if(isempty(linenumber))
                pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
            end
            C=regexp(A,"Analysis statistics");
            linenumber1=find(~cellfun(@isempty,C));
            if(isempty(linenumber1))
                pm_error("physmod:ee:SPICE2sscvalidation:SimulationError",SPICETool,subcircuitName);
            end



            for lineIndex=1:linenumber(1)-1
                fgetl(fid);
            end




            fidfile1write=fopen((dirname+"/"+"file1.txt"),"w");
            for lineIndex=1:(linenumber1-linenumber(1)-1)
                fprintf(fidfile1write,fgetl(fid));
                fprintf(fidfile1write,"\n");
            end




            fidfile1read=fopen((dirname+"/"+"file1.txt"),"r");
            A=split(fileread((dirname+"/"+"file1.txt")),newline);
            B=regexp(A,"^Time");
            linenumber2=find(~cellfun(@isempty,B));
            for lineIndex=1:linenumber2(1)-1
                fgetl(fidfile1read);
            end
            fidheaderfile2write=fopen((dirname+"/"+"file2header.txt"),"w");
            fprintf(fidheaderfile2write,fgetl(fidfile1read));
            fidfile2write=fopen((dirname+"/"+"file2.txt"),"w");
            for lineIndex=1:(linenumber2(2)-linenumber2(1)-1)
                fprintf(fidfile2write,fgetl(fidfile1read));
                fprintf(fidfile2write,"\n");
            end
            fidheaderfile3write=fopen((dirname+"/"+"file3header.txt"),"w");
            fprintf(fidheaderfile3write,fgetl(fidfile1read));
            fidfile3write=fopen((dirname+"/"+"file3.txt"),"w");
        end
        if(test(structArrayIndex).name=="breakdownt3")||(test(structArrayIndex).name=="breakdownt4")
            while~feof(fidfile1read)
                fprintf(fidfile3write,fgetl(fidfile1read));
                fprintf(fidfile3write,"\n");
            end
            fidheaderfile2read=fopen((dirname+"/"+"file2header.txt"),"r");
            headerNames2=textscan(fidheaderfile2read," %s %s %s %s %s ",1,"Delimiter","\t");
            headernum4=regexp(char(headerNames2{4}),"\d+","match");
            fidheaderfile3read=fopen((dirname+"/"+"file3header.txt"),"r");
            headerNames3=textscan(fidheaderfile3read," %s %s %s ",1,"Delimiter","\t");
            headernumb3=regexp(char(headerNames3{3}),"\d+","match");
            fclose(fid);
            fclose(fidfile1write);
            fclose(fidfile1read);
            fclose(fidfile2write);
            fclose(fidheaderfile2write);
            fclose(fidheaderfile2read);
            fclose(fidfile3write);
            fclose(fidheaderfile3write);
            fclose(fidheaderfile3read);
            file2Data=readtable((dirname+"/"+"file2.txt"),"Delimiter","\t");
            file3Data=readtable((dirname+"/"+"file3.txt"),"Delimiter","\t");
            SIMetrixVoltages{1}(str2double(char(headernumb3)),:)=(table2array(file3Data(:,3))).';
            SIMetrixCurrents{1}(str2double(char(headernum4)),:)=(table2array(file2Data(:,4))).';
            SIMetrixTime{1}=(table2array(file3Data(:,1))).';
        end
        if(test(structArrayIndex).name=="breakdownt5")||(test(structArrayIndex).name=="breakdownt6")
            if(isempty(file2_Breakdown))
                for lineIndex=1:(linenumber2(3)-linenumber2(2)-1)
                    fprintf(fidfile3write,fgetl(fidfile1read));
                    fprintf(fidfile3write,"\n");
                end
                fidheaderfile4write=fopen((dirname+"/"+"file4header.txt"),"w");
                fprintf(fidheaderfile4write,fgetl(fidfile1read));
                fidfile4write=fopen((dirname+"/"+"file4.txt"),"w");
                while~feof(fidfile1read)
                    fprintf(fidfile4write,fgetl(fidfile1read));
                    fprintf(fidfile4write,"\n");
                end
            end
            if(isempty(file2_Breakdown))
                fidheaderfile2read=fopen((dirname+"/"+"file2header.txt"),"r");
            else
                fidheaderfile2read=fopen((file2header_Breakdown),"r");
            end
            if(isempty(file2_Breakdown))
                fidheaderfile3read=fopen((dirname+"/"+"file3header.txt"),"r");
            else
                fidheaderfile3read=fopen((file3header_Breakdown),"r");
            end
            headerNames3=textscan(fidheaderfile3read," %s %s %s %s %s ",1,"Delimiter","\t");
            headernumb2=regexp(char(headerNames3{2}),"\d+","match");
            headernumb3=regexp(char(headerNames3{3}),"\d+","match");
            if(isempty(file2_Breakdown))
                fidheaderfile4read=fopen((dirname+"/"+"file4header.txt"),"r");
            else
                fidheaderfile4read=fopen((file4header_Breakdown),"r");
            end
            if(test(structArrayIndex).name=="breakdownt6")
                headerNames4=textscan(fidheaderfile4read," %s %s %s %s %s ",1,"Delimiter","\t");
                headernumbe5=regexp(char(headerNames4{5}),"\d+","match");
            end
            if(test(structArrayIndex).name=="breakdownt5")
                headerNames4=textscan(fidheaderfile4read," %s %s %s ",1,"Delimiter","\t");
                headernumbe3=regexp(char(headerNames4{3}),"\d+","match");
            end
            if(isempty(file2_Breakdown))
                fclose(fid);
                fclose(fidfile1write);
                fclose(fidfile1read);
                fclose(fidfile2write);
                fclose(fidheaderfile2write);
                fclose(fidheaderfile2read);
                fclose(fidfile3write);
                fclose(fidheaderfile3write);
                fclose(fidheaderfile3read);
                fclose(fidfile4write);
                fclose(fidheaderfile4write);
                fclose(fidheaderfile4read);
            else
                fclose(fidheaderfile2read);
                fclose(fidheaderfile3read);
                fclose(fidheaderfile4read);
            end
            if(isempty(file2_Breakdown))
                file3Data=readtable((dirname+"/"+"file3.txt"),"Delimiter","\t");
                file4Data=readtable((dirname+"/"+"file4.txt"),"Delimiter","\t");
            else
                file3Data=readtable((file3_Breakdown),"Delimiter","\t");
                file4Data=readtable((file4_Breakdown),"Delimiter","\t");
            end
            if(test(structArrayIndex).name=="breakdownt6")
                SIMetrixVoltages{1}(str2double(char(headernumbe5)),:)=(table2array(file4Data(:,5))).';
                SIMetrixCurrents{1}(str2double(char(headernumb3)),:)=(table2array(file3Data(:,3))).';
                SIMetrixTime{1}=(table2array(file4Data(:,1))).';
            end
            if(test(structArrayIndex).name=="breakdownt5")
                SIMetrixVoltages{1}(str2double(char(headernumbe3)),:)=(table2array(file4Data(:,3))).';
                SIMetrixCurrents{1}(str2double(char(headernumb2)),:)=(table2array(file3Data(:,2))).';
                SIMetrixTime{1}=(table2array(file4Data(:,1))).';
            end
        end
    end


    [~,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissValid,qossValid]=ee.internal.validation.mosfet.runSimscapeSimulation(SimscapeFile,test,structArrayIndex,subcircuitDetails.nodes);


    [outputStruct]=ee.internal.validation.mosfet.generateOutputTable(test,structArrayIndex,SIMetrixVoltages,SIMetrixCurrents,SIMetrixTime,SimscapeVoltages,SimscapeCurrents,SimscapeTime,absErrTol,relErrTol);


    if((isempty(file2_IdVgstj27))&&(isempty(file2_IdVgstj75))&&(isempty(file2_IdVds))&&(isempty(file2_Qiss))&&(isempty(file2_Qoss))&&(isempty(file2_Breakdown)))
        if exist(dirname,"dir")
            rmdir(dirname,"s");
        end
    end
end

function myCleanupFun2(dirname)
    if exist(dirname,"dir")
        rmdir(dirname,"s");
    end
end