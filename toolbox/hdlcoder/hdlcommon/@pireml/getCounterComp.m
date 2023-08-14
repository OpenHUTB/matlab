function[counterComp1,counterComp2]=getCounterComp(varargin)








































    counterComp2=[];


    CInfo=counterArgs(varargin{:});
    hN=CInfo.hN;
    hInSignals=CInfo.hInSignals;
    hOutSignal=CInfo.hOutSignal;
    hOutSignal1=CInfo.hOutSignal1;



    if CInfo.outputRate~=0
        hOutSignal.SimulinkRate=CInfo.outputRate;
    end

    [clock,hClkEnb,reset]=hN.getClockBundle(hOutSignal,1,1,0);

    if~isempty(CInfo.ClockEnableSignal)
        hClkEnb=CInfo.ClockEnableSignal;
    end


    canOptimizeToFreeRunning=checkIfCounterCanBeOptimizedToFreeRunning(CInfo,hOutSignal);
    doLimitedCounter=CInfo.isLimitedCounter&&~canOptimizeToFreeRunning;
    doModuloCounter=CInfo.isModuloCounter&&~canOptimizeToFreeRunning;



    doLimitOptimize=(doLimitedCounter&&CInfo.isLimitOptimize);



    robustCtr=((doLimitedCounter||doModuloCounter)&&(hOutSignal.Type.FractionLength==0))&&~CInfo.hasDirectionSig&&...
    (CInfo.stepValueData==1||CInfo.stepValueData==-1);
    if robustCtr


        if(CInfo.stepValueData==1&&CInfo.initValue>CInfo.countToValue)||...
            (CInfo.stepValueData==-1&&CInfo.initValue<CInfo.countToValue)
            robustCtr=false;
        end
    end
    if doModuloCounter&&CInfo.hasDirectionSig
        doLimitOptimize=true;
        [stepregComp,stepOutSignals]=elabStepRegisterCompForModCounter(CInfo,hN,...
        hInSignals,hOutSignal,hClkEnb);
        hInSignals=[hInSignals,stepOutSignals];
        if~hClkEnb.isClockEnable
            stepregComp.connectClockBundle(clock,hClkEnb,reset);
        end
    elseif doLimitOptimize&&~robustCtr
        [stepregComp,stepOutSignals]=elabStepRegisterComp(CInfo,hN,hInSignals,...
        hOutSignal,hClkEnb);
        hInSignals=[hInSignals,stepOutSignals];
        if~hClkEnb.isClockEnable
            stepregComp.connectClockBundle(clock,hClkEnb,reset);
        end
    end


    counterComp=elabCounterComp(CInfo,hN,hInSignals,hOutSignal,hOutSignal1,hClkEnb,...
    doLimitedCounter,doModuloCounter,doLimitOptimize,robustCtr);
    if~hClkEnb.isClockEnable
        counterComp.connectClockBundle(clock,hClkEnb,reset);
    end



    if doLimitOptimize&&~robustCtr
        counterComp1=stepregComp;
        counterComp2=counterComp;

    else
        counterComp1=counterComp;
    end


    commentStr=blockComment(CInfo);
    counterComp1.addComment(commentStr);

end



function[stepregComp,stepOutSignals]=elabStepRegisterComp(CInfo,hN,...
    hInSignals,hOutSignal,hClkEnb)



    complementValue=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
    CInfo.countFromValue-CInfo.countToValue);
    next2limit=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
    CInfo.countToValue-CInfo.stepValue);
    next2limit_neg=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
    CInfo.countToValue+CInfo.stepValue);


    output_ex=pirelab.getTypeInfoAsFi(hOutSignal.Type);

    stepParams={output_ex,CInfo.initValue,CInfo.stepValue,CInfo.stepNegValue,...
    CInfo.countToValue,CInfo.countFromValue,complementValue,next2limit,next2limit_neg,...
    CInfo.hasLocalReset,CInfo.hasLoadSignal,CInfo.hasLocalEnable,CInfo.hasDirectionSig};

    stepreg=hN.addSignal(hOutSignal.Type,sprintf('%s_stepreg',CInfo.compName));
    if CInfo.hasDirectionSig
        stepregneg=hN.addSignal(hOutSignal.Type,sprintf('%s_stepregneg',CInfo.compName));
        stepOutSignals=[stepreg,stepregneg];
    else
        stepOutSignals=stepreg;
    end


    stepregComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',sprintf('%s_step',CInfo.compName),...
    'InputSignals',[hOutSignal,hInSignals],...
    'OutputSignals',stepOutSignals,...
    'EnableSignals',hClkEnb,...
    'EMLFileName','hdleml_counter_stepreg',...
    'EMLParams',stepParams,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_ConditionalStmtInProcess',true);

end

function[next2limitUpperBound,next2limitLowerBound,wrappingStepValue]=...
    calculateConstantsForModuloUpCounter(outSignalType,minValue,stepValue,maxValue)
    next2limitUpperBound=pirelab.getTypeInfoAsFi(outSignalType,'Floor','Wrap',...
    maxValue-stepValue);
    next2limitLowerBound=pirelab.getTypeInfoAsFi(outSignalType,'Floor','Wrap',...
    maxValue-2*stepValue+1);
    wrappingStepValue=pirelab.getTypeInfoAsFi(outSignalType,'Floor','Wrap',...
    stepValue-maxValue-1+minValue);
end

function[next2limitUpperBound,next2limitLowerBound,wrappingStepValue]=...
    calculateConstantsForModuloDownCounter(outSignalType,minValue,stepValue,maxValue)
    next2limitLowerBound=pirelab.getTypeInfoAsFi(outSignalType,'Floor','Wrap',...
    minValue-stepValue);
    next2limitUpperBound=pirelab.getTypeInfoAsFi(outSignalType,'Floor','Wrap',...
    minValue-2*stepValue-1);
    wrappingStepValue=pirelab.getTypeInfoAsFi(outSignalType,'Floor','Wrap',...
    stepValue+maxValue+1-minValue);
end


function[stepregComp,stepOutSignals]=elabStepRegisterCompForModCounter(CInfo,hN,...
    hInSignals,hOutSignal,hClkEnb)

    minValue=min(CInfo.countFromValue,CInfo.countToValue);
    maxValue=max(CInfo.countFromValue,CInfo.countToValue);

    if CInfo.stepValueData>0
        [next2limitUpperBound,next2limitLowerBound,wrappingStepValue]=...
        calculateConstantsForModuloUpCounter(hOutSignal.Type,minValue,...
        CInfo.stepValue,maxValue);
        [next2limitUpperBound_neg,next2limitLowerBound_neg,wrappingStepValue_neg]=...
        calculateConstantsForModuloDownCounter(hOutSignal.Type,minValue,...
        CInfo.stepNegValue,maxValue);
        limit=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
        maxValue-CInfo.stepValue+1);
        limit_neg=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
        minValue+CInfo.stepValue-1);
    else
        [next2limitUpperBound,next2limitLowerBound,wrappingStepValue]=...
        calculateConstantsForModuloDownCounter(hOutSignal.Type,minValue,...
        CInfo.stepValue,maxValue);
        [next2limitUpperBound_neg,next2limitLowerBound_neg,wrappingStepValue_neg]=...
        calculateConstantsForModuloUpCounter(hOutSignal.Type,minValue,...
        CInfo.stepNegValue,maxValue);
        limit=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
        minValue+CInfo.stepNegValue-1);
        limit_neg=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
        maxValue-CInfo.stepNegValue+1);
    end



    output_ex=pirelab.getTypeInfoAsFi(hOutSignal.Type);

    stepParams={output_ex,CInfo.initValue,CInfo.stepValue,CInfo.stepNegValue,...
    next2limitUpperBound,next2limitLowerBound,...
    next2limitUpperBound_neg,next2limitLowerBound_neg,limit,limit_neg...
    ,CInfo.stepValueData,minValue,maxValue,...
    wrappingStepValue,wrappingStepValue_neg,...
    CInfo.hasLocalReset,CInfo.hasLoadSignal,CInfo.hasLocalEnable,CInfo.hasDirectionSig};

    stepreg=hN.addSignal(hOutSignal.Type,sprintf('%s_stepreg',CInfo.compName));
    if CInfo.hasDirectionSig
        stepregneg=hN.addSignal(hOutSignal.Type,sprintf('%s_stepregneg',CInfo.compName));
        stepOutSignals=[stepreg,stepregneg];
    else
        stepOutSignals=stepreg;
    end


    stepregComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',sprintf('%s_step',CInfo.compName),...
    'InputSignals',[hOutSignal,hInSignals],...
    'OutputSignals',stepOutSignals,...
    'EnableSignals',hClkEnb,...
    'EMLFileName','hdleml_modcounter_stepreg',...
    'EMLParams',stepParams,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_ConditionalStmtInProcess',true);

end




function counterComp=elabCounterComp(CInfo,hN,hInSignals,hOutSignal,hOutSignal1,...
    hClkEnb,doLimitedCounter,doModuloCounter,doLimitOptimize,robustCtr)

    output_ex=pirelab.getTypeInfoAsFi(hOutSignal.Type);

    if CInfo.hasLocalEnable&&~CInfo.hasLocalReset&&~CInfo.hasLoadSignal&&~doLimitedCounter


        hInSignals=hInSignals(2:end);
        if isempty(hInSignals)
            hInSignals=[];
        end
        CInfo.hasLocalEnable=false;

        hEnableSignals=[hClkEnb,CInfo.hEnbSignal];
    else
        hEnableSignals=hClkEnb;
    end













    if robustCtr
        fname='hdleml_robustctr';
        counterParams={output_ex,CInfo.initValue,CInfo.stepValue,CInfo.stepNegValue,...
        CInfo.countToValue,CInfo.countFromValue,...
        CInfo.hasLocalReset,CInfo.hasLoadSignal,CInfo.hasLocalEnable};
    elseif doModuloCounter
        fname='hdleml_modcounter';


        maxValue=max(CInfo.countFromValue,CInfo.countToValue);
        minValue=min(CInfo.countFromValue,CInfo.countToValue);
        if CInfo.stepValueData>0
            modValue=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
            (maxValue+1)-minValue-CInfo.stepValue);
            next2limit=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
            maxValue-CInfo.stepValue);
        else
            modValue=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
            (maxValue+1)-minValue+CInfo.stepValue);
            next2limit=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
            minValue-CInfo.stepValue);
        end

        counterParams={output_ex,CInfo.initValue,CInfo.stepValue,...
        CInfo.stepValueData,modValue,next2limit,...
        CInfo.hasLocalReset,CInfo.hasLoadSignal,CInfo.hasLocalEnable,...
        CInfo.hasDirectionSig};
    else
        fname='hdleml_counter';




        rangeUpperBound=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
        upperbound(CInfo.initValue));
        rangeLowerBound=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
        lowerbound(CInfo.initValue));
        if CInfo.stepValueData>0
            next2limit=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
            rangeUpperBound-CInfo.stepValueData);
        else
            next2limit=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
            rangeLowerBound-CInfo.stepValueData);
        end

        counterParams={output_ex,CInfo.initValue,CInfo.stepValue,CInfo.stepNegValue,CInfo.stepValueData,...
        CInfo.countToValue,CInfo.countFromValue,doLimitedCounter,doLimitOptimize,...
        CInfo.hasLocalReset,CInfo.hasLoadSignal,CInfo.hasLocalEnable,...
        CInfo.hasDirectionSig,next2limit};
    end
    counterComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',CInfo.compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',[hOutSignal,hOutSignal1],...
    'EnableSignals',hEnableSignals,...
    'EMLFileName',fname,...
    'EMLParams',counterParams,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_ConditionalStmtInProcess',true);

end


function canOptimizeToFreeRunning=checkIfCounterCanBeOptimizedToFreeRunning(CInfo,hOutSignal)


    if CInfo.isLimitedCounter||CInfo.isModuloCounter

        canOptimizeToFreeRunning=false;


        [countToMax,countFromMin]=calculateCounterRange(CInfo,hOutSignal);

        if countToMax&&countFromMin&&CInfo.stepValueData==1


            canOptimizeToFreeRunning=true;

        elseif hOutSignal.Type.WordLength==1

            if hOutSignal.Type.FractionLength~=0&&CInfo.isModuloCounter
                canOptimizeToFreeRunning=false;
            else
                canOptimizeToFreeRunning=true;
            end
        elseif CInfo.stepValue==CInfo.stepNegValue


            canOptimizeToFreeRunning=true;
        end
    else

        canOptimizeToFreeRunning=true;
    end

end


function[countToMax,countFromMin]=calculateCounterRange(CInfo,hOutSignal)


    countMax=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
    upperbound(CInfo.initValue));
    countMin=pirelab.getTypeInfoAsFi(hOutSignal.Type,'Floor','Wrap',...
    lowerbound(CInfo.initValue));
    countToMax=CInfo.countToValue==countMax;
    countFromMin=CInfo.countFromValue==countMin;

end


function CInfo=counterArgs(varargin)


    persistent myParser;
    if isempty(myParser)
        myParser=inputParser;
        myParser.addParameter('Network',[]);
        myParser.addParameter('OutputSignal',[]);
        myParser.addParameter('OutputSignal1',[]);
        myParser.addParameter('OutputSimulinkRate',0);
        myParser.addParameter('Name','counter');
        myParser.addParameter('LocalResetSignal',[]);
        myParser.addParameter('LoadSignal',[]);
        myParser.addParameter('LoadValueSignal',[]);
        myParser.addParameter('CountEnableSignal',[]);
        myParser.addParameter('CountDirectionSignal',[]);
        myParser.addParameter('ClockEnableSignal',[]);
        myParser.addParameter('InitialValue',0);
        myParser.addParameter('StepValue',1);
        myParser.addParameter('CountToValue',[]);
        myParser.addParameter('CountFromValue',[]);
        myParser.addParameter('CountType','Free running');
        myParser.addParameter('LimitedCounterOptimize',true);
    end

    myParser.parse(varargin{:});
    arg=myParser.Results;


    if isempty(arg.Network)||isempty(arg.OutputSignal)
        error(message('hdlcommon:hdlcommon:MissingInput',arg.Name));
    end


    CInfo.hN=arg.Network;
    CInfo.hOutSignal=arg.OutputSignal;
    CInfo.hOutSignal1=arg.OutputSignal1;
    CInfo.outputRate=arg.OutputSimulinkRate;
    CInfo.compName=arg.Name;
    CInfo.hRstSignal=arg.LocalResetSignal;
    CInfo.hLoadSignal=arg.LoadSignal;
    CInfo.hLoadValSignal=arg.LoadValueSignal;
    CInfo.hEnbSignal=arg.CountEnableSignal;
    CInfo.hDirectionSignal=arg.CountDirectionSignal;
    CInfo.ClockEnableSignal=arg.ClockEnableSignal;
    CInfo.CountType=arg.CountType;
    CInfo.initValue=pirelab.getTypeInfoAsFi(CInfo.hOutSignal.Type,...
    'Floor','Wrap',arg.InitialValue);
    CInfo.initValueData=double(arg.InitialValue);
    CInfo.stepValue=pirelab.getTypeInfoAsFi(CInfo.hOutSignal.Type,...
    'Floor','Wrap',arg.StepValue);
    CInfo.stepValueData=double(arg.StepValue);
    if CInfo.stepValueData>1
        CInfo.isLimitOptimize=false;
    else
        CInfo.isLimitOptimize=arg.LimitedCounterOptimize;
    end



    if~isempty(arg.CountToValue)
        if strcmp(CInfo.CountType,'Modulo')
            CInfo.isLimitedCounter=false;
            CInfo.isModuloCounter=true;
        else
            CInfo.isLimitedCounter=true;
            CInfo.isModuloCounter=false;
        end
        CInfo.countToValue=pirelab.getTypeInfoAsFi(CInfo.hOutSignal.Type,...
        'Floor','Wrap',arg.CountToValue);
        CInfo.countToValueData=double(arg.CountToValue);
    else
        CInfo.isLimitedCounter=false;
        CInfo.isModuloCounter=false;
        CInfo.countToValue=pirelab.getTypeInfoAsFi(CInfo.hOutSignal.Type);
        CInfo.countToValueData=0;
    end


    if~isempty(arg.CountFromValue)
        CInfo.countFromValue=pirelab.getTypeInfoAsFi(CInfo.hOutSignal.Type,...
        'Floor','Wrap',arg.CountFromValue);
    else
        CInfo.countFromValue=CInfo.initValue;
    end


    CInfo.stepNegValue=pirelab.getTypeInfoAsFi(CInfo.hOutSignal.Type,...
    'Floor','Wrap',-CInfo.stepValue);


    CInfo=initInputSignals(CInfo);

end


function CInfo=initInputSignals(CInfo)


    hInSignals=[];

    CInfo.hasLocalReset=false;
    CInfo.hasLoadSignal=false;
    CInfo.hasLocalEnable=false;
    CInfo.hasDirectionSig=false;

    if~isempty(CInfo.hRstSignal)
        CInfo.hasLocalReset=true;
        hInSignals=[hInSignals,CInfo.hRstSignal];
    end

    if~isempty(CInfo.hLoadSignal)
        CInfo.hasLoadSignal=true;
        hInSignals=[hInSignals,CInfo.hLoadSignal,CInfo.hLoadValSignal];

    end

    if~isempty(CInfo.hEnbSignal)
        CInfo.hasLocalEnable=true;
        hInSignals=[hInSignals,CInfo.hEnbSignal];
    end

    if~isempty(CInfo.hDirectionSignal)
        CInfo.hasDirectionSig=true;
        hInSignals=[hInSignals,CInfo.hDirectionSignal];
    end

    CInfo.hInSignals=hInSignals;

end


function str=blockComment(CInfo)


    nl=newline;

    if CInfo.isLimitedCounter
        Countertype='Count limited';
        count_to_value=[...
        nl,' count to value  = ',num2str(CInfo.countToValueData)];
    elseif CInfo.isModuloCounter
        Countertype='Modulo';
        count_to_value=[...
        nl,' count to value  = ',num2str(CInfo.countToValueData)];
    else
        Countertype='Free running';
        count_to_value='';
    end

    if CInfo.hOutSignal.Type.Signed
        Outputdatatype='Signed';
    else
        Outputdatatype='Unsigned';
    end

    comment=[Countertype,', ',Outputdatatype,' Counter',nl...
    ,' initial value   = ',num2str(CInfo.initValueData),nl...
    ,' step value      = ',num2str(CInfo.stepValueData)...
    ,count_to_value];

    str=[hdlformatcomment(comment,2),nl];

end


