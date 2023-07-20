function[VgsVec,VdsVec,TVec,IdsMat]=IdsVds(netlistOut,subcircuitName)



























    netlistOutPath=string(netlistOut);
    [~,name,~]=fileparts(netlistOutPath);

    if~all(strncmpi(name,subcircuitName,length(subcircuitName)))

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:OutputNameError')));
    end


    IdsVds=regexp(name,'(?<=\_)IdsVds(?=\_)','match');
    name=name(~cellfun(@isempty,IdsVds));
    netlistOutPath=netlistOutPath(~cellfun(@isempty,IdsVds));
    if isempty(name)

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NoFileNameMatchForIdsVgs','_IdsVds')));
    else

        fprintf([getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:sprintf_useToExtract',join(name,", "),'Ids(Vgs,Vds,T)')),'\n']);
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
    VgsCell=cell(1,length(netlistOutPath));
    VdsCell=cell(1,length(netlistOutPath));
    IdsCell=cell(1,length(netlistOutPath));

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


        if~strcmpi(analysis.sweepName,"Vgs")

            pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
            getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SweepParameterShouldBe','Vgs')));
        end


        VgsCell{ii}=analysis.sweepVectors';
        [VdsLength,~]=size(analysis.variableVectors{1});

        IdsCell{ii}=zeros(length(VdsCell{ii}),VdsLength);
        flagT=0;


        indexTime=strcmpi(analysis.variableName,"Time");
        indexVd=strcmpi(analysis.variableName,"V(dut1)");
        indexVg=strcmpi(analysis.variableName,"V(dut2)");
        indexVs=strcmpi(analysis.variableName,"V(dut3)");
        if any(strcmpi(analysis.variableName,"V(dut5)"))
            flagT=1;
            indexT=strcmpi(analysis.variableName,"V(dut5)");
        end
        indexId=strcmpi(analysis.variableName,"ID(X1#d)");

        for jj=1:length(VgsCell{ii})

            time=analysis.variableVectors{jj}(:,indexTime);
            Vd=analysis.variableVectors{jj}(:,indexVd);
            Vg=analysis.variableVectors{jj}(:,indexVg);
            Vs=analysis.variableVectors{jj}(:,indexVs);
            Ids=analysis.variableVectors{jj}(:,indexId);
            if flagT
                T=analysis.variableVectors{jj}(:,indexT);
            end

            Vds=Vd-Vs;
            Vgs=Vg-Vs;


            timeCell{ii}=time;
            VdsCell{ii}=Vds;


            if length(timeCell{1})==length(time)
                if~all(timeCell{1}==time)

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                    getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationTimeShouldBeTheSame','IV characteristics')));
                end
            else

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationTimeShouldBeTheSame','IV characteristics')));
            end


            if length(VdsCell{1})==length(Vds)
                if~all(VdsCell{1}==Vds)

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                    getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','Vds','IV characteristics')));
                end
            else

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationTimeShouldBeTheSame','IV characteristics')));
            end


            if~all(all(round(Vgs-VgsCell{ii}(jj),4)==0))

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','Vgs','IV characteristics')));
            end


            if flagT
                if~all(all(round(T-TVec(ii),4)==0))

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                    getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','T','IV characteristics')));
                end
            end


            IdsCell{ii}(jj,:)=Ids;
        end
    end

    IdsMat=zeros(length(VgsCell{1}),length(VdsCell{1}),length(TVec));
    IdsMat(:,:,1)=IdsCell{1};

    for ii=2:length(TVec)
        if timeCell{ii}(end)~=timeCell{1}(end)

            pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
            getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SimulationTimeShouldBeTheSame','IV characteristics')));
        end

        if~all(VgsCell{ii}==VgsCell{1})

            pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
            getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','Vgs','IV characteristics')));
        end

        for jj=1:length(VgsCell{1})
            IdsMat(jj,:,ii)=interp1(timeCell{ii},IdsCell{ii}(jj,:),timeCell{1});
        end
    end

    VgsVec=VgsCell{1}';
    VdsVec=VdsCell{1};
end
