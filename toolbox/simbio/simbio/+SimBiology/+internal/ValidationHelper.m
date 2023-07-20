classdef ValidationHelper









    methods(Static)
        function errorUnlessValidString(value)
            if~SimBiology.internal.ValidationHelper.isValidString(value)
                error(message('SimBiology:ValidationHelper:InvalidString'));
            end
        end

        function value=emptyOrValidatestring(value,validStrings)
            if isempty(value)
                value='';
            elseif nargin==1
                validateattributes(value,{'char'},{'row'});
            else
                value=validatestring(value,validStrings);
            end
        end

        function emptyOrValidateattributes(value,varargin)

            if isequal(value,[])||(isempty(value)&&isa(value,'handle'))
                return
            end
            validateattributes(value,varargin{:});
        end

        function tf=isValidString(string)




            tf=ischar(string)&&(isrow(string)||isequal(string,''));
        end

        function validateListOfStrings(strings)
            strings=convertStringsToChars(strings);
            if~SimBiology.internal.ValidationHelper.isValidListOfStrings(strings)
                error(message('SimBiology:ValidationHelper:InvalidListOfStrings'));
            end
        end

        function tf=isValidListOfStrings(strings)





            if~iscell(strings)
                strings={strings};
            end
            tf=iscellstr(strings)&&isvector(strings)&&...
            all(cellfun(@SimBiology.internal.ValidationHelper.isValidString,strings));
        end

        function strings=standardizeListOfStrings(strings)






            if isstring(strings)
                strings=cellstr(strings);
            elseif~iscell(strings)
                strings={strings};
            end
        end

        function validateLogicalScalarCompatible(value)

            validateattributes(value,{'logical','numeric'},{'scalar','nonnan','real'});
        end

        function varargout=deepConvertStringsToChars(varargin)







            [varargout{1:nargin}]=convertStringsToChars(varargin{:});
            for i=1:numel(varargout)
                if iscell(varargout{i})
                    [varargout{i}{:}]=SimBiology.internal.ValidationHelper.deepConvertStringsToChars(varargout{i}{:});
                elseif isstruct(varargout{i})
                    names=fieldnames(varargout{i});
                    for j=1:numel(varargout{i})
                        for k=1:numel(names)
                            varargout{i}(j).(names{k})=SimBiology.internal.ValidationHelper.deepConvertStringsToChars(varargout{i}(j).(names{k}));
                        end
                    end
                end
            end
        end
    end
end