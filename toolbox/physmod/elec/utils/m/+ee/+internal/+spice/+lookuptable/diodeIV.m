function[VVec,TVec,IMat]=diodeIV(netlistOut,subcircuitName)






















    netlistOutPath=string(netlistOut);
    [~,name,~]=fileparts(netlistOutPath);

    if~all(strncmpi(name,subcircuitName,length(subcircuitName)))

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:OutputNameError')));
    end


    diodeIV=regexp(name,'(?<=\_)diodeIV(?=\_)','match');
    name=name(~cellfun(@isempty,diodeIV));
    netlistOutPath=netlistOutPath(~cellfun(@isempty,diodeIV));
    if isempty(name)

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NoFileNameMatchForIdsVgs','_diodeIV')));
    else
        fprintf([getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:sprintf_useToExtract',join(name,", "),'Idiode(Vdiode, T)')),'\n']);
    end


    TVec=regexp(name,'(?<=\_T)(\w|\-|\+|\.)+','match');
    if isempty(TVec)

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FileNameMatchForT',name)));
    elseif any(cellfun(@isempty,TVec))

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FileNameMatchForT',name(find(cellfun(@isempty,TVec),true,'first')))));
    end
    TVec=cellfun(@str2double,TVec);


    [TVec,order]=sort(TVec);
    netlistOutPath=netlistOutPath(order);

    timeCell=cell(1,length(netlistOutPath));
    VCell=cell(1,length(netlistOutPath));
    ICell=cell(1,length(netlistOutPath));

    for ii=1:length(netlistOutPath)

        data=ee.internal.spice.SIMetrix2Matlab(netlistOutPath(ii));

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
            getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:ShouldNotHaveSweepParameter','diode characteristics')));
        end

        [VLength,~]=size(analysis.variableVectors{1});
        VCell{ii}=zeros(1,VLength);
        ICell{ii}=zeros(1,VLength);
        flagT=0;


        indexTime=strcmpi(analysis.variableName,"Time");
        indexVd=strcmpi(analysis.variableName,"V(dut1)");
        indexVs=strcmpi(analysis.variableName,"V(dut3)");
        if any(strcmpi(analysis.variableName,"V(dut5)"))
            flagT=1;
            indexT=strcmpi(analysis.variableName,"V(dut5)");
        end
        indexId=strcmpi(analysis.variableName,"ID(X1#d)");


        time=analysis.variableVectors{1}(:,indexTime);
        Vd=analysis.variableVectors{1}(:,indexVd);
        Vs=analysis.variableVectors{1}(:,indexVs);
        Ids=analysis.variableVectors{1}(:,indexId);
        if flagT
            T=analysis.variableVectors{1}(:,indexT);
        end

        timeCell{ii}=time;
        VCell{ii}=-(Vd-Vs);


        if flagT
            if~all(all(round(T-TVec(ii),4)==0))

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','T','diode characteristics')));
            end
        end


        ICell{ii}=-Ids;
    end

    IMat=zeros(length(TVec),length(VCell{1}));
    IMat(1,:)=ICell{1}';

    IMat(1,1)=0;

    for ii=2:length(TVec)
        if timeCell{ii}(end)~=timeCell{1}(end)

            pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
            getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationTimeShouldBeTheSame','diode characteristics')));
        end
        IMat(ii,:)=interp1(timeCell{ii},ICell{ii}',timeCell{1});


        IMat(ii,1)=0;
    end

    VVec=VCell{1}';
end
