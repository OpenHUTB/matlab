classdef Utilities<handle





    methods(Static,Hidden)
        function[import,errorMessage]=checkTimetable(data,varargin)

            if nargin>1
                name=varargin{1};
            end
            import=true;
            errorMessage="";
            if istimetable(data)

                if length(data.Properties.VariableNames)>1
                    import=false;
                    if nargin>1
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttMultipleErrorShowName",name)));
                    else
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttMultipleError")));
                    end
                    return;
                end

                variableName=data.Properties.VariableNames{1};
                variableData=data.(variableName);
                isVector=(isa(variableData,'double')||isa(variableData,'single'))...
                &&any(isfinite(variableData),'all')&&isvector(variableData);
                if~isVector
                    import=false;
                    if nargin>1
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttNonVectorErrorShowName",name)));
                    else
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttNonVectorError")));
                    end
                    return;
                end

                isLongEnough=numel(variableData)>3;
                if~isLongEnough
                    import=false;
                    if nargin>1
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttLengthErrorShowName",name)));
                    else
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttLengthError")));
                    end
                    return;
                end

                originalTimes=data.Properties.RowTimes;

                if isdatetime(originalTimes)
                    time=originalTimes-originalTimes(1);
                else
                    time=originalTimes;
                end
                if~wavelet.internal.isuniform(seconds(time))
                    import=false;
                    if nargin>1
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttNonUniformErrorShowName",name)));
                    else
                        errorMessage=string(getString(message("wavelet_tfanalyzer:dialog:ttNonUniformError")));
                    end
                    return;
                end
            end
        end
    end

end
