classdef PropertyValueValidator<handle&matlab.mixin.SetGet








    methods(Access=public,Hidden)


        function varargout=set(this,varargin)


            propName=varargin{1};
            if nargin==2&&ischar(propName)
                if hasPropertySet(this,propName)
                    varargout{1}=this.getPropertySet(propName);
                else
                    varargout{1}=[];
                end
            else
                if nargout
                    varargout{1}=set@matlab.mixin.SetGet(this,varargin{:});
                else
                    set@matlab.mixin.SetGet(this,varargin{:});
                end
            end
        end


        function value=validateEnum(this,propName,value)

            value=convertStringsToChars(value);

            validateattributes(value,{'char'},{},'',propName);

            validValues=getPropertySet(this,propName);

            ind=find(ismember(lower(validValues),lower(value))==1,1);
            if isempty(ind)&&hasPropertyObsoleteSet(this,propName)

                obsoleteValues=getPropertyObsoleteSet(this,propName);
                ind=find(ismember(lower(obsoleteValues),lower(value))==1,1);
                if ind>numel(validValues)
                    value=obsoleteValues{ind};
                    return;
                end
            end


            if isempty(ind)
                validValues=string(validValues);
                validValuesStr='';
                for i=1:numel(validValues)
                    validValuesStr=[validValuesStr,newline,'    ','''',char(validValues(i)),''''];%#ok<AGROW>
                end
                dsp.webscopes.internal.BaseWebScope.localError('invalidEnumValue',value,propName,validValuesStr);
            end

            value=validValues{ind};
        end
    end



    methods(Access=protected)

        function flag=hasPropertySet(this,propName)
            flag=isprop(this,[propName,'Set']);
        end

        function set=getPropertySet(this,propName)
            set=this.([propName,'Set']);
        end

        function flag=hasPropertyObsoleteSet(this,propName)
            flag=isprop(this,[propName,'ObsoleteSet']);
        end

        function set=getPropertyObsoleteSet(this,propName)
            set=this.([propName,'ObsoleteSet']);
        end
    end
end
