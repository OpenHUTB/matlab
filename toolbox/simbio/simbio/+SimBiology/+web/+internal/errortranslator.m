function[msg,identifier]=errortranslator(input1,input2)


















    switch(nargin)
    case 1
        ex=input1;
        identifier=ex.identifier;
        msg=ex.message;
    case 2
        ex=[];
        identifier=input1;
        msg=input2;
    end


    switch(identifier)
    case 'SimBiology:SBIONMIMPORT_Invalid_NMFileDef_TimeLabel'
        msg=getString(message('SimBiology:sbiodesktoperrortranslator:SBIONMIMPORT_Invalid_NMFileDef_TimeLabel'));
    case 'SimBiology:SBIONMIMPORT_Invalid_NMFileDef_DependentVariableLabel'
        msg=getString(message('SimBiology:sbiodesktoperrortranslator:SBIONMIMPORT_Invalid_NMFileDef_DependentVariableLabel'));
    case 'SimBiology:sbservices:UNIT_NOT_SET_ON_OBSERVABLE'
        msg=getString(message('SimBiology:sbiodesktoperrortranslator:UNIT_NOT_SET_ON_OBSERVABLE'));
    case 'SimBiology:groupedData:createDoses:IgnoringUnits'
        msg='Mismatched units between the dose settings and the data are ignored.';
    case{'SimBiology:LeastSquaresResults:caughtExceptionToWarning',...
        'SimBiology:LeastSquaresResults:caughtExceptionInProfileLikelihoodEvaluation'}
        msg=removeStackFromMessage(msg);
    case{'SimBiology:SBIOABSTRACTKL_EXISTS_AS_BUILTIN',...
        'SimBiology:SBIOABSTRACTKL_EXISTS_AS_USER'}

        msg=trimLastNSentences(msg,1);
    case{'SimBiology:GlobalSensitivityAnalysis:WarnAboutInvalidClassifier'}

        msg=trimLastNSentences(msg,8);
    case{'SimBiology:EventFcnBadLHSToken',...
        'SimBiology:RuleBadLHSToken',...
        'SimBiology:ObservableObjectDoesNotResolve',...
        'SimBiology:RuleObjectDoesNotResolve',...
        'SimBiology:EventObjectDoesNotResolve',...
        'SimBiology:ReactionObjectDoesNotResolve'}





        msg=removeHyperlink(msg);
    case{'SimBiology:CodeGeneration:AccelerationFailed',...
        'SimBiology:CodeGeneration:InvalidMexCompilerFitting',...
        'SimBiology:CodeGeneration:AcceleratedResultsDiffer',...
        'SimBiology:odebuilder:INVALID_ASSIGNMENT_RULE',...
        'SimBiology:odebuilder:INVALID_ASSIGNMENT_RULES'}

        msg=removeHyperlinkAndClickHereText(msg);
    case 'SimBiology:SimFunction:UndefinedFunction'

        errorStartIdx=strfind(msg,'The following error');
        if isempty(errorStartIdx)
            errorText='';
        else
            errorText=msg(errorStartIdx:end);
            msg=msg(1:errorStartIdx-1);
        end
        msg=removeHyperlink(msg);
        msg=[msg,errorText];
    case{'SimBiology:SBIONMIMPORT_Invalid_File',...
        'SimBiology:sbiofit:AllFitsFailed',...
        'SimBiology:sbiofit:CategoryVariableValidation',...
        'SimBiology:fit:InvalidDataUnits',...
'SimBiology:sbiofit:InvalidVariant'...
        }

        msg=addCause(ex,msg);
    case 'SimBiology:sbiosteadystate:RequireScheduleDose'
        msg='Steady state only supports bolus schedule doses at time = 0.';
    case 'SimBiology:sbiosteadystate:UnsupportedDoseParameters'
        msg='Steady state does not support doses with lag or duration parameters.';
    case 'SimBiology:sbiosteadystate:NonZeroTimeDose'
        msg='Steady state only supports bolus dosing at time = 0.';
    case 'SimBiology:sbiosteadystate:NonZeroRate'
        msg='Steady stat only supports bolus dosing at time = 0. Remove the non-zero rate from dose.';
    case{'SimBiology:senscsverify:iOrJInNumericLiteral',...
        'SimBiology:senscsverify:UnsupportedOp',...
        'SimBiology:senscsverify:UnsupportedOp2',...
        'SimBiology:senscsverify:UnsupportedFunctionFatal',...
        'SimBiology:senscsverify:UnsupportedFunction'}


        msg=removeHyperlinkAndClickHereText(msg);
        msg=[msg,' For more information, visit https://www.mathworks.com/help/simbio/ug/global-local-sensitivity-analysis-gsa-lsa-simbiology.html#bsr0iqh'];
    case 'SimBiology:bmodel:DuplicateName'


        msg=removeHyperlinkAndClickHereText(msg);
        msg=[msg,' For more information, visit https://www.mathworks.com/help/simbio/ug/evaluation-of-model-component-names-in-expressions.html#mw_41e5dd76-4a98-4c22-a2c6-a36a612c2c5a'];
    case{'MATLAB:griddedInterpolant:CubicUniformOnlyWarnId','MATLAB:griddedInterpolant:CubicNeedsThreeWarnId'}



        identifier='SimBiology:Plotting:CUBIC_INTERPOLATION_WARNING';
        msg=getString(message(identifier));
    end

end

function newMsg=addCause(ex,msg)

    if isprop(ex,'cause')
        causes=ex.cause;
        additionalMessages=cell(size(causes));
        for i=1:length(causes)
            cause=causes{i};
            nextMsg=SimBiology.web.internal.errortranslator(cause);
            if isempty(cause.cause)
                additionalMessages{i}=nextMsg;
            else
                nestedCauseMsg=SimBiology.web.internal.errortranslator(cause.cause{1});
                additionalMessages{i}=[nextMsg,' ',nestedCauseMsg];
            end
        end
        newMsg=[strjoin([msg;additionalMessages(:)],'\n')];
    else
        newMsg=msg;
    end

end

function newMsg=trimLastNSentences(msg,n)

    try

        idx=strfind(msg,'.');
        newMsg=msg(1:idx(end-n));
    catch ex %#ok<NASGU>
        newMsg=msg;
    end

end

function[newMsg,success]=removeHyperlink(msg)

    try

        begin_startIdx=strfind(msg,'<a');
        end_startIdx=strfind(msg,'</a');



        begin_startIdx=begin_startIdx(end);
        end_startIdx=end_startIdx(end);



        endIdx=strfind(msg,'>');
        begin_endIdx=endIdx(end-1);
        end_endIdx=endIdx(end);

        newMsg=eraseBetween(msg,end_startIdx,end_endIdx,'Boundaries','inclusive');
        newMsg=eraseBetween(newMsg,begin_startIdx,begin_endIdx,'Boundaries','inclusive');

        success=true;
    catch ex %#ok<NASGU>

        newMsg=msg;
        success=false;
    end

end

function newMsg=removeHyperlinkAndClickHereText(msg)


    [newMsg,success]=removeHyperlink(msg);
    if success
        try
            idx=strfind(newMsg,'Click here');
            idx=idx(end);
            newMsg=newMsg(1:idx-1);
        catch ex %#ok<NASGU>
        end
    end

end

function newMsg=removeStackFromMessage(msg)

    try
        dmessage=double(msg);
        idx=find(dmessage==10);
        newLine=find(diff(idx)==1);
        messageEnd=idx(newLine(1))-1;
        newMsg=msg(1:messageEnd);
    catch
        newMsg=msg;
    end
end
