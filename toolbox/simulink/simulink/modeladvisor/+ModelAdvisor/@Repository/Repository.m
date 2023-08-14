classdef Repository<handle
    properties(Hidden=true)

        keepConnectionAlive=true;
    end

    properties

        FileLocation='';


        DatabaseHandle=[];


        MAObj={};


        SID='';
    end

    methods





        function obj=Repository(input,varargin)
            PerfTools.Tracer.logMATLABData('MAGroup','Database Obj Constructor',true);

            if isa(input,'Simulink.ModelAdvisor')
                obj.MAObj=input;
                obj.SID=Simulink.ID.getSID(obj.MAObj.System);
                if nargin>1&&ischar(varargin{1})
                    obj.connect(varargin{1});
                else
                    obj.connect(fullfile(input.getWorkDir('CheckOnly'),'ModelAdvisorData'));
                end
            elseif ischar(input)
                obj.connect(input);
            else
                DAStudio.error('ModelAdvisor:engine:WrongConstructor','Advisor.Repository');
            end

            PerfTools.Tracer.logMATLABData('MAGroup','Database Obj Constructor',false);
        end

        function set.keepConnectionAlive(obj,valueProposed)
            originalValue=obj.keepConnectionAlive;
            obj.keepConnectionAlive=valueProposed;

            if originalValue&&~valueProposed
                obj.disconnect;
            end
        end
    end

    methods(Static=true)
        function tablename=convertTablename(input)
            switch lower(input)
            case{'allrptinfo','geninfo'}
                tablename='mdladv.ReportsInfo';
            case 'mdladvinfo'
                tablename='mdladv.MdladvInfo';
            case 'parallelinfo'
                tablename='mdladv.ParallelInfo';
            case 'resultdetails'
                tablename='mdladv.ResultDetails';
            otherwise
                DAStudio.error('ModelAdvisor:engine:UnkownTableSpecified',input);
            end
        end
    end
end

