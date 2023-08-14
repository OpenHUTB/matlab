classdef CPModel<handle



    properties(SetAccess=protected,GetAccess=protected)

        model;
    end

    properties(Dependent)
MaxTime
    end

    methods
        function obj=CPModel()


            obj.model=cpopt.Model;



            modelId=obj.model.createModel();
            obj.model.setActiveModel(modelId);
        end

        function delete(obj)

            obj.model.clearAllModels();
        end

        function obj=solve(obj)

            obj.model.solve();
        end

        function obj=addVariable(obj,varName,slope,bias)
            if nargin~=2&&nargin~=4
                warning('CPModel:InvalidArguments',...
                'Invalid number of arguments');
                return;
            end

            if~ischar(varName)
                warning('CPModel:InvalidArguments',...
                'Invalid type of arguments');
                return;
            end

            if nargin==2
                obj.model.addVariable(varName)
            else
                if isfloat(slope)&&isfloat(bias)
                    obj.model.addVariable(varName,slope,bias)
                else
                    warning('CPModel:InvalidArguments',...
                    'Invalid type of arguments')
                end
            end
        end

        function obj=setVariable(obj,varName,slope,bias)
            obj.model.setVariable(varName,slope,bias)
        end

        function obj=setVariableSlope(obj,varName,slope)
            obj.model.setVariableSlope(varName,slope)
        end

        function obj=setVariableBias(obj,varName,bias)
            obj.model.setVariableBias(varName,bias)
        end

        function obj=addConstraint(obj,constraintType,inVars,outVars)
            if nargin~=4
                warning('CPModel:InvalidArguments',...
                'Invalid number of arguments');
                return;
            end

            if~isa(constraintType,'cpopt.internal.ConstraintType')
                warning('CPModel:InvalidArguments',...
                'Invalid type of arguments');
                return;
            end

            conName=char(constraintType);


            if(length(inVars)~=1&&length(inVars)~=2)||...
                length(outVars)~=1
                warning('CPModel:InvalidArguments',...
                'Invalid number of arguments');
                return;
            end

            if length(inVars)==1
                obj.model.addConstraint(conName,inVars{1},outVars{1});
            else
                obj.model.addConstraint(conName,inVars{1},inVars{2},outVars{1});
            end
        end

        function known=isSlopeKnown(obj,varName)
            known=obj.getSlopeForVariable(varName)~=realmin('double');
        end

        function known=isBiasKnown(obj,varName)
            known=obj.getBiasForVariable(varName)~=realmin('double');
        end

        function slope=getSlopeForVariable(obj,varName)
            if~ischar(varName)
                warning('CPModel:InvalidArguments',...
                'Invalid type of arguments');
                return;
            end

            slope=obj.model.getSlope(varName);
        end

        function bias=getBiasForVariable(obj,varName)
            if~ischar(varName)
                warning('CPModel:InvalidArguments',...
                'Invalid type of arguments');
                return;
            end

            bias=obj.model.getBias(varName);
        end

        function set.MaxTime(obj,time)
            obj.model.setMaxTime(time);
        end

        function time=get.MaxTime(obj)
            time=double(obj.model.getMaxTime());
        end

        function timedout=solveTimedOut(obj)
            timedout=obj.model.solveTimedOut();
        end
    end

end


