function str=figureDataCursorUpdateFcn(p,e)



    pos=e.Position;
    normMag=norm(pos(1:2));
    userMag=transformNormMagToUserMag(p,normMag);
    normRad=atan2(pos(2),pos(1));
    userDeg=transformNormRadToUserDeg(p,normRad);




    s_ang=internal.polariCommon.sprintfMaxNumFracDigits(userDeg,1);
    s_mag=internal.polariCommon.sprintfMaxNumTotalDigits(userMag,4);
    str={[char(952),': ',s_ang,char(176)],...
    ['m: ',s_mag]};

    if isIntensityData(p)






        datasetIndex=1;
        angIdx=getDataIndexFromPoint(p,...
        [cos(normRad),sin(normRad)],datasetIndex);
        magIdx=getMagIndexFromPoint(p,normMag,datasetIndex);
        pdata=getDataset(p,datasetIndex);
        inten=pdata.intensity(magIdx,angIdx);


        s_int=internal.polariCommon.sprintfMaxNumFracDigits(inten,1);
        str=[str,{['i: [',s_int,']']}];
    end
