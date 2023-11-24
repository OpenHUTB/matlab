function cacheData=simrfV2_antcachefit(block,MaskWSValues)
    cacheData=simrfV2_getantcachedata(block);
    antSrc=get_param(block,'AntennaSource');
    prevAntSrc=get_param(block,'PrevAppliedAntSource');
    if~strcmp(antSrc,prevAntSrc)&&~any(strcmp({antSrc,prevAntSrc},...
        'Isotropic radiator'))
        cacheData.AntChangedArr=true;
        cacheData.AntChangedDep=true;
        set_param(block,'UserData',cacheData);
    end

    if strcmp(get_param(block,'InputIncWave'),'on')
        if(~isfield(cacheData,'RecAntVocOn')||~cacheData.RecAntVocOn)
            cacheData.RecAntVocOn=true;
            set_param(block,'UserData',cacheData);
        end
    elseif(~isfield(cacheData,'RecAntVocOn')||cacheData.RecAntVocOn)
        cacheData.RecAntVocOn=false;
        set_param(block,'UserData',cacheData);
    end
    if strcmp(get_param(block,'OutputRadWave'),'on')
        if(~isfield(cacheData,'TransAntIinMeasurementOn')||...
            ~cacheData.TransAntIinMeasurementOn)
            cacheData.TransAntIinMeasurementOn=true;
            set_param(block,'UserData',cacheData);
        end
    elseif(~isfield(cacheData,'TransAntIinMeasurementOn')||...
        cacheData.TransAntIinMeasurementOn)
        cacheData.TransAntIinMeasurementOn=false;
        set_param(block,'UserData',cacheData);
    end
    antSrcCmp=strcmp(antSrc,{'Antenna object','Antenna Designer'});
    if any(antSrcCmp)
        rArr=MaskWSValues.rArr;
        if~isempty(rArr)&&isnumeric(rArr)&&numel(rArr)==2&&...
            all(isfinite(rArr))&&isreal(rArr)
            rArrRad=convertAzEl2ThPhRad(rArr,MaskWSValues.rArr_unit);
        else
            rArrRad=[];
        end
        rDep=MaskWSValues.rDep;
        if~isempty(rDep)&&isnumeric(rDep)&&numel(rDep)==2&&...
            all(isfinite(rDep))&&isreal(rDep)
            rDepRad=convertAzEl2ThPhRad(rDep,MaskWSValues.rDep_unit);
        else
            rDepRad=[];
        end
        showBar=strcmp(get_param(bdroot(block),'Shown'),'on');
        if antSrcCmp(1)
            antObjVal=get_param(block,'AntennaObj');
            if isvarname(antObjVal)
                antObj=MaskWSValues.AntennaObj;
                supClasses=superclasses(antObj);
                isEmStruct=any(strcmp(supClasses,'em.EmStructures'));
                if~isEmStruct
                    isWrStruct=any(strcmp(supClasses,'em.WireStructures'));
                    FPortFldName='Frequency';
                    FFieldFldName=FPortFldName;
                else

                    isWrStruct=false;
                    FPortFldName='PortFrequency';
                    FFieldFldName='FieldFrequency';
                end
                auxData=get_param([block,'/AuxData'],'UserData');
                if(isEmStruct||isWrStruct)&&...
                    any(strcmp(methods(antObj),'info'))&&...
                    any(strcmp(methods(antObj),'sparameters'))&&...
                    any(strcmp(methods(antObj),'EHfields'))&&...
                    strcmp(antObj.info.IsSolved,'true')&&...
                    ~(isempty(antObj.info.(FPortFldName))&&...
                    isempty(antObj.info.(FFieldFldName)))
                    if isempty(auxData)||~isfield(auxData,'Antenna')||...
                        isempty(auxData.Antenna)
                        auxData.Antenna=copy(antObj);
                        auxData.Antenna.meshconfig('manual');


                        if isempty(auxData.Antenna.info.(FPortFldName))
                            auxData.sparam=sparameters(auxData.Antenna,...
                            unique(auxData.Antenna.info.(FFieldFldName)));
                        else
                            auxData.sparam=sparameters(auxData.Antenna,...
                            unique(auxData.Antenna.info.(FPortFldName)));
                        end
                        if auxData.sparam.NumPorts<=65
                            eqAnt=~isempty(cacheData.OrigAntenna)&&...
                            isequalInt(cacheData.OrigAntenna,antObj);
                            if~eqAnt
                                cacheData.OrigAntenna=copy(antObj);
                            end
                            if strcmp(get_param(block,'InputIncWave'),...
                                'on')&&~isempty(rArrRad)&&(~eqAnt||...
                                isempty(cacheData.ArrDirection)||...
                                any(cacheData.ArrDirection~=rArrRad))
                                cacheData.ArrDirection=rArrRad;
                                [cacheData.normFIthetaArr,...
                                cacheData.normFIphiArr]=...
                                simrfV2_antcalcvel(auxData.Antenna,...
                                auxData.sparam,...
                                cacheData.ArrDirection,showBar);
                                cacheData.AntChangedArr=false;
                                set_param(block,'UserData',cacheData);
                            elseif~eqAnt




                                cacheData.AntChangedArr=true;
                                set_param(block,'UserData',cacheData);
                            end
                            if(strcmp(get_param(block,'OutputRadWave'),...
                                'on')&&~isempty(rDepRad)&&(~eqAnt||...
                                isempty(cacheData.DepDirection)||...
                                any(cacheData.DepDirection~=rDepRad)))
                                cacheData.DepDirection=rDepRad;
                                [cacheData.normFIthetaDep,...
                                cacheData.normFIphiDep]=...
                                simrfV2_antcalcvel(auxData.Antenna,...
                                auxData.sparam,...
                                cacheData.DepDirection,showBar);
                                cacheData.AntChangedDep=false;
                                set_param(block,'UserData',cacheData);
                            elseif~eqAnt




                                cacheData.AntChangedDep=true;
                                set_param(block,'UserData',cacheData);
                            end
                        else
                            auxData.Antenna=[];
                        end
                        set_param([block,'/AuxData'],'UserData',auxData);
                    else
                        if isempty(cacheData.OrigAntenna)||...
                            ~isequalInt(cacheData.OrigAntenna,antObj)
                            auxData.Antenna=copy(antObj);
                            auxData.Antenna.meshconfig('manual');


                            if isempty(auxData.Antenna.info.(FPortFldName))
                                auxData.sparam=sparameters(auxData.Antenna,...
                                unique(...
                                auxData.Antenna.info.(FFieldFldName)));
                            else
                                auxData.sparam=sparameters(auxData.Antenna,...
                                unique(...
                                auxData.Antenna.info.(FPortFldName)));
                            end
                            if auxData.sparam.NumPorts<=65
                                cacheData.OrigAntenna=copy(antObj);
                                if strcmp(get_param(block,'InputIncWave'),...
                                    'on')&&~isempty(rArrRad)
                                    cacheData.ArrDirection=rArrRad;
                                    [cacheData.normFIthetaArr,...
                                    cacheData.normFIphiArr]=...
                                    simrfV2_antcalcvel(...
                                    auxData.Antenna,...
                                    auxData.sparam,...
                                    cacheData.ArrDirection,showBar);
                                    cacheData.AntChangedArr=false;
                                    set_param(block,'UserData',cacheData);
                                else





                                    cacheData.AntChangedArr=true;
                                    set_param(block,'UserData',cacheData);
                                end
                                if strcmp(get_param(block,'OutputRadWave'),...
                                    'on')&&~isempty(rDepRad)
                                    cacheData.DepDirection=rDepRad;
                                    [cacheData.normFIthetaDep,...
                                    cacheData.normFIphiDep]=...
                                    simrfV2_antcalcvel(...
                                    auxData.Antenna,...
                                    auxData.sparam,...
                                    cacheData.DepDirection,showBar);
                                    cacheData.AntChangedDep=false;
                                    set_param(block,'UserData',cacheData);
                                else





                                    cacheData.AntChangedDep=true;
                                    set_param(block,'UserData',cacheData);
                                end

                                set_param(block,'UserData',cacheData);
                            else
                                auxData.Antenna=[];
                            end
                            set_param([block,'/AuxData'],'UserData',auxData);
                        else
                            if strcmp(get_param(block,'InputIncWave'),...
                                'on')&&~isempty(rArrRad)&&...
                                (isempty(cacheData.ArrDirection)||...
                                any(cacheData.ArrDirection~=rArrRad)||...
                                cacheData.AntChangedArr)
                                cacheData.ArrDirection=rArrRad;
                                [cacheData.normFIthetaArr,...
                                cacheData.normFIphiArr]=...
                                simrfV2_antcalcvel(auxData.Antenna,...
                                auxData.sparam,...
                                cacheData.ArrDirection,showBar);
                                cacheData.AntChangedArr=false;
                                set_param(block,'UserData',cacheData);
                            end
                            if strcmp(get_param(block,'OutputRadWave'),...
                                'on')&&~isempty(rDepRad)&&...
                                (isempty(cacheData.DepDirection)||...
                                any(cacheData.DepDirection~=rDepRad)||...
                                cacheData.AntChangedDep)
                                cacheData.DepDirection=rDepRad;
                                [cacheData.normFIthetaDep,...
                                cacheData.normFIphiDep]=...
                                simrfV2_antcalcvel(auxData.Antenna,...
                                auxData.sparam,...
                                cacheData.DepDirection,showBar);
                                cacheData.AntChangedDep=false;
                                set_param(block,'UserData',cacheData);
                            end
                        end
                    end
                end
            end
        else


            antObj=cacheData.IntAntenna;
            auxData=get_param([block,'/AuxData'],'UserData');
            if~isempty(antObj)&&strcmp(antObj.info.IsSolved,'true')&&...
                ~(isempty(antObj.info.PortFrequency)&&...
                isempty(antObj.info.FieldFrequency))
                if~isfield(auxData,'Antenna')||isempty(auxData.Antenna)||...
                    ~isequalInt(auxData.Antenna,antObj,true)


                    auxData.Antenna=antObj;
                    auxData.Antenna.meshconfig('manual');


                    if isempty(auxData.Antenna.info.PortFrequency)
                        auxData.sparam=sparameters(auxData.Antenna,...
                        unique(auxData.Antenna.info.FieldFrequency));
                    else
                        auxData.sparam=sparameters(auxData.Antenna,...
                        unique(auxData.Antenna.info.PortFrequency));
                    end
                    if strcmp(get_param(block,'InputIncWave'),...
                        'on')&&~isempty(rArrRad)&&...
                        (cacheData.AntChangedArr||...
                        isempty(cacheData.ArrDirection)||...
                        any(cacheData.ArrDirection~=rArrRad))
                        cacheData.ArrDirection=rArrRad;
                        [cacheData.normFIthetaArr,...
                        cacheData.normFIphiArr]=...
                        simrfV2_antcalcvel(auxData.Antenna,...
                        auxData.sparam,...
                        cacheData.ArrDirection,showBar);
                        cacheData.AntChangedArr=false;
                        set_param(block,'UserData',cacheData);
                    else




                        cacheData.AntChangedArr=true;
                        set_param(block,'UserData',cacheData);
                    end
                    if strcmp(get_param(block,'OutputRadWave'),...
                        'on')&&~isempty(rDepRad)&&...
                        (cacheData.AntChangedDep||...
                        isempty(cacheData.DepDirection)||...
                        any(cacheData.DepDirection~=rDepRad))
                        cacheData.DepDirection=rDepRad;
                        [cacheData.normFIthetaDep,...
                        cacheData.normFIphiDep]=...
                        simrfV2_antcalcvel(auxData.Antenna,...
                        auxData.sparam,...
                        cacheData.DepDirection,showBar);
                        cacheData.AntChangedDep=false;
                        set_param(block,'UserData',cacheData);
                    else




                        cacheData.AntChangedDep=true;
                        set_param(block,'UserData',cacheData);
                    end
                    set_param([block,'/AuxData'],'UserData',auxData);
                else
                    if strcmp(get_param(block,'InputIncWave'),'on')&&...
                        ~isempty(rArrRad)&&...
                        (isempty(cacheData.ArrDirection)||...
                        any(cacheData.ArrDirection~=rArrRad)||...
                        cacheData.AntChangedArr)
                        cacheData.ArrDirection=rArrRad;
                        [cacheData.normFIthetaArr,...
                        cacheData.normFIphiArr]=...
                        simrfV2_antcalcvel(auxData.Antenna,...
                        auxData.sparam,...
                        cacheData.ArrDirection,showBar);
                        cacheData.AntChangedArr=false;
                        set_param(block,'UserData',cacheData);
                    end
                    if strcmp(get_param(block,'OutputRadWave'),'on')&&...
                        ~isempty(rDepRad)&&...
                        (isempty(cacheData.DepDirection)||...
                        any(cacheData.DepDirection~=rDepRad)||...
                        cacheData.AntChangedDep)
                        cacheData.DepDirection=rDepRad;
                        [cacheData.normFIthetaDep,...
                        cacheData.normFIphiDep]=...
                        simrfV2_antcalcvel(auxData.Antenna,...
                        auxData.sparam,...
                        cacheData.DepDirection,showBar);
                        cacheData.AntChangedDep=false;
                        set_param(block,'UserData',cacheData);
                    end
                end
            end
        end
    end

end

function dirthPh=convertAzEl2ThPhRad(dirAzEl,dir_unit)
    if~strcmp(dir_unit,'rad')

        dirAzEl=dirAzEl*pi/180;
    end
    dirthPh(1)=pi/2-dirAzEl(2);
    dirthPh(2)=dirAzEl(1);
end

