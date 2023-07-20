function TT=currentTail(netlistOut,subcircuitName,pulsePeriodTail)

















    netlistOutPath=string(netlistOut);
    [~,name,~]=fileparts(netlistOutPath);

    if~all(strncmpi(name,subcircuitName,length(subcircuitName)))
        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:OutputNameError')));
    end


    currentTail1=regexp(name,'(?<=\_)currentTail','match');
    name=name(~cellfun(@isempty,currentTail1));
    netlistOutPath=netlistOutPath(~cellfun(@isempty,currentTail1));
    if length(name)==1
        fprintf([getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:sprintf_useToExtract',join(name,", "),'Ids(Vgs,Vds,T)')),'\n']);
    else

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NoFileNameMatchForIdsVgs','_currentTail')));
    end


    currentTail1=regexp(name,'(?<=\_)currentTail','match');
    if any(cellfun(@isempty,currentTail1))

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FileNameMatchForT',name(cellfun(@isempty,currentTail)))));
    end


    data=ee.internal.spice.SIMetrix2Matlab(netlistOutPath);

    if~(length(data.analysis)==1)
        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:ContainOneSimulationAnalysis')));
    end

    analysis=data.analysis{1};

    if~strcmpi(analysis.type,"Transient")

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationTypeTransient')));
    end


    if isfield(analysis,'sweepVectors')

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:ShouldNotHaveSweepParameter','current tail characteristics')));
    end


    indexTime=strcmpi(analysis.variableName,"Time");
    indexIc=strcmpi(analysis.variableName,"ID(X1#d)");


    time=analysis.variableVectors{1}(:,indexTime);
    Ice=analysis.variableVectors{1}(:,indexIc);


    number=round(time(end)/pulsePeriodTail);
    if number<5

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:AtLeastPeriod',5);
    end
    Ion=interp1(time,Ice,(number-2)*pulsePeriodTail-pulsePeriodTail/10);

    time1=time(time>(number-1.25)*pulsePeriodTail);
    Ice1=Ice(time>(number-1.25)*pulsePeriodTail);
    time1=time1(time1<(number-0.75)*pulsePeriodTail);
    Ice1=Ice1(time1<(number-0.75)*pulsePeriodTail);

    time10=find(Ice1>0.9*Ion,1,'last');
    time90=find(Ice1<0.1*Ion,1,'first');
    TT=time1(time90)-time1(time10);
end
