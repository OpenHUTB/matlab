function dimensionObj=createDimensionObject(namedElement,dimension)









    dimensionObj=namedElement.createIntoDimension(struct('metaClass','dds.datamodel.types.Dimension'));
    dimensionObj.FixedSize=1;
    if ischar(dimension)

        strippedValue=regexprep(dimension,'(^\s*\[)*([^\]]*)(\])*','$2');
        splitStr=strsplit(strippedValue,'(,)|(\s)','DelimiterType','RegularExpression');
        mdl=mf.zero.getModel(namedElement);
        for i=1:numel(splitStr)
            dimensionObj.MaxLength.add(dimensionObj.createIntoMaxLength(struct('metaClass','dds.datamodel.types.ValueOrConst')));
            dimensionObj.CurLength.add(dimensionObj.createIntoMaxLength(struct('metaClass','dds.datamodel.types.ValueOrConst')));
            dimensionObj.MaxLength(i).Unlimited=false;
            dimensionObj.CurLength(i).Unlimited=false;
            typeObj=dds.internal.getTypeBasedOnFullName(splitStr{i},mdl);
            if~isempty(typeObj)
                dimensionObj.MaxLength(i).ValueConst=typeObj;
                dimensionObj.CurLength(i).ValueConst=typeObj;
            else
                dimensionObj.MaxLength(i).Value=str2double(splitStr{i});
                dimensionObj.CurLength(i).Value=dimensionObj.MaxLength(i).Value;
            end
        end
    else
        for i=1:numel(dimension)
            dimensionObj.MaxLength.add(dimensionObj.createIntoMaxLength(struct('metaClass','dds.datamodel.types.ValueOrConst')));
            dimensionObj.CurLength.add(dimensionObj.createIntoMaxLength(struct('metaClass','dds.datamodel.types.ValueOrConst')));
            dimensionObj.MaxLength(i).Unlimited=false;
            dimensionObj.CurLength(i).Unlimited=false;
            dimensionObj.MaxLength(i).Value=dimension(i);
            dimensionObj.CurLength(i).Value=dimension(i);
        end
    end
end
