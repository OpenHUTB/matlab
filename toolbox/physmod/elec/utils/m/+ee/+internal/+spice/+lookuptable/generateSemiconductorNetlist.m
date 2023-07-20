classdef generateSemiconductorNetlist


















































































































    properties(Access=public)
        netlists;
        SPICETool="SIMetrix";
        netlistPath;
        terminals=[1,2,3,0,5];





        flagIdsVgs=1;
        flagIdsVds=1;
        flagCapacitance=1;
        flagDiodeIV=1;
        flagTailTransient=0;
        VgsRangeIdsVgs=[0,20];
        VdsStepsIdsVgs=[1:0.2:5];
        VdsRangeIdsVds=[0,5];
        VgsStepsIdsVds=[2:3:20];
        VgsCapacitance=[-5:2:20];
        VdsCapacitance=[0:5:30];
        frequencyCapacitance=1e6;
        acVoltageCapacitance=0.05;
        VdsDiodeIV=[0,-3];
        VceTail=400;
        pulseVgeTail=15;
        pulsePeriodTail=5e-6;
        T=27;
        reltol=1e-3;
        abstol=1e-4;
        vntol=1e-2;
        gmin=1e-6;
        cshunt=1e-6;
        IVsimulationTime=20;
        IVsimulationStepSize=0.02
    end

    properties(Access=private)
        subcircuitFile;
        subcircuitName;
        subcircuitNameLine;
        subcircuitNode;
        flagTermianlsChecked=0;
    end

    methods
        function this=generateSemiconductorNetlist(subcircuitFile,subcircuitName,varargin)


            subcircuitFile=strtrim(subcircuitFile);
            if~isfile(subcircuitFile)

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotFind',subcircuitFile);
            end

            [filepath,name,ext]=fileparts(char(subcircuitFile));
            filepath=getfield(what(filepath),'path');
            this.subcircuitFile=fullfile(filepath,[name,ext]);


            fid=fopen(subcircuitFile,'r','n');
            if fid<3

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotFind',subcircuitFile);
            end


            subcircuitRaw=split(fileread(subcircuitFile),newline);

            fclose(fid);

            [~,subcircuitLineNumber]=this.getExpression(subcircuitRaw,['(?<=^\s*\.SUBCKT\s+)',char(subcircuitName)]);

            if isempty(subcircuitLineNumber)

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotFindTheSubcircuit',subcircuitName,subcircuitFile);
            end
            this.subcircuitNameLine=subcircuitRaw{subcircuitLineNumber};


            nodeNames=regexp(this.subcircuitNameLine,['(?<=^\s*\.SUBCKT\s+',char(subcircuitName),')(\s+(?!PARAMS)\w+)+'],'match','ignorecase');
            if isempty(nodeNames)

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SubcircuitMustContainAtLeast3Nodes',subcircuitName);
            end
            nodeNames=split(nodeNames{1});
            nodeNames=nodeNames(~cellfun(@isempty,nodeNames));
            if length(nodeNames)<3

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:SubcircuitMustContainAtLeast3Nodes',subcircuitName);
            end
            this.subcircuitNode=nodeNames;
            this.subcircuitName=upper(subcircuitName);
        end

        function this=generateNetlists(this)

            filepath=fileparts(char(this.subcircuitFile));

            if isempty(this.netlistPath)

                if isempty(filepath)

                    this.netlistPath=pwd;
                else
                    this.netlistPath=filepath;
                end
            else
                if~exist(this.netlistPath,"dir")

                    mkdir(this.netlistPath);
                end
            end
            this.netlistPath=getfield(what(this.netlistPath),'path');


            netlistsIdsVgs=[];
            netlistsIdsVds=[];
            netlistsCapacitance=[];
            netlistsDiodeIV=[];
            netlistsCurrentTail=[];

            if this.flagIdsVgs==1

                [this,netlistsIdsVgs]=this.generateIdsVgs;
            end

            if this.flagIdsVds==1

                [this,netlistsIdsVds]=this.generateIdsVds;
            end

            if this.flagCapacitance==1

                [this,netlistsCapacitance]=this.generateCapacitance;
            end

            if this.flagDiodeIV==1

                [this,netlistsDiodeIV]=this.generateDiodeIV;
            end

            if this.flagTailTransient==1

                [this,netlistsCurrentTail]=this.generateCurrentTail;
            end

            this.netlists=[netlistsIdsVgs;netlistsIdsVds;netlistsCapacitance;...
            netlistsDiodeIV;netlistsCurrentTail];
        end

        function[this,netlists]=generateIdsVgs(this)



            if length(this.VgsRangeIdsVgs)~=2

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBe','VgsRangeIdsVgs',2);
            end

            if length(this.VdsStepsIdsVgs)<2


                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBeGreatThanOrEqualTo','VdsStepsIdsVgs',2);
            end


            this.VdsStepsIdsVgs=sort(this.VdsStepsIdsVgs);


            [this.terminals,this.flagTermianlsChecked]=this.checkTerminals;


            netlists=cell(length(this.T),1);


            for ii=1:length(this.T)
                netlistName=[char(this.subcircuitName),'_IdsVgs_T',num2str(this.T(ii)),'.net'];
                netlists{ii}=fullfile(this.netlistPath,netlistName);
                if isfile(netlists{ii})

                    pm_warning('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NetlistAlreadyExist',netlists{ii});
                end


                fileID=fopen(netlists{ii},'w');
                if fileID<3

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotWriteToTheFile',netlists{ii});
                end


                fprintf(fileID,'* Ids vs Vgs with step Vds %s\n',this.subcircuitName);

                fprintf(fileID,'* Autogenerated netlist at %s\n\n',datetime('now'));


                fprintf(fileID,'.inc %s\n',this.subcircuitFile);

                fprintf(fileID,'.opt reltol=%.4g abstol=%.4g vntol=%.4g gmin=%.4g cshunt=%.4g\n',...
                this.reltol,this.abstol,this.vntol,this.gmin,this.cshunt);
                fprintf(fileID,'\n');



                this.writeCallSubcircuit(fileID,[]);


                for jj=1:length(this.terminals)
                    if this.terminals(jj)~=0

                        fprintf(fileID,'V%d dut%d ',this.terminals(jj),this.terminals(jj));
                        switch this.terminals(jj)
                        case 1

                            fprintf(fileID,'0 {Vds}');
                        case 2

                            fprintf(fileID,'0 pwl(0 %.2f %d %.2f)',this.VgsRangeIdsVgs(1),this.IVsimulationTime,this.VgsRangeIdsVgs(2));
                        case 3

                            fprintf(fileID,'0 0');
                        case 4

                            fprintf(fileID,'dut3 0');
                        case 5

                            fprintf(fileID,'0 {Temperature}');
                        end
                        fprintf(fileID,'\n');
                    end
                end
                fprintf(fileID,'\n');


                fprintf(fileID,'.param Temperature %.2f\n',this.T(ii));
                fprintf(fileID,'\n');


                fprintf(fileID,'.tran %.2g %d Sweep single param=Vds list ',this.IVsimulationStepSize,this.IVsimulationTime);
                fprintf(fileID,'%.2f ',this.VdsStepsIdsVgs);
                fprintf(fileID,'\n\n');


                fprintf(fileID,'.print tran V(dut1)\n');
                fprintf(fileID,'.print tran V(dut2)\n');
                fprintf(fileID,'.print tran V(dut3)\n');

                if find(this.terminals==4)
                    fprintf(fileID,'.print tran V(dut4)\n');
                end
                if find(this.terminals==5)
                    fprintf(fileID,'.print tran V(dut5)\n');
                end

                fprintf(fileID,'.print tran ID(X1)\n');
                fprintf(fileID,'.print tran IG(X1)\n');
                fprintf(fileID,'.print tran IS(X1)\n');
                if find(this.terminals==4)
                    fprintf(fileID,'.print tran IB(dut1)\n');
                end

                fprintf(fileID,'\n.end\n');

                fclose(fileID);
            end
        end

        function[this,netlists]=generateIdsVds(this)


            if length(this.VdsRangeIdsVds)~=2

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBe','VdsRangeIdsVds',2);
            end

            if length(this.VgsStepsIdsVds)<2


                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBeGreatThanOrEqualTo','VgsStepsIdsVds',2);
            end


            this.VgsStepsIdsVds=sort(this.VgsStepsIdsVds);


            [this.terminals,this.flagTermianlsChecked]=this.checkTerminals;


            netlists=cell(length(this.T),1);


            for ii=1:length(this.T)
                netlistName=[char(this.subcircuitName),'_IdsVds_T',num2str(this.T(ii)),'.net'];
                netlists{ii}=fullfile(this.netlistPath,netlistName);
                if isfile(netlists{ii})

                    pm_warning('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NetlistAlreadyExist',netlists{ii});
                end


                fileID=fopen(netlists{ii},'w');
                if fileID<3

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotWriteToTheFile',netlists{ii});
                end


                fprintf(fileID,'* Ids vs Vgs with step Vds %s\n',this.subcircuitName);

                fprintf(fileID,'* Autogenerated netlist at %s\n\n',datetime('now'));


                fprintf(fileID,'.inc %s\n',this.subcircuitFile);

                fprintf(fileID,'.opt reltol=%.4g abstol=%.4g vntol=%.4g gmin=%.4g cshunt=%.4g\n',...
                this.reltol,this.abstol,this.vntol,this.gmin,this.cshunt);
                fprintf(fileID,'\n');



                this.writeCallSubcircuit(fileID,[]);


                for jj=1:length(this.terminals)
                    if this.terminals(jj)~=0

                        fprintf(fileID,'V%d dut%d ',this.terminals(jj),this.terminals(jj));
                        switch this.terminals(jj)
                        case 1

                            fprintf(fileID,'0 pwl(0 %.2f %d %.2f)',this.VdsRangeIdsVds(1),this.IVsimulationTime,this.VdsRangeIdsVds(2));
                        case 2

                            fprintf(fileID,'0 {Vgs}');
                        case 3

                            fprintf(fileID,'0 0');
                        case 4

                            fprintf(fileID,'dut3 0');
                        case 5

                            fprintf(fileID,'0 {Temperature}');
                        end
                        fprintf(fileID,'\n');
                    end
                end
                fprintf(fileID,'\n');


                fprintf(fileID,'.param Temperature %.2f\n',this.T(ii));
                fprintf(fileID,'\n');


                fprintf(fileID,'.tran %.2g %d Sweep single param=Vgs list ',this.IVsimulationStepSize,this.IVsimulationTime);
                fprintf(fileID,'%.2f ',this.VgsStepsIdsVds);
                fprintf(fileID,'\n\n');


                fprintf(fileID,'.print tran V(dut1)\n');
                fprintf(fileID,'.print tran V(dut2)\n');
                fprintf(fileID,'.print tran V(dut3)\n');

                if find(this.terminals==4)
                    fprintf(fileID,'.print tran V(dut4)\n');
                end
                if find(this.terminals==5)
                    fprintf(fileID,'.print tran V(dut5)\n');
                end

                fprintf(fileID,'.print tran ID(X1)\n');
                fprintf(fileID,'.print tran IG(X1)\n');
                fprintf(fileID,'.print tran IS(X1)\n');
                if find(this.terminals==4)
                    fprintf(fileID,'.print tran IB(dut1)\n');
                end

                fprintf(fileID,'\n.end\n');

                fclose(fileID);
            end
        end

        function[this,netlists]=generateCapacitance(this)


            if length(this.VdsCapacitance)<3


                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBeGreatThanOrEqualTo','VdsCapacitance',3);
            end


            this.VdsCapacitance=sort(this.VdsCapacitance);

            if isempty(this.VgsCapacitance)

                this.VgsCapacitance=0;
            end

            if~any(this.VgsCapacitance==0)

                this.VgsCapacitance(end+1)=0;
            end

            this.VgsCapacitance=sort(this.VgsCapacitance);


            [this.terminals,this.flagTermianlsChecked]=this.checkTerminals;


            netlists=cell(length(this.VgsCapacitance),1);


            for ii=1:length(this.VgsCapacitance)
                netlistName=[char(this.subcircuitName),'_Capacitance_Vgs',num2str(this.VgsCapacitance(ii)),'.net'];
                netlists{ii}=fullfile(this.netlistPath,netlistName);
                if isfile(netlists{ii})

                    pm_warning('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NetlistAlreadyExist',netlists{ii});
                end


                fileID=fopen(netlists{ii},'w');
                if fileID<3

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotWriteToTheFile',netlists{ii});
                end


                fprintf(fileID,'* Ids vs Vgs with step Vds %s\n',this.subcircuitName);

                fprintf(fileID,'* Autogenerated netlist at %s\n\n',datetime('now'));


                fprintf(fileID,'.inc %s\n',this.subcircuitFile);

                fprintf(fileID,'.opt reltol=%.4g abstol=%.4g vntol=%.4g gmin=%.4g cshunt=%.4g\n',...
                this.reltol,this.abstol,this.vntol,this.gmin,this.cshunt);
                fprintf(fileID,'\n');



                for kk=1:2
                    if kk==1
                        fprintf(fileID,'* Ciss I-V with Vgs small AC\n');
                    else
                        fprintf(fileID,'* Coss Crss I-V with Vds small AC\n');
                    end
                    this.writeCallSubcircuit(fileID,kk);


                    for jj=1:length(this.terminals)
                        if this.terminals(jj)~=0

                            fprintf(fileID,'V%d%d dut%d%d ',kk,this.terminals(jj),kk,this.terminals(jj));
                            switch this.terminals(jj)
                            case 1

                                if kk==1

                                    fprintf(fileID,'0 {Vds}');
                                else

                                    fprintf(fileID,'0 sine({Vds} %.2g {f} {2/f})',this.acVoltageCapacitance);
                                end
                            case 2

                                if kk==1
                                    fprintf(fileID,'0 sine({Vgs} %.2g {f} {2/f})',this.acVoltageCapacitance);
                                else
                                    fprintf(fileID,'0 {Vgs}');
                                end
                            case 3

                                fprintf(fileID,'0 0');
                            case 4

                                fprintf(fileID,'dut3 0');
                            case 5

                                fprintf(fileID,'0 27');
                            end
                            fprintf(fileID,'\n');
                        end
                    end
                    fprintf(fileID,'\n');
                end

                fprintf(fileID,'.param f %.4g\n',this.frequencyCapacitance);
                fprintf(fileID,'.param Vgs %.4g\n',this.VgsCapacitance(ii));
                fprintf(fileID,'\n');


                fprintf(fileID,'.tran %.2g %.2g Sweep single param=Vds list ',...
                1/this.frequencyCapacitance/10,10/this.frequencyCapacitance);
                fprintf(fileID,'%.2f ',this.VdsCapacitance);
                fprintf(fileID,'\n\n');


                for kk=1:2
                    fprintf(fileID,'.print tran V(dut%d1)\n',kk);
                    fprintf(fileID,'.print tran V(dut%d2)\n',kk);
                    fprintf(fileID,'.print tran V(dut%d3)\n',kk);

                    if find(this.terminals==4)
                        fprintf(fileID,'.print tran V(dut%d4)\n',kk);
                    end
                    if find(this.terminals==5)
                        fprintf(fileID,'.print tran V(dut%d5)\n',kk);
                    end

                    fprintf(fileID,'.print tran ID(X%d)\n',kk);
                    fprintf(fileID,'.print tran IG(X%d)\n',kk);
                    fprintf(fileID,'.print tran IS(X%d)\n',kk);
                    if find(this.terminals==4)
                        fprintf(fileID,'.print tran IB(dut%d)\n',kk);
                    end
                end

                fprintf(fileID,'\n.end\n');

                fclose(fileID);
            end
        end

        function[this,netlists]=generateDiodeIV(this)


            if length(this.VdsDiodeIV)~=2

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBe','VdsDiodeIV',2);
            end


            [this.terminals,this.flagTermianlsChecked]=this.checkTerminals;


            netlists=cell(length(this.T),1);


            for ii=1:length(this.T)

                netlistName=[char(this.subcircuitName),'_diodeIV_T',num2str(this.T(ii)),'.net'];
                netlists{ii}=fullfile(this.netlistPath,netlistName);
                if isfile(netlists{ii})

                    pm_warning('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NetlistAlreadyExist',netlists{ii});
                end


                fileID=fopen(netlists{ii},'w');
                if fileID<3

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotWriteToTheFile',netlists{ii});
                end


                fprintf(fileID,'* Source-Drain Forward Diode of %s\n',this.subcircuitName);

                fprintf(fileID,'* Autogenerated netlist at %s\n\n',datetime('now'));


                fprintf(fileID,'.inc %s\n',this.subcircuitFile);

                fprintf(fileID,'.opt reltol=%.4g abstol=%.4g vntol=%.4g gmin=%.4g cshunt=%.4g\n',...
                this.reltol,this.abstol,this.vntol,this.gmin,this.cshunt);
                fprintf(fileID,'\n');



                this.writeCallSubcircuit(fileID,[]);


                for jj=1:length(this.terminals)
                    if this.terminals(jj)~=0

                        fprintf(fileID,'V%d dut%d ',this.terminals(jj),this.terminals(jj));
                        switch this.terminals(jj)
                        case 1

                            fprintf(fileID,'0 pwl(0 %.2f %d %.2f)',this.VdsDiodeIV(1),this.IVsimulationTime,this.VdsDiodeIV(2));
                        case 2

                            fprintf(fileID,'0 -10');
                        case 3

                            fprintf(fileID,'0 0');
                        case 4

                            fprintf(fileID,'dut3 0');
                        case 5

                            fprintf(fileID,'0 {Temperature}');
                        end
                        fprintf(fileID,'\n');
                    end
                end
                fprintf(fileID,'\n');


                fprintf(fileID,'.param Temperature %.2f\n',this.T(ii));
                fprintf(fileID,'\n');


                fprintf(fileID,'.tran %.2g %d',this.IVsimulationStepSize,this.IVsimulationTime);
                fprintf(fileID,'\n\n');


                fprintf(fileID,'.print tran V(dut1)\n');
                fprintf(fileID,'.print tran V(dut2)\n');
                fprintf(fileID,'.print tran V(dut3)\n');

                if find(this.terminals==4)
                    fprintf(fileID,'.print tran V(dut4)\n');
                end
                if find(this.terminals==5)
                    fprintf(fileID,'.print tran V(dut5)\n');
                end

                fprintf(fileID,'.print tran ID(X1)\n');
                fprintf(fileID,'.print tran IG(X1)\n');
                fprintf(fileID,'.print tran IS(X1)\n');
                if find(this.terminals==4)
                    fprintf(fileID,'.print tran IB(dut1)\n');
                end

                fprintf(fileID,'\n.end\n');

                fclose(fileID);
            end
        end

        function[this,netlists]=generateCurrentTail(this)


            if length(this.VceTail)~=1

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBe','VceTail',1);
            end

            if length(this.pulseVgeTail)~=1

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBe','pulseVgeTail',1);
            end

            if length(this.pulsePeriodTail)~=1

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBe','pulsePeriodTail',1);
            end


            [this.terminals,this.flagTermianlsChecked]=this.checkTerminals;


            netlistName=[char(this.subcircuitName),'_currentTail.net'];
            netlists{1}=fullfile(this.netlistPath,netlistName);
            if isfile(netlists{1})

                pm_warning('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:NetlistAlreadyExist',netlists{1});
            end


            fileID=fopen(netlists{1},'w');
            if fileID<3

                pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:CanNotWriteToTheFile',netlists{1});
            end


            fprintf(fileID,'* Tail Current Transient of %s\n',this.subcircuitName);

            fprintf(fileID,'* Autogenerated netlist at %s\n\n',datetime('now'));


            fprintf(fileID,'.inc %s\n',this.subcircuitFile);

            fprintf(fileID,'.opt reltol=%.4g abstol=%.4g vntol=%.4g gmin=%.4g cshunt=%.4g\n',...
            this.reltol,this.abstol,this.vntol,this.gmin,this.cshunt);
            fprintf(fileID,'\n');



            this.writeCallSubcircuit(fileID,[]);


            for jj=1:length(this.terminals)
                if this.terminals(jj)~=0

                    fprintf(fileID,'V%d dut%d ',this.terminals(jj),this.terminals(jj));
                    switch this.terminals(jj)
                    case 1

                        fprintf(fileID,'0 %d',this.VceTail);
                    case 2

                        Td=this.pulsePeriodTail/2;
                        Tr=this.pulsePeriodTail*1e-8;
                        Tf=this.pulsePeriodTail*1e-8;
                        Ton=this.pulsePeriodTail/2;
                        Tp=this.pulsePeriodTail;
                        fprintf(fileID,'0 pulse(0 %.2f %.2g %.2g %.2g %.3g %.2g)',...
                        this.pulseVgeTail,Td,Tr,Tf,Ton,Tp);
                    case 3

                        fprintf(fileID,'0 0');
                    case 4

                        fprintf(fileID,'dut3 0');
                    case 5

                        fprintf(fileID,'0 {Temperature}');
                    end
                    fprintf(fileID,'\n');
                end
            end
            fprintf(fileID,'\n');


            fprintf(fileID,'.param Temperature %.2f\n',27);
            fprintf(fileID,'\n');


            fprintf(fileID,'.tran %.2g %.2g ',this.pulsePeriodTail*1e-3,this.pulsePeriodTail*10);
            fprintf(fileID,'\n\n');


            fprintf(fileID,'.print tran V(dut1)\n');
            fprintf(fileID,'.print tran V(dut2)\n');
            fprintf(fileID,'.print tran V(dut3)\n');

            if find(this.terminals==4)
                fprintf(fileID,'.print tran V(dut4)\n');
            end
            if find(this.terminals==5)
                fprintf(fileID,'.print tran V(dut5)\n');
            end

            fprintf(fileID,'.print tran ID(X1)\n');
            fprintf(fileID,'.print tran IG(X1)\n');
            fprintf(fileID,'.print tran IS(X1)\n');
            if find(this.terminals==4)
                fprintf(fileID,'.print tran IB(dut1)\n');
            end

            fprintf(fileID,'\n.end\n');

            fclose(fileID);

            this.netlists{1+end}=netlistName;
        end
    end

    methods(Access=private)
        function[strings,line]=getExpression(this,raw,expression)


            strings=regexp(raw,expression,'ignorecase','match');
            line=find(~cellfun(@isempty,strings));
            strings=strings(line);
            strings=cellfun(@(x)x{1},strings,'UniformOutput',false);
        end

        function[terminals,flags]=checkTerminals(this)

            terminals=this.terminals;
            flags=this.flagTermianlsChecked;

            if~flags
                if length(terminals)<3

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TheLengthShouldBeGreaterThan','terminals',3);
                end

                if~(any(terminals==1)&&any(terminals==2)&&...
                    any(terminals==3))

                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:TerminalsMustInlcude123');
                end

                if length(terminals)<=length(this.subcircuitNode)
                    terminals=[terminals,zeros(1,length(this.subcircuitNode)-length(terminals))];
                else


                    pm_error('physmod:ee:utilities:spice:semiconductorSubcircuit2lookup:DefinedNodeNumberError')
                end


                flags=1;
            end
        end

        function writeCallSubcircuit(this,fileID,dutPreIndex)




            if isempty(dutPreIndex)
                fprintf(fileID,'X1 ');
            else
                fprintf(fileID,'X%d ',dutPreIndex);
            end
            kk=0;
            pinnames=char(zeros(1,length(nonzeros(this.terminals))));
            for jj=1:length(this.terminals)

                if this.terminals(jj)~=0&&this.terminals(jj)<=5&&...
                    mod(this.terminals(jj),1)==0

                    fprintf(fileID,'dut%d%d ',dutPreIndex,this.terminals(jj));
                    switch this.terminals(jj)
                    case 1
                        pinnames(jj-kk)='D';
                    case 2
                        pinnames(jj-kk)='G';
                    case 3
                        pinnames(jj-kk)='S';
                    case 4
                        pinnames(jj-kk)='B';
                    end
                else

                    kk=kk+1;
                    fprintf(fileID,'unconnected%d%d ',dutPreIndex,kk);
                end
            end
            fprintf(fileID,'%s pinnames: ',this.subcircuitName);
            fprintf(fileID,'%c ',pinnames);
            fprintf(fileID,'\n');
        end
    end
end