classdef(Abstract)JSServiceFeature<handle&matlab.mixin.internal.Scalar

    properties(SetAccess=private)
        log(1,1)logical=false;
        debug(1,1)logical=false;
        queryTimeout(1,1)double=20;
        queryClientId double{matlab.internal.validation.mustBeScalarOrEmpty,mustBePositive}=[];
    end

    properties(Hidden,SetAccess=private)
instance
    end

    events
FeatureUpdate
    end

    methods
        function self=JSServiceFeature()

            mc=metaclass(self);
            assert(mc.Sealed,'%s must be Sealed',mc.Name);

            nonCompliantProps=mc.PropertyList.findobj(...
            '-not','DefiningClass',?experiments.internal.JSServiceFeature,...
            '-not','-function','SetAccess',@(a)isequal(a,{?experiments.internal.JSServiceFeature}));
            assert(isempty(nonCompliantProps),'Properties of %s must be SetAccess={?%s} (use the ''set'' method instead):\n    %s',...
            mc.Name,mfilename('class'),strjoin({nonCompliantProps.Name}));

            deleteMethod=mc.MethodList.findobj('Name','delete','Access','private');
            assert(~isempty(deleteMethod),'%s must define an Access=private delete method (to prevent manual deletion)',mc.Name);
        end

        function previous=set(self,varargin)

            mc=metaclass(self);
            p=inputParser();
            for field=string({mc.PropertyList.Name})
                p.addParameter(field,self.(field));
            end
            p.parse(varargin{:});


            previous=struct();
            update=rmfield(p.Results,p.UsingDefaults);
            for field=string(fieldnames(update))'
                if~isequal(self.(field),update.(field))
                    previous.(field)=self.(field);
                    self.(field)=update.(field);
                    update.(field)=self.(field);
                else
                    update=rmfield(update,field);
                end
            end


            hidden=intersect(fieldnames(update),{mc.PropertyList.findobj('Hidden',true).Name});
            previous=rmfield(previous,hidden);
            update=rmfield(update,hidden);


            if~isempty(fieldnames(update))
                self.notify('FeatureUpdate',experiments.internal.JSServiceFeatureUpdate(update,previous));
            end
        end

        function s=struct(self)

            for field=string(properties(self))'
                s.(field)=self.(field);
            end
        end
    end

    methods(Static)
        function s=toJSON(s)

            for field=string(fieldnames(s))'
                value=s.(field);
                if isempty(value)

                    s.(field)=false;
                elseif~isscalar(value)||~isnumeric(value)&&~islogical(value)&&~isstring(value)

                    s.(field)=NaN;
                end
            end
        end
    end
end
