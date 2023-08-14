classdef NMFileDef<hgsetget


















































    properties(Access=public)
        CompartmentLabel='';
        ContinuousCovariateLabels={};
        DateLabel='';
        DependentVariableLabel='';
        DoseLabel='';
        DoseIntervalLabel='';
        DoseRepeatLabel='';
        EventIDLabel='';
        GroupLabel='';
        MissingDependentVariableLabel='';
        RateLabel='';
        TimeLabel='';
    end

    properties(SetAccess=private)
        Type='NMFileDef';
    end


    methods

        function obj=NMFileDef(varargin)
            if nargin>0
                set(obj,varargin{:});
            end
        end

        function set.CompartmentLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'CompartmentLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_CompartmentLabel',msg.getString());
            end
            obj.CompartmentLabel=value;
        end

        function set.ContinuousCovariateLabels(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyCovariateValue(value,'ContinuousCovariateLabels');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_ContinuousCovariateLabels',msg.getString());
            end

            if ischar(value)&&strcmp(value,'')
                value={};
            elseif ischar(value)
                value={value};
            end

            obj.ContinuousCovariateLabels=value;
        end

        function set.DateLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'DateLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_DateLabel',msg.getString());
            end

            obj.DateLabel=value;
        end

        function set.DependentVariableLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'DependentVariableLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_DependentVariableLabel',msg.getString());
            end

            obj.DependentVariableLabel=value;
        end

        function set.DoseLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'DoseLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_DoseLabel',msg.getString());
            end

            obj.DoseLabel=value;
        end

        function set.DoseIntervalLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'DoseIntervalLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_DoseIntervalLabel',msg.getString());
            end

            obj.DoseIntervalLabel=value;
        end

        function set.DoseRepeatLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'DoseRepeatLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_DoseRepeatLabel',msg.getString());
            end

            obj.DoseRepeatLabel=value;
        end

        function set.EventIDLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'EventIDLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_EventIDLabel',msg.getString());
            end

            obj.EventIDLabel=value;
        end

        function set.GroupLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'GroupLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_GroupLabel',msg.getString());
            end

            obj.GroupLabel=value;
        end

        function set.MissingDependentVariableLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'MissingDependentVariableLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_MissingDependentVariableLabel',msg.getString());
            end

            obj.MissingDependentVariableLabel=value;
        end

        function set.RateLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'RateLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_RateLabel',msg.getString());
            end

            obj.RateLabel=value;
        end

        function set.TimeLabel(obj,value)
            msg=SimBiology.internal.Data.NMFileDef.verifyValue(value,'TimeLabel');
            if~isempty(msg)
                error('SimBiology:NMFileDef_Invalid_TimeLabel',msg.getString());
            end

            obj.TimeLabel=value;
        end

    end

    methods(Static)

        function msg=verifyValue(value,label)
            msg=[];

            if~ischar(value)&&~isnumeric(value)
                msg=message('SimBiology:sbionmimport:InvalidValue1',label,label);
            elseif isnumeric(value)
                if length(value)>1
                    msg=message('SimBiology:sbionmimport:InvalidValue2',label,label);
                elseif~isreal(value)||~isfinite(value)||(value<1)||(floor(value)~=value)
                    msg=message('SimBiology:sbionmimport:InvalidValue3',label,label);
                end
            end
        end

        function msg=verifyCovariateValue(value,label)
            msg='';

            if~ischar(value)&&~iscellstr(value)&&~isnumeric(value)
                msg=message('SimBiology:sbionmimport:InvalidCovariate1',label,label);
            elseif isnumeric(value)
                if~isempty(find(value<1,1))
                    msg=message('SimBiology:sbionmimport:InvalidCovariate2',label,label);
                end

                for i=1:length(value)
                    if floor(value(i))~=value(i)
                        msg=message('SimBiology:sbionmimport:InvalidCovariate3',label,label);
                        return;
                    end
                end
            end
        end

    end
end