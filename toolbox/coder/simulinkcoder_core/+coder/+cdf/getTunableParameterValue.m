function retVal=getTunableParameterValue(modelName,paramName,paramPath,data)





    retVal{1}=false;
    retVal{2}=[];
    retVal=coder.internal.getDataObjectPropertyValue(modelName,paramName,data);
    if~retVal{1}&&~isempty(paramPath)&&ischar(paramPath)
        [path,key]=fileparts(paramPath);
        blkType=get_param(path,'BlockType');
        if matches(blkType,{'Lookup_n-D','Interpolation_n-D','LookupNDDirect'})&&matches(key,{'maxIndex','dimSizes'})
            if(matches(blkType,{'Lookup_n-D','LookupNDDirect'})&&matches(get_param(path,'DataSpecification'),'Table and breakpoints'))||...
                (matches(blkType,{'Interpolation_n-D'})&&matches(get_param(path,'TableSpecification'),'Explicit values'))
                tabKey='Table';
            else
                tabKey='LookupTableObject';
            end
            tabData=get_param(path,tabKey);
            [found,lutObj]=coder.cdf.evalExpCDF(modelName,tabData);
            if~found
                lutObj=coder.cdf.evalSubsysExpr(modelName,path,tabKey);
            end
            if~isempty(lutObj)
                if isa(lutObj,'Simulink.LookupTable')
                    tbVal=lutObj.Table.Value;
                elseif isa(lutObj,'Simulink.Parameter')
                    tbVal=lutObj.Value;
                elseif~isempty(lutObj)
                    tbVal=lutObj;
                else
                    tbVal=[];
                end
                if isempty(tbVal)
                    retVal{1}=false;
                    retVal{2}=[];
                else
                    retVal{1}=true;

                    retVal{2}=size(tbVal)-1;
                    if matches(key,{'dimSizes'})




                        for i=1:numel(retVal{2})
                            if i==1
                                retVal{2}(1)=1;
                            elseif i==2
                                retVal{2}(2)=retVal{2}(2);
                            else
                                retVal{2}(i)=retVal{2}(i-1)*retVal{2}(i);
                            end
                        end
                    end
                end
            end
        elseif~isempty(path)&&~isempty(key)
            try
                valueChar=get_param(path,key);

                retVal=coder.internal.getDataObjectPropertyValue(modelName,valueChar,data);
                if~retVal{1}
                    value=evalinGlobalScope(modelName,valueChar);
                else
                    value=retVal{2};
                end
            catch

                value=coder.cdf.evalSubsysExpr(modelName,path,key);
            end
            retVal{1}=true;
            if isa(value,'Simulink.data.Expression')
                try
                    value=eval(value.ExpressionString);
                catch
                    retVal{1}=false;
                    value=[];
                end
            end
            if isempty(value)
                retVal={false,[]};
            else
                retVal{2}=value;
            end
        else
            retVal{1}=false;
            retVal{2}=[];
        end
    end
end


