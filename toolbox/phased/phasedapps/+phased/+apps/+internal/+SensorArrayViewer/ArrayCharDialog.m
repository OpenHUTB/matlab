


classdef ArrayCharDialog<dialogmgr.DCTableReadout


    properties

Application

    end

    properties(Access=private)
        ArrayDirectivity=0
        Span=cell(3,1)
        Prefix=cell(3,1)
    end

    methods
        function obj=ArrayCharDialog(SAV,name)
            if nargin<2
                name=getString(message('phased:apps:arrayapp:ArrayCharacteristics'));
            end
            if nargin<1
                SAV=[];
            end
            obj.Name=name;
            obj.Application=SAV;
        end

    end

    methods(Access=protected)
        function initReadout(obj)

            obj.InitialText={...
            [getString(message('phased:apps:arrayapp:ArrayDirectivity')),':'],...
            getString(message('phased:apps:arrayapp:ArrayCharL1','0.0','0','0'));...
            [getString(message('phased:apps:arrayapp:ArraySpan')),':'],...
            getString(message('phased:apps:arrayapp:ArrayCharL2','0','','0','','0',''));...
            [getString(message('phased:apps:arrayapp:NumElements')),':'],'4'};

            obj.InterColumnSpacing=2;
            obj.InterRowSpacing=2;
            obj.InnerBorderSpacing=4;


            obj.ColumnWidths={140,'max'};
            obj.HorizontalAlignment={'right','center'};


        end
    end

    methods
        function prepareToCalculate(obj)

            obj.updateElement(1,2,'Calculating');
            drawnow('expose');
        end

        function updateReadout(obj)

            curAT=obj.Application.Settings.getCurArrayType();

            nE=curAT.getArraySize();

            SF=curAT.SignalFreqs;
            if curAT.SteeringIsOn
                SA=curAT.SteeringAngles;
            else
                SA=[0;0];
            end

            if isempty(curAT.SteerWeights)
                w=ones(nE,1);
            else
                w=curAT.SteerWeights(:,1);
            end

            obj.ArrayDirectivity=directivity(curAT.ArrayObj,...
            SF(1),SA(:,1),...
            'PropagationSpeed',curAT.PropSpeed,...
            'Weights',w);

            ElementsPosition=getElementPosition(curAT.ArrayObj);



            xspan=abs(max(ElementsPosition(1,:))-min(ElementsPosition(1,:)));
            yspan=abs(max(ElementsPosition(2,:))-min(ElementsPosition(2,:)));
            zspan=abs(max(ElementsPosition(3,:))-min(ElementsPosition(3,:)));

            [xspan,~,obj.Prefix{1}]=engunits(xspan);
            [yspan,~,obj.Prefix{2}]=engunits(yspan);
            [zspan,~,obj.Prefix{3}]=engunits(zspan);

            obj.Span{1}=num2str(round(xspan,2));
            obj.Span{2}=num2str(round(yspan,2));
            obj.Span{3}=num2str(round(zspan,2));

            obj.Span=regexprep(obj.Span,'(\.\d{2})\d*','$1');

            obj.updateColumn(2,{...
            sprintf(getString(message('phased:apps:arrayapp:ArrayCharL1',...
            sprintf('%0.2f',obj.ArrayDirectivity),...
            num2str(SA(1)),...
            num2str(SA(2))))),...
            sprintf(getString(message('phased:apps:arrayapp:ArrayCharL2',...
            num2str(obj.Span{1}),obj.Prefix{1},...
            num2str(obj.Span{2}),obj.Prefix{2},...
            num2str(obj.Span{3}),obj.Prefix{3}))),...
            sprintf('%d',nE),...
            });

            obj.Controls{1,2}.Tag='ArrayChar_ArrayDirectivityTag';
            obj.Controls{2,2}.Tag='ArrayChar_ArraySpanTag';
            obj.Controls{3,2}.Tag='ArrayChar_NumElementsTag';

        end

        function generateReport(obj,mcode)

            curAT=obj.Application.Settings.getCurArrayType();

            nE=curAT.getArraySize();
            if curAT.SteeringIsOn
                SA=curAT.SteeringAngles;
            else
                SA=[0;0];
            end

            mcode.addcr([expandReportStr(obj.Application,'% Steering Angle Azimuth (deg)'),num2str(SA(1))]);
            mcode.addcr([expandReportStr(obj.Application,'% Steering Angle Elevation (deg)'),num2str(SA(2))]);
            mcode.addcr([expandReportStr(obj.Application,'% Directivity at Steering Angle (dBi)'),sprintf('%0.2f',obj.ArrayDirectivity)]);
            mcode.addcr([expandReportStr(obj.Application,['% X-Axis Array Span (',obj.Prefix{1},'m)']),num2str(obj.Span{1})]);
            mcode.addcr([expandReportStr(obj.Application,['% Y-Axis Array Span (',obj.Prefix{2},'m)']),num2str(obj.Span{2})]);
            mcode.addcr([expandReportStr(obj.Application,['% Z-Axis Array Span (',obj.Prefix{3},'m)']),num2str(obj.Span{3})]);
            mcode.addcr([expandReportStr(obj.Application,'% Total Number of Elements'),num2str(nE)]);
        end

    end
end
