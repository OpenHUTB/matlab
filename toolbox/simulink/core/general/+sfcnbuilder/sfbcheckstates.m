function[ad,isValid,errorMessage,d]=sfbcheckstates(ad)




    isValid=1;
    errorMessage='';
    cr=newline;

    NumDStates=ad.SfunWizardData.NumberOfDiscreteStates;
    NumDStates=strrep(NumDStates,']','');
    NumDStates=strrep(NumDStates,'[','');
    DStatesIC=ad.SfunWizardData.DiscreteStatesIC;
    [DStatesIC,isvalidDStatesIC,dstatesErrorMessage]=setInitCond(DStatesIC,NumDStates);

    NumCStates=ad.SfunWizardData.NumberOfContinuousStates;
    NumCStates=strrep(NumCStates,']','');
    NumCStates=strrep(NumCStates,'[','');
    CStatesIC=ad.SfunWizardData.ContinuousStatesIC;
    [CStatesIC,isvalidCStatesIC,cstatesErrorMessage]=setInitCond(CStatesIC,NumCStates);

    NumPWorks=ad.SfunWizardData.NumberOfPWorks;

    if~sfcnbuilder.isValidParams(NumDStates)
        errorMessage=sprintf(['Error: invalid setting for the S-function discrete states: %s\n',...
        '       The states must be a numerical value greater than or equal to 0.'],NumDStates);
        isValid=0;
    end

    if~isvalidDStatesIC
        errorMessage=horzcat(errorMessage,cr,dstatesErrorMessage);
        isValid=0;
    end


    if~sfcnbuilder.isValidParams(NumCStates)
        InvalidNumCStates=sprintf(['Error: invalid setting for the S-function continuous states: %s\n',...
        '       The states must be a numerical value greater than or equal to 0.'],NumCStates);
        errorMessage=horzcat(errorMessage,cr,InvalidNumCStates);
        isValid=0;
    end

    if~isvalidCStatesIC
        errorMessage=horzcat(errorMessage,cr,cstatesErrorMessage);
        isValid=0;
    end

    d.NumDStates=NumDStates;
    d.DStatesIC=DStatesIC;
    d.NumCStates=NumCStates;
    d.CStatesIC=CStatesIC;
    d.NumPWorks=NumPWorks;
    d.NumDWorks='0';































































end

function[InitCond,isvalid,strmessage]=setInitCond(InitCond,NumStates)
    strmessage='';
    isvalid=1;
    tempInitCond=InitCond;

    strmessageError=sprintf(['Error: Invalid setting for the states initial condition: ''%s''',...
    '\n       The length of the initial condition must be a numeric vector equal to the number of states.'],InitCond);

    try

        InitCond=strtrim(InitCond);
        if~(InitCond(1)=='[')
            InitCond=['[',InitCond];
        end
        if~(InitCond(end)==']')
            InitCond=[InitCond,']'];
        end
        InitCond=regexprep(InitCond,'[\s,]+',',');

        n=length(strfind(InitCond,','))+1;
        if(~isempty(str2num(NumStates)))
            if(str2num(NumStates)==n||str2num(NumStates)==0)
                InitCond=strrep(InitCond,']','');
                InitCond=strrep(InitCond,'[','');
                isvalid=1;
            else
                InitCond=tempInitCond;
                isvalid=0;
                strmessage=strmessageError;
            end
        end
    catch
        InitCond=tempInitCond;
        isvalid=0;
        strmessage=strmessageError;
    end
end