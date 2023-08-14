classdef StateflowHelper<handle




    methods(Static,Access=public)

        function createReceiverChart(chart,msgName,typename)






















            msgName=arxml.arxml_private('p_create_aridentifier',...
            msgName,namelengthmax);

            message=Stateflow.Message(chart);
            message.Name=msgName;
            message.Scope='input';
            message.DataType=typename;
            message.UseInternalQueue=false;

            data=Stateflow.Data(chart);
            data.Name='msgData_out';
            data.Scope='output';
            data.DataType=typename;


            s=Stateflow.Junction(chart);
            s.Position.Center=[50,50];


            s(end+1)=Stateflow.Junction(chart);
            s(end).Position.Center=[250,50];



            s(end+1)=Stateflow.Junction(chart);
            s(end).Position.Center=[50,150];


            t=Stateflow.Transition(chart);
            t.SourceOClock=6;
            t.Destination=s(1);
            t.DestinationOClock=12;
            xsource=s(1).Position.Center(1);
            ysource=s(1).Position.Center(2)-45;
            t.SourceEndPoint=[xsource,ysource];
            t.MidPoint=[xsource,ysource+15];



            t(end+1)=Stateflow.Transition(chart);
            t(end).Source=s(1);
            t(end).Destination=s(2);
            t(end).SourceOClock=3;
            t(end).DestinationOClock=9;
            t(end).LabelString=sprintf('%s',msgName);


            t(end+1)=Stateflow.Transition(chart);
            t(end).Source=s(2);
            t(end).Destination=s(3);
            t(end).SourceOClock=8;
            t(end).DestinationOClock=2;
            t(end).LabelString=sprintf('{%s = %s.data;}',data.Name,message.Name);



            t(end+1)=Stateflow.Transition(chart);
            t(end).Source=s(1);
            t(end).Destination=s(3);
            t(end).SourceOClock=6;
            t(end).DestinationOClock=12;
        end

        function createSenderChart(chart,msgName,typename,dimensions)












            msgName=arxml.arxml_private('p_create_aridentifier',...
            msgName,namelengthmax);

            message=Stateflow.Message(chart);
            message.Name=msgName;
            message.Scope='output';
            message.DataType=typename;

            message.Props.Array.Size=dimensions;



            s=Stateflow.Junction(chart);
            s.Position.Center=[50,50];


            t=Stateflow.Transition(chart);
            t.SourceOClock=6;
            t.Destination=s(1);
            t.DestinationOClock=12;
            xsource=s(1).Position.Center(1);
            ysource=s(1).Position.Center(2)-45;
            t.SourceEndPoint=[xsource,ysource];
            t.MidPoint=[xsource,ysource+15];
        end

    end
end


