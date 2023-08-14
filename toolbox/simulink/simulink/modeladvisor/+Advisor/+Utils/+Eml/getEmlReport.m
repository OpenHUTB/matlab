function report=getEmlReport(emlSfObj)







    if isnumeric(emlSfObj)
        chartH=idToHandle(sfroot(),emlSfObj);
    elseif isa(emlSfObj,'Stateflow.EMFunction')
        chartH=emlSfObj.chart;
    else
        chartH=emlSfObj;
    end



    [spec,~]=computeSpec(chartH.Id,[]);



    [~,mainInfoName,~,~]=sfprivate('get_report_path',pwd,spec,false);

    if~exist(mainInfoName,'file')


        modeldir=fileparts(chartH.Machine.FullFileName);
        reportDir=fullfile(sfprivate('get_sf_proj',modeldir),'EMLReport');
        mainInfoName=fullfile(reportDir,[spec,'.mat']);
    end

    try

        eml_block_file=load(mainInfoName);
        report=eml_block_file.report;
    catch
        report=[];
    end
end

function hBlk=computeBlockHandle(chartId)
    hBlk=sfprivate('chart2block',chartId);
    if strcmpi(get_param(bdroot(hBlk),'BlockDiagramType'),'library')
        hBlk=sf('get',chartId,'chart.activeInstance');
    end
end

function[spec,hBlk]=computeSpec(chartId,hBlk)
    if isempty(hBlk)
        hBlk=computeBlockHandle(chartId);
    end
    spec=sf('SFunctionSpecialization',chartId,hBlk,true);
    if isempty(spec)





        spec=sf('MD5AsString',getfullname(hBlk));
    end
end