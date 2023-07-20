classdef IntegerVectorToStringConverter<handle





    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=IntegerVectorToStringConverter()
        end
    end

    methods
        function compactString=convert(this,values)
            validateattributes(values,{'numeric'},{'vector','integer','increasing'});
            isColumn=iscolumn(values);
            if isColumn&&~isscalar(values)

                compactString=this.convert(values');
                compactString(end+1)='''';
            else
                valueGroups=FunctionApproximation.internal.getIntegerGroups(values);
                nGroups=numel(valueGroups);
                compactString='[';
                for ii=1:nGroups
                    if numel(valueGroups{ii})<3

                        for jj=1:numel(valueGroups{ii})
                            compactString=sprintf('%s%s ',compactString,int2str(valueGroups{ii}(jj)));
                        end
                    else

                        first=valueGroups{ii}(1);
                        last=valueGroups{ii}(end);
                        spacing=valueGroups{ii}(2)-valueGroups{ii}(1);
                        firstValueString=int2str(first);
                        lastValueString=int2str(last);
                        if spacing==1


                            compactString=sprintf('%s%s:%s ',compactString,...
                            firstValueString,lastValueString);
                        else


                            spacingValueString=int2str(spacing);
                            compactString=sprintf('%s%s:%s:%s ',compactString,...
                            firstValueString,spacingValueString,lastValueString);
                        end
                    end
                end
                compactString(end)=']';




                if nGroups==1
                    try





                        evalc(compactString(2:end-1));
                        compactString=compactString(2:end-1);
                    catch

                    end
                end

                if~fixed.internal.type.isAnyDouble(values)

                    compactString=[class(values),'(',compactString,')'];
                end
            end
        end
    end
end


