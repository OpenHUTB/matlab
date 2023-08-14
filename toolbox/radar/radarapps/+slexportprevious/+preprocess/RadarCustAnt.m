function RadarCustAnt(obj)



    CustAntBlocks=obj.findBlocksOfType('MATLABSystem');

    if isR2019bOrEarlier(obj.ver)
        ws=warning('off','phased:element:ObsoletePropertyByTwoProperties');
        ws(2)=warning('off','shared_channel:arrayelemdef:ObsoletePropertyByTwoProperties');
        for i=1:numel(CustAntBlocks)
            blk=CustAntBlocks{i};
            blkSystem=get_param(blk,'System');
            if strcmp(blkSystem,'radar.internal.SimulinkConstantGammaClutter')||...
                strcmp(blkSystem,'gpuConstantGammaClutter')

                custStr=get_param(blk,'Sensor');

                if isR2019bOrEarlier(obj.ver)




                    if contains(custStr,'phi-theta')
                        custStr=insertAzElConvertedPVPairString(custStr);
                        custStr=removePatternCoordinateString(custStr);
                        custStr=removePhiAnglesString(custStr);
                        custStr=removeThetaAnglesString(custStr);
                    end
                end

                if isR2018bOrEarlier(obj.ver)
                    custStr=removeMatchArrayNormalString(custStr);
                end
                if isR2016bOrEarlier(obj.ver)
                    custStr=replaceMagitudePhasePatternString(custStr);
                end

                set_param(blk,'Sensor',custStr);

            end
        end
        warning(ws);
    end

end

function custStr=removePatternCoordinateString(custStr)
    custStr=removePVPairString(custStr,'''PatternCoordinateSystem''');
end

function custStr=removePhiAnglesString(custStr)
    custStr=removePVPairString(custStr,'''PhiAngles''');
end

function custStr=removeThetaAnglesString(custStr)
    custStr=removePVPairString(custStr,'''ThetaAngles''');
end

function custStr=removeMatchArrayNormalString(custStr)
    custStr=removePVPairString(custStr,'''MatchArrayNormal''');
end

function custStr=replaceMagitudePhasePatternString(custStr)
    custStr=replace(custStr,'MagnitudePattern','RadiationPattern');
    custStr=removePVPairString(custStr,'''PhasePattern''');
end

function custStr=insertAzElConvertedPVPairString(custStrIn)





    phiAngConfigured=contains(custStrIn,'PhiAngles');
    thetaAngConfigured=contains(custStrIn,'ThetaAngles');



    if phiAngConfigured
        [~,phiValEndIdx,phiValStartIdx]=getPVPairString(custStrIn,'''PhiAngles''');
        phi=evalin('base',custStrIn(phiValStartIdx:phiValEndIdx));
        az=phased.CustomAntennaElement.mapPhiAnglesToAzimuthAngles(phi);
    else
        phi=0:360;
        az=-180:180;
    end

    if thetaAngConfigured
        [~,thetaValEndIdx,thetaValStartIdx]=getPVPairString(custStrIn,'''ThetaAngles''');
        theta=evalin('base',custStrIn(thetaValStartIdx:thetaValEndIdx));
        el=sort(90-theta);
    else
        theta=0:180;
        el=-90:90;
    end


    if contains(custStrIn,'MagnitudePattern')
        [magPatIdx,magPatValEndIdx,magPatValStartIdx]=...
        getPVPairString(custStrIn,'''MagnitudePattern''');
        magPat_phitheta=evalin('base',custStrIn(magPatValStartIdx:magPatValEndIdx));
        magPat_azel=phithetaConversion(magPat_phitheta,phi,theta,az,el);

        custStrIn=removePVPairString(custStrIn,'''MagnitudePattern''',magPatIdx,magPatValEndIdx);
    else
        magPat_azel=zeros(181,361);
    end

    if contains(custStrIn,'PhasePattern')
        [phasePatIdx,phasePatValEndIdx,phasePatValStartIdx]=...
        getPVPairString(custStrIn,'''PhasePattern''');
        phasePat_phitheta=evalin('base',custStrIn(phasePatValStartIdx:phasePatValEndIdx));
        phasePat_azel=phithetaConversion(phasePat_phitheta,phi,theta,az,el);

        custStrIn=removePVPairString(custStrIn,'''PhasePattern''',phasePatIdx,phasePatValEndIdx);
    else
        phasePat_azel=zeros(181,361);
    end









    [ElemIdx,~,ElemValStartIdx]=...
    getPVPairString(custStrIn,'''Element''');


    LeftBracketIdx=strfind(custStrIn,'(');


    if~isempty(ElemIdx)

        tempIdx=LeftBracketIdx(LeftBracketIdx>ElemValStartIdx);
    else

        tempIdx=LeftBracketIdx;
    end





    constructorStartIdx=tempIdx(1)+1;



    temp_str=custStrIn(constructorStartIdx:end);
    custStrIn(constructorStartIdx:end)='';


    if phiAngConfigured&&thetaAngConfigured

        azelConfigStr=['''AzimuthAngles''',',',mat2str(az),',',...
        '''ElevationAngles''',',',mat2str(el),',',...
        '''MagnitudePattern''',',',mat2str(magPat_azel),',',...
        '''PhasePattern''',',',mat2str(phasePat_azel),','];
    elseif~phiAngConfigured&&thetaAngConfigured

        azelConfigStr=['''ElevationAngles''',',',mat2str(el),',',...
        '''MagnitudePattern''',',',mat2str(magPat_azel),',',...
        '''PhasePattern''',',',mat2str(phasePat_azel),','];
    elseif phiAngConfigured&&~thetaAngConfigured

        azelConfigStr=['''AzimuthAngles''',',',mat2str(az),',',...
        '''MagnitudePattern''',',',mat2str(magPat_azel),',',...
        '''PhasePattern''',',',mat2str(phasePat_azel),','];
    elseif~phiAngConfigured&&~thetaAngConfigured

        azelConfigStr=[...
        '''MagnitudePattern''',',',mat2str(magPat_azel),',',...
        '''PhasePattern''',',',mat2str(phasePat_azel),','];
    end


    custStr=[custStrIn,azelConfigStr,temp_str];
end

function pat_new=phithetaConversion(pat,phi,theta,az,el)
    np=size(pat,3);
    pat_new=zeros(numel(el),numel(az),np,'like',pat);
    for m=1:np
        pat_new(:,:,m)=phitheta2azelpat(pat(:,:,m),phi,...
        theta,az,el,'RotateZ2X',true);
    end
end

function custStr=removePVPairString(custStr,PName,varargin)



    if isempty(varargin)
        [PNameIdx,PNameValueEndIdx]=getPVPairString(custStr,PName);
    else
        PNameIdx=varargin{1};
        PNameValueEndIdx=varargin{2};
    end
    if~isempty(PNameIdx)
        custStr(PNameIdx:PNameValueEndIdx)='';
    end
end

function[PNameIdx,PNameValueEndIdx,PNameValueStartIdx]=getPVPairString(custStr,PName)
    PNameIdx=strfind(custStr,PName);
    PNameValueEndIdx=[];
    PNameValueStartIdx=[];
    if~isempty(PNameIdx)
        CommaIdx=strfind(custStr,',');
        LeftBracketIdx=strfind(custStr,'(');
        RightBracketIdx=strfind(custStr,')');
        PNameValueStartIdx=CommaIdx(find(CommaIdx>PNameIdx,1))+1;
        IdxPool=sort([CommaIdx,LeftBracketIdx,RightBracketIdx]);
        bcount=0;
        for m=1:numel(IdxPool)









            current_idx=IdxPool(m);
            if current_idx>PNameValueStartIdx
                if custStr(current_idx)==','
                    if bcount==0
                        PNameValueEndIdx=current_idx;
                        break;
                    end
                elseif custStr(current_idx)=='('
                    bcount=bcount+1;
                else
                    bcount=bcount-1;
                    if bcount==-1
                        if custStr(PNameIdx-1)==','
                            PNameIdx=PNameIdx-1;
                        end
                        PNameValueEndIdx=current_idx-1;
                        break;
                    end
                end
            end
        end
    end
end
