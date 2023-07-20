classdef SurgeArrester_class<ConvClass&handle



    properties

        OldParam=struct(...
        'ProtectionVoltage',[],...
        'Columns',[],...
        'ReferenceCurrent',[],...
        'Segment1',[],...
        'Segment2',[],...
        'Segment3',[]...
        )


        OldDropdown=struct(...
        'Measurements',[],...
        'BreakLoop',[]...
        )


        NewDirectParam=struct(...
        'rseries',[],...
        'c',[]...
        )


        NewDerivedParam=struct(...
        'vln',[],...
        'vnu',[],...
        'alphaNormal',[],...
        'rLeak',[],...
        'rUpturn',[]...
        )


        NewDropdown=struct(...
        'prm',[]...
        )


        BlockOption={...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Surge Arrester'
        NewPath='elec_conv_SurgeArrester/SurgeArrester'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.rseries=0;
            obj.NewDirectParam.c=0;
        end


        function obj=SurgeArrester_class(Segment1,Segment2,Segment3,ProtectionVoltage,ReferenceCurrent,Columns)
            if nargin>0
                obj.OldParam.Segment1=Segment1;
                obj.OldParam.Segment2=Segment2;
                obj.OldParam.Segment3=Segment3;
                obj.OldParam.ProtectionVoltage=ProtectionVoltage;
                obj.OldParam.ReferenceCurrent=ReferenceCurrent;
                obj.OldParam.Columns=Columns;
            end
        end

        function obj=objParamMappingDerived(obj)

            k1=ConvClass.mapDirect(obj.OldParam.Segment1,1);
            k2=ConvClass.mapDirect(obj.OldParam.Segment2,1);
            k3=ConvClass.mapDirect(obj.OldParam.Segment3,1);
            alpha1=ConvClass.mapDirect(obj.OldParam.Segment1,2);
            alpha2=ConvClass.mapDirect(obj.OldParam.Segment2,2);
            alpha3=ConvClass.mapDirect(obj.OldParam.Segment3,2);
            Vref=obj.OldParam.ProtectionVoltage;
            Iref=obj.OldParam.ReferenceCurrent;
            n=obj.OldParam.Columns;

            p1=Iref*n/(k1^alpha1);
            p2=Iref*n/(k2^alpha2);
            p3=Iref*n/(k3^alpha3);

            ic1=p1*((p1/p2)^(alpha1/(alpha2-alpha1)));
            ic2=p2*((p2/p3)^(alpha2/(alpha3-alpha2)));
            vc1=Vref*k2*(ic1/(n*Iref)).^(1/alpha2);
            vc2=Vref*k2*(ic2/(n*Iref)).^(1/alpha2);

            iEndOfLeak=ic1*1e-3;
            vEndOfLeak=Vref*k1*(iEndOfLeak/(n*Iref))^(1/alpha1);
            r1=vEndOfLeak/iEndOfLeak;
            vEndOfNormal=vc2;
            r3=Vref*k3/(alpha3*n*Iref)*(ic2/n/Iref)^((1-alpha3)/alpha3);


            VsampleSeg=linspace(vEndOfLeak,vEndOfNormal,20);
            IsampleSeg=zeros(1,length(VsampleSeg));
            for temp=1:length(VsampleSeg)
                Vsample=VsampleSeg(temp);
                if Vsample<=vc1
                    Isample=p1*(Vsample/Vref)^alpha1;
                else
                    Isample=p2*(Vsample/Vref)^alpha2;
                end
                IsampleSeg(temp)=Isample;
            end

            vln=vEndOfLeak;
            vnu=vEndOfNormal;
            rLeak=r1;
            rUpturn=r3;


            alpha0=alpha2;
            lb=alpha0*0.01;
            ub=alpha0*2;
            alphaVec=linspace(lb,ub,1000);
            errorVec=zeros(1,length(alphaVec));
            for temp=1:length(alphaVec)
                alpha=alphaVec(temp);
                k=1/(alpha*rUpturn*vnu^(alpha-1));
                c1=vln/rLeak-(vln^alpha)/(alpha*rUpturn*vnu^(alpha-1));
                errorVec(temp)=sum((k*(VsampleSeg).^alpha+c1-IsampleSeg).^2);
            end
            alpha=alphaVec(errorVec==min(errorVec));

            obj.NewDerivedParam.vln=vln;
            obj.NewDerivedParam.vnu=vnu;
            obj.NewDerivedParam.alphaNormal=alpha;
            obj.NewDerivedParam.rLeak=rLeak;
            obj.NewDerivedParam.rUpturn=rUpturn;

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            obj.NewDropdown.prm='2';


            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Branch voltage'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltage');
            case 'Branch current'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch current');
            case 'Branch voltage and current'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltage and current');
            end
        end
    end

end
