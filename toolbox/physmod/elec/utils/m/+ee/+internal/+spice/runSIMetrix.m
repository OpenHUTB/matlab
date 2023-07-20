function outFilePaths=runSIMetrix(SIMetrixPath,netlists)






















    if~ispc

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SPICEToolDoNotSupportCurrentPlatform','SIMetrix');
    end


    if~exist(SIMetrixPath,"file")||~endsWith(SIMetrixPath,"Sim.exe")
        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SetTheCorrectPathOfTheExecutable','SIMetrix');
        SIMetrixCommand=string.empty;
    else
        SIMetrixCommand=""""+SIMetrixPath+""" ";
    end


    netlistsStrings=string(netlists);


    currentPath=pwd;


    outFilePaths=cell(length(netlistsStrings),1);
    for ii=1:length(netlistsStrings)

        if isfile(netlistsStrings(ii))

            [filepath,name,ext]=fileparts(char(netlistsStrings(ii)));
            cd(filepath);


            result=system(char(SIMetrixCommand+char([name,ext])));
            if result~=0
                pm_error("physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationError","SIMetrix",netlistsStrings(ii));
            end


            outFile=fullfile(filepath,[name,'.out']);

            if isfile(outFile)
                outFilePaths{ii}=outFile;
            else

                pm_error("physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationError","SIMetrix",netlistsStrings(ii));
            end

        else

            pm_error("physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotFind",netlistsStrings(ii));
        end
    end

    if~isa(netlists,'cell')
        outFilePaths=string(outFilePaths);
    end


    cd(currentPath);
end