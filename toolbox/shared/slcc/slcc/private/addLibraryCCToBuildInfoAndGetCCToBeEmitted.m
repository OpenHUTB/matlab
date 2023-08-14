function[allCCHeaderCode,allCSrcCode,allCCInitCode,allCCTermCode,isCpp]=addLibraryCCToBuildInfoAndGetCCToBeEmitted(mainModelH,libModelHandles)











    mainModelName=get_param(mainModelH,'Name');
    linkMachines=sfprivate('get_link_chart_file_numbers',mainModelName);

    linkMachineHandles=[];
    if~isempty(linkMachines)
        linkMachineHandles=cell2mat(get_param(linkMachines,'Handle'));
    end

    libModelHandesNoSF=setdiff(libModelHandles,linkMachineHandles);
    [allCCHeaderCode,allCSrcCode]=deal(cell(size(libModelHandesNoSF)));
    [allCCInitCode,allCCTermCode]=deal('');
    twonewlines=strcat(newline,newline);
    for i=1:numel(libModelHandesNoSF)
        [allCCHeaderCode{i},allCSrcCode{i},ccInitCode,ccTermCode]=addLibraryCustomCodeToBuildInfo(libModelHandesNoSF(i),mainModelH);
        allCCInitCode=strcat(allCCInitCode,twonewlines,ccInitCode);
        allCCTermCode=strcat(allCCTermCode,twonewlines,ccTermCode);
    end
    allCCInitCode=strtrim(allCCInitCode);
    allCCTermCode=strtrim(allCCTermCode);

    isCpp=isequal(get_param(getActiveConfigSet(mainModelName),'TargetLang'),'C++');
