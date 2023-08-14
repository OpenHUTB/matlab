function[outputStruct]=generateOutputTable(test,structArrayIndex,SPICEToolVoltages,SPICEToolCurrents,SPICEToolTime,SimscapeVoltages,SimscapeCurrents,SimscapeTime,absErrTol,relErrTol)


































    SPICEToolVoltages1=cell(1,length(test(structArrayIndex).stepValues));
    SPICEToolCurrents1=cell(1,length(test(structArrayIndex).stepValues));
    for stepValueIndex=1:max([1,length(test(structArrayIndex).stepValues)])

        if(test(structArrayIndex).name=="idvgst3")||(test(structArrayIndex).name=="idvgst4")||(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst6tj27")||...
            (test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvgst6tj75")
            k=1;
            if(test(structArrayIndex).name=="idvgst4")||(test(structArrayIndex).name=="idvgst3")
                s2.testname(stepValueIndex,:)="id vs vgs";
            end
            if(test(structArrayIndex).name=="idvgst5tj27")||(test(structArrayIndex).name=="idvgst6tj27")
                s2.testname(stepValueIndex,:)="id vs vgs for tj=27";
            end
            if(test(structArrayIndex).name=="idvgst5tj75")||(test(structArrayIndex).name=="idvgst6tj75")
                s2.testname(stepValueIndex,:)="id vs vgs for tj=75";
            end
            s2.Vds_values(stepValueIndex,:)=test(structArrayIndex).stepValues(stepValueIndex);
            s2.Vgs_values(stepValueIndex,:)=SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1);
            [SPICEToolVoltages1{stepValueIndex}(test(structArrayIndex).sweepNodes,:),IA,~]=unique(SPICEToolVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:));
            for j=1:length(IA)
                SPICEToolCurrents1{stepValueIndex}(1,j)=SPICEToolCurrents{stepValueIndex}(1,IA(j));
            end
            s2.SPICETool_currents(stepValueIndex,:)=interp1(SPICEToolVoltages1{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SPICEToolCurrents1{stepValueIndex}(1,:),...
            SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1),"linear","extrap");
            s2.Simscape_currents(stepValueIndex,:)=interp1(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(1,:),...
            SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1),"linear","extrap");
            difference(stepValueIndex,:)=s2.SPICETool_currents(stepValueIndex,:)-s2.Simscape_currents(stepValueIndex,:);%#ok<AGROW>
            x=1;
            for j=1:length(s2.SPICETool_currents(stepValueIndex,:))
                if~((abs(difference(stepValueIndex,j))<absErrTol)||(abs(difference(stepValueIndex,j)/(-s2.SPICETool_currents(stepValueIndex,j)))<relErrTol))
                    vgs_indices_for_differences_beyond_error_tolerances{stepValueIndex}(k)=j;%#ok<AGROW>
                    k=k+1;
                    x=0;
                end
            end
            if(x==1)
                vgs_indices_for_differences_beyond_error_tolerances{stepValueIndex}=[];
            end
            outputStruct.plots(structArrayIndex).results=struct2table(s2);
            outputStruct.plots(structArrayIndex).results.Vgs_indices_for_differences_beyond_error_tolerances=vgs_indices_for_differences_beyond_error_tolerances';
        end
        if(test(structArrayIndex).name=="idvdst5")||(test(structArrayIndex).name=="idvdst3")||(test(structArrayIndex).name=="idvdst6")||(test(structArrayIndex).name=="idvdst4")
            m=1;
            s3.testname(stepValueIndex,:)="id vs vds";
            s3.Vgs_values(stepValueIndex,:)=test(structArrayIndex).stepValues(stepValueIndex);
            s3.Vds_values(stepValueIndex,:)=SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1);
            [SPICEToolVoltages1{stepValueIndex}(test(structArrayIndex).sweepNodes,:),IA,~]=unique(SPICEToolVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:));
            for j=1:length(IA)
                SPICEToolCurrents1{stepValueIndex}(1,j)=SPICEToolCurrents{stepValueIndex}(1,IA(j));
            end
            s3.SPICETool_currents(stepValueIndex,:)=interp1(SPICEToolVoltages1{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SPICEToolCurrents1{stepValueIndex}(1,:),...
            SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1),"linear","extrap");
            s3.Simscape_currents(stepValueIndex,:)=interp1(SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SimscapeCurrents{stepValueIndex}(1,:),...
            SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end-1),"linear","extrap");
            difference1(stepValueIndex,:)=s3.SPICETool_currents(stepValueIndex,:)-s3.Simscape_currents(stepValueIndex,:);%#ok<AGROW>
            x=1;
            for j=1:length(s3.SPICETool_currents(stepValueIndex,:))
                if~((abs(difference1(stepValueIndex,j))<absErrTol)||(abs(difference1(stepValueIndex,j)/(-s3.SPICETool_currents(stepValueIndex,j)))<relErrTol))
                    vds_indices_for_differences_beyond_error_tolerances{stepValueIndex}(m)=j;%#ok<AGROW>
                    m=m+1;
                    x=0;
                end
            end
            if(x==1)
                vds_indices_for_differences_beyond_error_tolerances{stepValueIndex}=[];
            end
            outputStruct.plots(structArrayIndex).results=struct2table(s3);
            outputStruct.plots(structArrayIndex).results.Vds_indices_for_differences_beyond_error_tolerances=vds_indices_for_differences_beyond_error_tolerances';
        end
        if(test(structArrayIndex).name=="qisst5")||(test(structArrayIndex).name=="qisst3")||(test(structArrayIndex).name=="qisst6")||(test(structArrayIndex).name=="qisst4")
            n=1;
            s4.t(structArrayIndex).testname(stepValueIndex,:)="qiss";
            s4.t(structArrayIndex).Simtime_values(stepValueIndex,:)=SPICEToolTime{1};
            s4.t(structArrayIndex).SPICETool_voltages(stepValueIndex,:)=SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end);
            s4.t(structArrayIndex).Simscape_voltages(stepValueIndex,:)=interp1(SimscapeTime{1},SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,1:end),SPICEToolTime{1},"linear","extrap");
            difference2(stepValueIndex,:)=s4.t(structArrayIndex).SPICETool_voltages(stepValueIndex,:)-s4.t(structArrayIndex).Simscape_voltages(stepValueIndex,:);%#ok<AGROW>
            x=1;
            for j=1:length(s4.t(structArrayIndex).SPICETool_voltages(stepValueIndex,:))
                if~((abs(difference2(stepValueIndex,j))<absErrTol)||(abs(difference2(stepValueIndex,j)/(-s4.t(structArrayIndex).SPICETool_voltages(stepValueIndex,j)))<relErrTol))
                    simtime_indices_for_differences_beyond_error_tolerances{stepValueIndex}(n)=j;%#ok<AGROW>
                    n=n+1;
                    x=0;
                end
            end
            if(x==1)
                simtime_indices_for_differences_beyond_error_tolerances{stepValueIndex}=[];
            end
            outputStruct.plots(structArrayIndex).results=struct2table(s4.t(structArrayIndex));
            outputStruct.plots(structArrayIndex).results.Simtime_indices_for_differences_beyond_error_tolerances=simtime_indices_for_differences_beyond_error_tolerances';
        end
        if(test(structArrayIndex).name=="qosst5")||(test(structArrayIndex).name=="qosst3")||(test(structArrayIndex).name=="qosst6")||(test(structArrayIndex).name=="qosst4")
            p=1;
            s5.t(structArrayIndex).testname(stepValueIndex,:)="qoss";
            s5.t(structArrayIndex).Simtime_values(stepValueIndex,:)=SPICEToolTime{1};
            s5.t(structArrayIndex).SPICETool_voltages(stepValueIndex,:)=SPICEToolVoltages{1}(test(structArrayIndex).sweepNodes,1:end);
            s5.t(structArrayIndex).Simscape_voltages(stepValueIndex,:)=interp1(SimscapeTime{1},SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,1:end),SPICEToolTime{1},"linear","extrap");
            difference3(stepValueIndex,:)=s5.t(structArrayIndex).SPICETool_voltages(stepValueIndex,:)-s5.t(structArrayIndex).Simscape_voltages(stepValueIndex,:);%#ok<AGROW>
            x=1;
            for j=1:length(s5.t(structArrayIndex).SPICETool_voltages(stepValueIndex,:))
                if~((abs(difference3(stepValueIndex,j))<absErrTol)||(abs(difference3(stepValueIndex,j)/(-s5.t(structArrayIndex).SPICETool_voltages(stepValueIndex,j)))<relErrTol))
                    simtime_indices_for_differences_beyond_error_tolerances{stepValueIndex}(p)=j;
                    p=p+1;
                    x=0;
                end
            end
            if(x==1)
                simtime_indices_for_differences_beyond_error_tolerances{stepValueIndex}=[];
            end
            outputStruct.plots(structArrayIndex).results=struct2table(s5.t(structArrayIndex));
            outputStruct.plots(structArrayIndex).results.Simtime_indices_for_differences_beyond_error_tolerances=simtime_indices_for_differences_beyond_error_tolerances';
        end
        if(test(structArrayIndex).name=="breakdownt5")||(test(structArrayIndex).name=="breakdownt3")||(test(structArrayIndex).name=="breakdownt6")||(test(structArrayIndex).name=="breakdownt4")
            q=1;
            s6.t(structArrayIndex).testname(stepValueIndex,:)="breakdown";
            s6.t(structArrayIndex).Vds_values(stepValueIndex,:)=SimscapeVoltages{1}(test(structArrayIndex).sweepNodes,:);
            [SPICEToolVoltages1{stepValueIndex}(1,:),IA,~]=unique(SPICEToolVoltages{stepValueIndex}(1,:));
            for j=1:length(IA)
                SPICEToolCurrents1{stepValueIndex}(1,j)=SPICEToolCurrents{stepValueIndex}(1,IA(j));
            end
            s6.t(structArrayIndex).SPICETool_currents(stepValueIndex,:)=interp1(SPICEToolVoltages1{stepValueIndex}(test(structArrayIndex).sweepNodes,:),-SPICEToolCurrents1{stepValueIndex}(1,:),...
            SimscapeVoltages{stepValueIndex}(test(structArrayIndex).sweepNodes,:),"linear","extrap");
            s6.t(structArrayIndex).Simscape_currents(stepValueIndex,:)=-SimscapeCurrents{stepValueIndex}(1,:);
            difference4(stepValueIndex,:)=s6.t(structArrayIndex).SPICETool_currents(stepValueIndex,:)-s6.t(structArrayIndex).Simscape_currents(stepValueIndex,:);%#ok<AGROW>
            x=1;
            for j=1:length(s6.t(structArrayIndex).SPICETool_currents(stepValueIndex,:))
                if~((abs(difference4(stepValueIndex,j))<absErrTol)||(abs(difference4(stepValueIndex,j)/(-s6.t(structArrayIndex).SPICETool_currents(stepValueIndex,j)))<relErrTol))
                    Vds_indices_for_differences_beyond_error_tolerances{stepValueIndex}(q)=j;%#ok<AGROW>
                    q=q+1;
                    x=0;
                end
            end
            if(x==1)
                Vds_indices_for_differences_beyond_error_tolerances{stepValueIndex}=[];
            end
            outputStruct.plots(structArrayIndex).results=struct2table(s6.t(structArrayIndex));
            outputStruct.plots(structArrayIndex).results.Vds_indices_for_differences_beyond_error_tolerances=Vds_indices_for_differences_beyond_error_tolerances';
        end
    end
end