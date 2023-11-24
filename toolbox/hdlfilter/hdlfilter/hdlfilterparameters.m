function result=hdlfilterparameters(whichparams)

    hdl_parameters=PersistentHDLPropSet;

    if isempty(hdlgetparameter('target_language'))
        warning(message('hdlfilter:hdlfilterparameters:usingdefaults'));
        hdldefaultfilterparameters;
    end

    result={};

    if nargin==0
        whichparams='nondefault';

        targetlang=hdlgetparameter('target_language');
        if strcmpi(targetlang,'vhdl')
            result{end+1}='TargetLanguage';
            result{end+1}='VHDL';
        elseif strcmpi(targetlang,'verilog')


        else
            error(message('hdlfilter:hdlfilterparameters:UnknownTargetLanguage',targetlang));
        end
    else
        whichparams=lower(whichparams);
    end

    result=[result,creatematdata(hdl_parameters.CLI,whichparams)];

    n=1;
    while n<=length(result)&&~strcmpi(result{n},'CastBeforeSum')
        n=n+2;
    end
    if n<=length(result)&&strcmpi(result{n+1},'off')
        result={result{1:n-1},result{n+2:end}};
    end



