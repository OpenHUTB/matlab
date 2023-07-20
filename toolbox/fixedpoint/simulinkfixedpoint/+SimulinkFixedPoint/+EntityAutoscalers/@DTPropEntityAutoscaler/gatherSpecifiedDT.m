function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,~)




    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';
    blkPath=blkObj.getFullName;
    comments={};
    specifiedDTStr='';

    if~isequal(blkObj.PropDataTypeMode,'Specify via dialog')
        specifiedDTStr=blkObj.PropDataTypeMode;
        paramNames.modeStr='PropDataTypeMode';

    elseif~isequal(blkObj.PropScalingMode,'Specify via dialog')
        specifiedDTStr=blkObj.PropScalingMode;
        paramNames.modeStr='PropScalingMode';

    else
        paramNames.modeStr='PropDataType';

        dtContainerStr=blkObj.PropDataType;
        dtSlopeStr=blkObj.PropScaling;

        if SimulinkFixedPoint.DataTypeContainer.isStrFltptType(dtContainerStr)

            specifiedDTStr=dtContainerStr;
        else
            [isValid,val]=evalBlockDT(h,blkPath,dtContainerStr,dtSlopeStr);
            if~isValid
                specifiedDTStr=dtContainerStr;
            else

                if~(isa(val,'Simulink.AliasType'))
                    specifiedDTStr=fixdt(val);
                end
            end
        end
    end
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
end


function[isValid,val]=evalBlockDT(~,blockPath,unevaledContainerStr,unevaledSlopeStr)

    isValid=false;
    val=[];

    blockPath=regexprep(blockPath,'\n',' ');

    if~isempty(regexpi(unevaledContainerStr,'slDataTypeAndScale'))
        unevaledContainerStr(end)=',';
        unevaledContainerStr=sprintf('%s ''%s'')',unevaledContainerStr,blockPath);
    end
    try
        val=slDataTypeAndScale(unevaledContainerStr,unevaledSlopeStr,blockPath);
        isValid=true;

    catch



    end

    if ischar(val)
        if~isempty(regexp(val,'^(int|uint)(8|16|32)$','ONCE'))||SimulinkFixedPoint.DataTypeContainer.isStrFltptType(val)
            val=fixdt(val);
        else
            val=slResolve(val,blockPath);
        end
    end

    if isstruct(val)

        try
            val=eval(fixdt(val));
        catch

        end
    end

    if(isnumerictype(val)||isa(val,'Simulink.NumericType'))
        isValid=true;
    end
end



