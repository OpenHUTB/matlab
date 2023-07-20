function res=getBlockMaskTypeAttributes(h,blkObj,pathItem)%#ok






    if strcmp(pathItem,'1')
        res.IsSettableInSomeSituations=false;
        res.DisplayDataTypeStr='Inherit: Same as table';
    else
        if strcmp(blkObj.TableIsInput,'on')
            res.IsSettableInSomeSituations=false;
            res.DisplayDataTypeStr='Inherit: Same as table port';
        else
            res.IsSettableInSomeSituations=true;
            res.DataTypeEditField_ParamName='TableDataTypeStr';
            res.LockScaling_ParamName='LockScale';
        end
    end


