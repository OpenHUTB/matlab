function[maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,...
    modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)




    fixdtSignValStr='1';
    maskSignValStr='Signed';


    switch pathItem
    case 'Coefficients'
        paramPrefixStr='firstCoeff';
        maskSignValStr=blkObj.firstCoeffSignedness;
        fixdtSignValStr=maskSignValStr2fixdtSignValStr(h,maskSignValStr);

    case{'Product output','Accumulator'}
        if strcmpi(pathItem,'Product output')
            paramPrefixStr='prodOutput';
        else
            paramPrefixStr='accum';
        end











        if isPostCompiledSate(blkObj)
            if~strcmp(blkObj.filtSrc,'Specify via dialog')



                fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,[1,2]);
                maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);
            else


                coeff_maskSignValStr=blkObj.firstCoeffSignedness;
                if strcmp(coeff_maskSignValStr,'Signed')
                    fixdtSignValStr='1';
                else
                    fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,1);
                end
                maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);
            end
        else
            fixdtSignValStr='[]';
            maskSignValStr='Auto';
        end

    case 'Output'

        paramPrefixStr='output';
        maskSignValStr=blkObj.outputSignedness;

        if strcmp(maskSignValStr,'Auto')
            if isPostCompiledSate(blkObj)


                fixdtSignValStr=getInportFixdtSignValStr(h,blkObj,1);
                maskSignValStr=fixdtSignValStr2maskSignValStr(h,fixdtSignValStr);
            else
                fixdtSignValStr='[]';
            end
        else
            fixdtSignValStr=maskSignValStr2fixdtSignValStr(h,maskSignValStr);
        end
    otherwise

    end

    [wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDTypeInfoForPathItem(h,blkObj,paramPrefixStr,fixdtSignValStr);

    if strncmp(specifiedDTStr,'Same as',7)
        specifiedDTStr=['Inherit: ',specifiedDTStr];
    end


    function flag=isPostCompiledSate(blkObj)

        topLvlMDL=blkObj.getParent;
        while~isa(topLvlMDL,'Simulink.BlockDiagram')

            parentMDL=getParent(topLvlMDL);
            topLvlMDL=parentMDL;
        end

        flag=~strcmpi(topLvlMDL.SimulationStatus,'stopped');

