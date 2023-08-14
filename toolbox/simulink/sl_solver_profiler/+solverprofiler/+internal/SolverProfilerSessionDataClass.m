classdef SolverProfilerSessionDataClass<handle










    properties(Access=public)
Version
Model
Date
    end

    properties(Access=private,Hidden=true)
Data
StatesFileName
    end

    methods(Hidden=true)

        function obj=SolverProfilerSessionDataClass(data,mdl,statesFileName)
            obj.Data=data;
            [ver,~]=version;
            obj.setVersion(ver);
            obj.setDate(datestr(clock,0));
            obj.setModel(mdl);
            obj.setStatesFileName(statesFileName);
        end


        function delete(~)
        end


        function data=getActualDataFromSolverProfilerSessionData(obj)
            data=obj.Data;
        end


        function setVersion(obj,ver)
            obj.Version=ver;
        end


        function setModel(obj,mdl)
            obj.Model=mdl;
        end


        function setDate(obj,date)
            obj.Date=date;
        end


        function setStatesFileName(obj,filename)
            obj.StatesFileName=filename;
        end


        function mdl=getModel(obj)
            mdl=obj.Model;
        end


        function statesFileName=getStatesFileName(obj)
            statesFileName=obj.StatesFileName;
        end

    end
end