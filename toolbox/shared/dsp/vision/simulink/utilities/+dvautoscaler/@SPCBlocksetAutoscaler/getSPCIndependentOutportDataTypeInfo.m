function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr]=getSPCIndependentOutportDataTypeInfo(h,blkObj,supportsUnsigned,maxValue)%#ok




    signValStr='';
    wlValueStr='';
    flValueStr='';
    flDlgStr='';
    dtypeModeStr=blkObj.dataType;

    if strcmpi(dtypeModeStr,'Fixed-point')
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr]=...
        getFixptDTypeReturnVals(blkObj,supportsUnsigned,maxValue,[]);

    elseif strcmpi(dtypeModeStr,'User-defined')
        specifiedDTStr=blkObj.udDataType;
        blockPath=regexprep(blkObj.getFullName,'\n',' ');
        rslvdUsrDefDataType=slResolve(blkObj.udDataType,blockPath);


        if isa(rslvdUsrDefDataType,'Simulink.NumericType')||isa(rslvdUsrDefDataType,'embedded.numerictype')

            if isfixed(rslvdUsrDefDataType)
                signValStr=rslvdUsrDefDataType.Signedness;
                wlValueStr=num2str(rslvdUsrDefDataType.WordLength);
                if strcmpi(blkObj.fracBitsMode,'Best precision')

                    flDlgStr='';
                    flValueStr='Best precision';
                    specifiedDTStr=getFixdtStr(signValStr,wlValueStr,'');
                else

                    flDlgStr='numFracBits';
                    flValueStr=blkObj.(flDlgStr);
                    specifiedDTStr=getFixdtStr(signValStr,wlValueStr,flValueStr);
                end
            end

        elseif isstruct(rslvdUsrDefDataType)&&isfield(rslvdUsrDefDataType,'Class')

            classStr=rslvdUsrDefDataType.Class;
            if strcmpi(classStr,'double')||strcmpi(classStr,'single')

                specifiedDTStr=classStr;
            elseif strcmpi(classStr,'fix')||strcmpi(classStr,'frac')

                [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr]=...
                getFixptDTypeReturnVals(blkObj,supportsUnsigned,maxValue,rslvdUsrDefDataType);
            end
        end

    else

        specifiedDTStr=dtypeModeStr;
    end



    function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr]=getFixptDTypeReturnVals(blkObj,supportsUnsigned,maxValue,rslvdUserDefDTStruct)

        dtInfo=dspGetFixptSourceDTInfo(blkObj,supportsUnsigned,maxValue);
        wlValueStr=num2str(dtInfo.DataTypeWordLength);

        if supportsUnsigned&&~(dtInfo.DataTypeIsSigned)
            signValStr='Unsigned';
        else
            signValStr='Signed';
        end

        if isFLExplicitlySpecified(blkObj,rslvdUserDefDTStruct)

            flDlgStr='numFracBits';
            flValueStr=blkObj.(flDlgStr);
            specifiedDTStr=getFixdtStr(signValStr,wlValueStr,flValueStr);
        else

            flDlgStr='';
            flValueStr='Best precision';
            specifiedDTStr=getFixdtStr(signValStr,wlValueStr,'');
        end



        function result=isFLExplicitlySpecified(blkObj,rslvdUserDefDTStruct)
            if strcmpi(blkObj.dataType,'Fixed-point')
                result=~strcmpi(blkObj.fracBitsMode,'Best precision');
            else





                result=...
                (~isempty(rslvdUserDefDTStruct)&&...
                isstruct(rslvdUserDefDTStruct)&&...
                isfield(rslvdUserDefDTStruct,'Class')&&...
                strcmpi(rslvdUserDefDTStruct.Class,'fix')&&...
                ~strcmpi(blkObj.fracBitsMode,'Best precision'));
            end



            function specifiedDTStr=getFixdtStr(signValStr,wlValueStr,flValueStr)
                if isempty(flValueStr)

                    if strcmpi(signValStr,'unsigned')
                        specifiedDTStr=strcat('fixdt(0,',wlValueStr,')');
                    else
                        specifiedDTStr=strcat('fixdt(1,',wlValueStr,')');
                    end
                else

                    if strcmpi(signValStr,'unsigned')
                        specifiedDTStr=strcat('fixdt(0,',wlValueStr,',',flValueStr,')');
                    else
                        specifiedDTStr=strcat('fixdt(1,',wlValueStr,',',flValueStr,')');
                    end
                end
