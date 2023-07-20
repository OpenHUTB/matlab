function varargout=autoblksobdmisf(varargin)
    varargout{1}=0;
    Block=varargin{1};
    ParamList=[];
    LookupTblList=[];


    MaskObject=get_param(Block,'MaskObject');
    Enabled={MaskObject.Parameters.Enabled};
    parmNames={MaskObject.Parameters(strcmp(Enabled,'on')).Name};

    switch varargin{2}

    case 'InitObdSet'
        nCols=[2,2,1,1];
        gteVal=[-36,54,1,1];
        lteVal=[36,126,1000,100];
        ParamList=makePList(parmNames,nCols,gteVal,lteVal);

        angLo={parmNames{1},{'gte',gteVal(1);'lte',lteVal(1)}};
        angHi={parmNames{2},{'gte',gteVal(2);'lte',lteVal(2)}};
        LookupTblList=[{angLo,parmNames{1},{'gte',gteVal(1);'lte',lteVal(1)}};...
        {angHi,parmNames{2},{'gte',gteVal(2);'lte',lteVal(2)}}];
        autoblkscheckparams(Block,'',ParamList,LookupTblList)
    case 'InitObdMisf'
        tMisfMin=getVariable(get_param(bdroot,'ModelWorkspace'),'tMisfMin');
        for i=1:numel(parmNames)
            if isscalar(str2num(get_param(Block,parmNames{i})))
                if isempty(ParamList)
                    ParamList={parmNames{i},[1,1],{'gte',tMisfMin;'lte',1e6}};
                else
                    ParamList=[ParamList;{parmNames{i},[1,1],{'gte',tMisfMin;'lte',1e6}}];
                end
            else
                misf={parmNames{i},{'gte',0.01;'lte',1e6}};
                if isempty(LookupTblList)
                    LookupTblList={misf,parmNames{i},{'gte',tMisfMin;'lte',1e6}};
                else
                    LookupTblList=[LookupTblList;{misf,parmNames{i},{'gte',tMisfMin;'lte',1e6}}];
                end
            end
        end
        autoblkscheckparams(Block,'',ParamList,LookupTblList)
    case 'InitObdCrkT'
        nCols=ones(1,4);
        gteVal=[10,0.1,0,0];
        lteVal=[1000,0.9,10,20000];
        ParamList=makePList(parmNames,nCols,gteVal,lteVal);
        autoblkscheckparams(Block,'',ParamList,LookupTblList)
    case 'DrawECU'
        varargout{1}=drawECU(Block);
    case 'DrawEngPlant'
        varargout{1}=drawEngPlant(Block);
    case 'DrawCrankSlider'
        varargout{1}=drawCrankSlider(Block);
    end
end

function ParamList=makePList(parmNames,nCols,gteVal,lteVal)
    nParms=numel(parmNames);
    ParamList=cell(nParms,3);
    ParamList(1,:)={parmNames{1},[1,nCols(1)],{'gte',gteVal(1);'lte',lteVal(1)}};
    if nParms>1
        for i=2:nParms
            ParamList(i,:)={parmNames{i},[1,nCols(i)],{'gte',gteVal(i);'lte',lteVal(i)}};
        end
    end
end

function IconInfo=drawECU(Block)

    AliasNames={'CpsVoltage','CpsVoltage';'InstEngSpeed','InstEngSpeed';...
    'EngSpeed','EngSpeed';'EngRun','EngRun';...
    'DTCConfFunctionTPU','DTCConfFunctionTPU';'CntrSignals','CntrSignals'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='propulsion_controller_spark_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,50,150,'white');
end

function IconInfo=drawEngPlant(Block)

    AliasNames={'KeyState','KeyState';'CPVoltage','CPVoltage';...
    'Ang','Ang';'CntrSignals','CntrSignals'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='engine_spark_ignition.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,10,'white');
end

function IconInfo=drawCrankSlider(Block)

    AliasNames={'CrkAng','CrkAng';'CylP','CylP';...
    'Stroke','Stroke';'Tind','Tind'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='crank_slider.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,100,10,'white');
end