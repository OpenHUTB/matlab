










function[bResultStatus,ResultDescription]=modelAdvisorCheck_UniqueLocal(system,xlateTagPrefix)





    ResultDescription={};
    bResultStatus=false;



    part_pass=1;

    sfr=get_param(system,'Object');
    if(~isempty(sfr))
        charts=sfr.find('-isa','Stateflow.Chart');

        linkCharts=ModelAdvisor.Common.find_LinkChart(sfr);
        charts=[charts(:);linkCharts(:)];
    else
        charts=[];
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    charts=mdladvObj.filterResultWithExclusion(charts);


    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setInformation({DAStudio.message([xlateTagPrefix,'hisl_0061_Info_1'])});
    ft.setColTitles({DAStudio.message([xlateTagPrefix,'hisl_0061_ColTitle_1']),...
    DAStudio.message([xlateTagPrefix,'hisl_0061_ColTitle_2'])});
    if(strcmp(xlateTagPrefix,'ModelAdvisor:iec61508:'))
        ft.setSubTitle(DAStudio.message([xlateTagPrefix,'hisl_0061_Title']));
    end

    for knx=1:length(charts)
        dataArray=charts(knx).find('-isa','Stateflow.Data');

        dataArray=filterOutAutoManagedData(dataArray);

        numData=length(dataArray);
        dataName={};
        for inx=1:numData
            dataName{inx}=dataArray(inx).Name;
        end

        [uniqueData]=unique(dataName);
        numUnique=length(uniqueData);
        if(numUnique~=numData)
            part_pass=0;

            for inx=1:numUnique


                [~,index]=find(strcmp(uniqueData(inx),dataName));
                if(length(index)>1)
                    linksToIds=[];
                    for jnx=1:length(index)
                        sidLink=Simulink.ID.getSID(dataArray(index(jnx)));
                        str=['<a href="matlab:Simulink.ID.hilite(''',...
                        sidLink,''')">',...
                        dataArray(index(jnx)).Path,'</a>'];
                        linksToIds=[linksToIds,str,'<br/>'];
                    end
                    linksToIds=linksToIds(1:end-5);
                    ft.addRow({uniqueData{inx},linksToIds});

                end
            end
        end
    end

    if(isempty(charts))
        ft.setSubResultStatus('Pass');
        bResultStatus=true;
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:iec61508:NoChartsFound'))
    elseif(part_pass)
        ft.setSubResultStatus('Pass');
        bResultStatus=true;
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0061_NoDupLocals']));
    else
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0061_Fail_1']));
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'hisl_0061_RecAct_1']));
    end

    ft.setSubBar(0);
    ResultDescription{end+1}=ft;

end

function out=filterOutAutoManagedData(in)
    keep=true(size(in));
    for i=1:numel(in)
        if in(i).autoManaged
            keep(i)=false;
        end
    end
    out=in(keep);
end

