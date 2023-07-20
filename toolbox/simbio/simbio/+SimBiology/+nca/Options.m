classdef Options






    properties(Dependent,Hidden=true)
independentVariableColumnName
    end

    properties
        IVDoseColumnName(1,:)char='';
        EVDoseColumnName(1,:)char='';
        concentrationColumnName(1,:)string="CONC";
        timeColumnName(1,:)char='TIME';
        groupColumnName(1,:)char='';
        idColumnName(1,:)char='';
        infusionRateColumnName(1,:)char='';


        LOQ=0;


        AdministrationRoute SimBiology.nca.AdministrationRoute=SimBiology.nca.AdministrationRoute.IVBolus;



        TAU=NaN;


        SparseData=false;








        Lambda_Z_Time_Min_Max=[NaN,NaN];






        PartialAreas={[]};







        C_max_ranges={[]};
    end

    properties(Hidden=true)




        lambdaZ_Tolerance=1e-4;
    end

    methods
        function value=get.independentVariableColumnName(obj)
            value=obj.timeColumnName;
        end

        function obj=set.independentVariableColumnName(obj,value)
            obj.timeColumnName=value;
        end
    end
end

