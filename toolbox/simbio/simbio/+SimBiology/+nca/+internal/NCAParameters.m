classdef NCAParameters





    properties
        doseSchedule='';
        administrationRoute='';

        Lambda_Z=nan
        R2=nan
        adjusted_R2=nan
        Num_points=nan
        AUC_0_last=nan

        Tlast=nan
        C_max=nan
        C_max_Dose=nan
        T_max=nan
        MRT=nan
        T_half=nan
        AUC_infinity=nan
        AUC_infinity_dose=nan
        AUC_extrap_percent=nan
        CL=nan
        DM=nan
        V_z=nan

doseCountParams
doseAdministrationParams

        partialAreas=struct;
        T_max_usr=struct;
        C_max_usr=struct;

        responseName(1,1)string="";
    end

    methods
        function obj=NCAParameters(doseCount,doseAdministration)
            switch doseCount
            case SimBiology.nca.internal.DoseSchedule.Single
                obj.doseCountParams=SimBiology.nca.internal.singleDoseParameters;
            case SimBiology.nca.internal.DoseSchedule.Multiple
                obj.doseCountParams=SimBiology.nca.internal.multipleDoseParameters;
            otherwise






                obj.doseCountParams=SimBiology.nca.internal.singleDoseParameters;
            end

            switch doseAdministration
            case{SimBiology.nca.AdministrationRoute.IVBolus,SimBiology.nca.AdministrationRoute.IVInfusion}
                obj.doseAdministrationParams=SimBiology.nca.internal.IVDoseParameters;
            case SimBiology.nca.AdministrationRoute.ExtraVascular
                obj.doseAdministrationParams=SimBiology.nca.internal.EVDoseParameters;
            otherwise





                obj.doseAdministrationParams=SimBiology.nca.internal.IVDoseParameters;

            end
        end

        function t=getTable(obj)



            state=warning('query','MATLAB:structOnObject');
            warning('off','MATLAB:structOnObject');

            s=arrayfun(@(x)struct(x),obj);
            t=struct2table(s,'AsArray',true);


            d={obj.doseCountParams};
            t.doseCountParams=[];

            singleDoseType=cellfun(@(x)isa(x,'SimBiology.nca.internal.singleDoseParameters'),d);
            multipleDoseType=cellfun(@(x)isa(x,'SimBiology.nca.internal.multipleDoseParameters'),d);

            e={};

            if all(singleDoseType)
                e(singleDoseType,1)=d(singleDoseType);
            elseif all(multipleDoseType)
                e(multipleDoseType,1)=d(multipleDoseType);
            else
                e(singleDoseType,1)=d(singleDoseType);
                e(~singleDoseType,2)=d(~singleDoseType);
                e(~singleDoseType,1)={SimBiology.nca.internal.singleDoseParameters};
                e(singleDoseType,2)={SimBiology.nca.internal.multipleDoseParameters};
            end

            t_dosing_tmp=cellfun(@(x)struct2table(struct(x)),e,'UniformOutput',false);

            t_dosing=vertcat(t_dosing_tmp{:,1});

            for j=2:size(t_dosing_tmp,2)
                t_dosing=horzcat(t_dosing,vertcat(t_dosing_tmp{:,j}));
            end


            d={obj.doseAdministrationParams};
            t.doseAdministrationParams=[];

            IVDoseType=cellfun(@(x)isa(x,'SimBiology.nca.internal.IVDoseParameters'),d);
            SCDoseType=cellfun(@(x)isa(x,'SimBiology.nca.internal.EVDoseParameters'),d);

            e={};

            if all(IVDoseType)
                e(IVDoseType,1)=d(IVDoseType);
            elseif all(SCDoseType)
                e(SCDoseType,1)=d(SCDoseType);
            else
                e(IVDoseType,1)=d(IVDoseType);
                e(~IVDoseType,2)=d(~IVDoseType);
                e(~IVDoseType,1)={SimBiology.nca.internal.IVDoseParameters};
                e(IVDoseType,2)={SimBiology.nca.internal.EVDoseParameters};
            end

            t_doseType_tmp=cellfun(@(x)struct2table(struct(x)),e,'UniformOutput',false);
            t_doseType=vertcat(t_doseType_tmp{:,1});

            for j=2:size(t_doseType_tmp,2)
                t_doseType=horzcat(t_doseType,vertcat(t_doseType_tmp{:,j}));
            end


            t=horzcat(t,t_dosing,t_doseType);


            if~isempty(fields(t.C_max_usr))
                C_max_usr_VarNames=fields(t.C_max_usr);
                T_max_usr_VarNames=fields(t.T_max_usr);
                assert(numel(C_max_usr_VarNames)==numel(T_max_usr_VarNames));
                for cMi=1:numel(C_max_usr_VarNames)
                    t.(T_max_usr_VarNames{cMi})=[t.T_max_usr.(T_max_usr_VarNames{cMi})]';
                    t.(C_max_usr_VarNames{cMi})=[t.C_max_usr.(C_max_usr_VarNames{cMi})]';
                end
            end
            t.C_max_usr=[];
            t.T_max_usr=[];


            if~isempty(fields(t.partialAreas))
                partialAreaVarNames=fields(t.partialAreas);
                for pAi=1:numel(partialAreaVarNames)
                    t.(partialAreaVarNames{pAi})=[t.partialAreas.(partialAreaVarNames{pAi})]';
                end
            end
            t.partialAreas=[];

            warning(state.state,'MATLAB:structOnObject');
        end
    end
end

