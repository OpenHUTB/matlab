function[VgsVec,VdsVec,CgsMat,CgdMat,CdsVec]=capacitance(netlistOut,subcircuitName,frequency)

































    netlistOutPath=string(netlistOut);
    [~,name,~]=fileparts(netlistOutPath);

    if~all(strncmpi(name,subcircuitName,length(subcircuitName)))

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:OutputNameError')));
    end


    capacitanceName=regexp(name,'(?<=\_)Capacitance(?=\_)','match');
    name=name(~cellfun(@isempty,capacitanceName));
    netlistOutPath=netlistOutPath(~cellfun(@isempty,capacitanceName));
    if isempty(name)

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NoFileNameMatchForIdsVgs','_Capacitance')));
    else
        fprintf([getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:sprintf_useToExtract',join(name,", "),'Capacitance')),'\n']);
    end


    VgsVec=regexp(name,'(?<=\_Vgs)(\w|\-|\+|\.)+','match');
    if isempty(VgsVec)

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FileNameMatchForT',name)));
    elseif any(cellfun(@isempty,VgsVec))

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutputName',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FileNameMatchForT',name(find(cellfun(@isempty,VgsVec),true,'first')))));
    end
    VgsVec=cellfun(@str2double,VgsVec);

    [VgsVec,order]=sort(VgsVec);
    netlistOutPath=netlistOutPath(order);

    VdsCell=cell(1,length(netlistOutPath));
    CissCell=cell(1,length(netlistOutPath));
    CrssCell=cell(1,length(netlistOutPath));
    CossCell=cell(1,length(netlistOutPath));

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


        if~strcmpi(analysis.sweepName,"Vds")

            pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
            getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SweepParameterShouldBe','Vds')));
        end


        VdsCell{ii}=analysis.sweepVectors';


        indexTime=strcmpi(analysis.variableName,"Time");

        indexVd1=strcmpi(analysis.variableName,"V(dut11)");
        indexVg1=strcmpi(analysis.variableName,"V(dut12)");
        indexVs1=strcmpi(analysis.variableName,"V(dut13)");
        indexIg1=strcmpi(analysis.variableName,"IG(X1#g)");


        indexVd2=strcmpi(analysis.variableName,"V(dut21)");
        indexVg2=strcmpi(analysis.variableName,"V(dut22)");
        indexVs2=strcmpi(analysis.variableName,"V(dut23)");
        indexIg2=strcmpi(analysis.variableName,"IG(X2#g)");
        indexId2=strcmpi(analysis.variableName,"ID(X2#d)");

        VgsDC=zeros(1,length(VdsCell{ii}));
        VgsAC=zeros(1,length(VdsCell{ii}));
        VdsDC=zeros(1,length(VdsCell{ii}));
        VdsAC=zeros(1,length(VdsCell{ii}));
        CissCell{ii}=zeros(1,length(VdsCell{ii}));
        CrssCell{ii}=zeros(1,length(VdsCell{ii}));
        CossCell{ii}=zeros(1,length(VdsCell{ii}));

        for jj=1:length(VdsCell{ii})

            time=analysis.variableVectors{jj}(:,indexTime);


            indexf=find(time>=5/frequency,1,'first');
            time=time(indexf:end)-time(indexf);

            Vd1=analysis.variableVectors{jj}(indexf:end,indexVd1);
            Vg1=analysis.variableVectors{jj}(indexf:end,indexVg1);
            Vs1=analysis.variableVectors{jj}(indexf:end,indexVs1);
            Ig1=analysis.variableVectors{jj}(indexf:end,indexIg1);
            Vd2=analysis.variableVectors{jj}(indexf:end,indexVd2);
            Vg2=analysis.variableVectors{jj}(indexf:end,indexVg2);
            Vs2=analysis.variableVectors{jj}(indexf:end,indexVs2);
            Ig2=analysis.variableVectors{jj}(indexf:end,indexIg2);
            Id2=analysis.variableVectors{jj}(indexf:end,indexId2);
            Vgs1=Vg1-Vs1;
            Vds2=Vd2-Vs2;


            VgsDC(jj)=trapz(time,Vgs1)/time(end);

            if abs(VgsDC(jj)-VgsVec(ii))>1e-3

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','Vgs','Capacitance characteristics')));
            end
            VgsAC(jj)=trapz(time,sin(2*pi*frequency*time).*(Vgs1-VgsDC(jj)))*2/time(end);
            IgDC1=trapz(time,Ig1)/time(end);
            CissCell{ii}(jj)=trapz(time,sin(2*pi*frequency*time+pi/2).*(Ig1-IgDC1))*2/time(end)/VgsAC(jj)/2/pi/frequency;


            VdsDC(jj)=trapz(time,Vds2)/time(end);

            if abs(VdsDC(jj)-VdsCell{ii}(jj))>1e-3

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
                getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','Vds','Capacitance characteristics')));
            end
            VdsAC(jj)=trapz(time,sin(2*pi*frequency*time).*(Vds2-VdsDC(jj)))*2/time(end);
            IgDC2=trapz(time,Ig2)/time(end);
            IdDC2=trapz(time,Id2)/time(end);
            CrssCell{ii}(jj)=-trapz(time,sin(2*pi*frequency*time+pi/2).*(Ig2-IgDC2))*2/time(end)/VdsAC(jj)/2/pi/frequency;
            CossCell{ii}(jj)=trapz(time,sin(2*pi*frequency*time+pi/2).*(Id2-IdDC2))*2/time(end)/VdsAC(jj)/2/pi/frequency;
        end
    end


    if~all(cellfun(@(x)isequal(x,VdsCell{1}),VdsCell,'UniformOutput',true))

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:FormatErrorInSPICEOutput',...
        getString(message('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheValueOfShouldBeTheSame','Vds','Capacitance characteristics')));
    end

    VdsVec=VdsCell{1};
    CissMat=cell2mat(CissCell);
    CissMat=reshape(CissMat,[length(VdsVec),length(VgsVec)])';
    CrssMat=cell2mat(CrssCell);
    CrssMat=reshape(CrssMat,[length(VdsVec),length(VgsVec)])';
    CossMat=cell2mat(CossCell);
    CossMat=reshape(CossMat,[length(VdsVec),length(VgsVec)])';



    indexVgs0=find(VgsVec==0);
    if indexVgs0
        CdsVec=CossMat(indexVgs0,:)-CrssMat(indexVgs0,:);
    else

        pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:MustIncludeVgsForCapacitanceCharacteristics');
    end

    CgsMat=CissMat-CrssMat;
    CgdMat=CrssMat;
end
