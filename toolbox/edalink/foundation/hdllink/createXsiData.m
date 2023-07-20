function xsiData=createXsiData(varargin)






















    p=inputParser;

    langOpts={'vhdl','vlog','svlog'};
    precOpts=CosimWizardPkg.CosimWizardData.precStrToExp.keys();
    typeOpts={'Logic','Integer','Real'};

    p.addParameter('design','xsim.dir/design/xsimk',@(x)ischar(x));
    p.addParameter('lang','vhdl',@(x)any(validatestring(x,langOpts)));
    p.addParameter('prec','1ns',@(x)any(validatestring(x,precOpts)));
    p.addParameter('types',{'Logic','Logic','Logic'},@(x)(l_checkTypes(x,typeOpts)));
    p.addParameter('dims',{8,8,8},@l_checkDims);
    p.addParameter('rstnames',{},@l_checkRstNames);
    p.addParameter('rstvals',{},@l_checkRstVals);
    p.addParameter('rstdurs',{},@l_checkRstDurs);

    p.parse(varargin{:});

    raw=p.Results;

    assert(all(size(raw.dims)==size(raw.types)),"dims and types must have same number of elements");
    dbldims=cellfun(@(x)(double(x)),raw.dims,'UniformOutput',false);
    siginfo=struct('Dims',dbldims,'Type',cellfun(@(x)(l_typeEnumVal(x)),raw.types,'UniformOutput',false));

    assert(all(size(raw.rstnames)==size(raw.rstvals)),"rstnames and rstvals must have same number of elements");
    assert(all(size(raw.rstvals)==size(raw.rstdurs)),"rstvals and rstdurs must have same number of elements");
    rstinfo=struct('Name',raw.rstnames,'InitialValue',raw.rstvals,'Duration',raw.rstdurs);

    xsiData=struct(...
    'ProductName','EDA Simulator Link VS',...
    'DesignLib',raw.design,...
    'Language',l_langEnumVal(raw.lang),...
    'TimePrecision',l_timePrecEnumVal(raw.prec),...
    'HdlSigInfo',siginfo,...
    'ResetInfo',rstinfo);

end

function TF=l_checkTypes(x,typeOpts)
    TF=all(cellfun(@(eachval)(any(validatestring(eachval,typeOpts))),x));
end
function TF=l_checkDims(x)
    TF=iscell(x);
    if TF
        cellfun(@(eachval)(validateattributes(eachval,'numeric',{'positive'})),x);
    end
    TF=true;
end
function TF=l_checkRstVals(x)
    if isempty(x)
        TF=true;
    else
        TF=iscell(x);
        if TF
            cellfun(@(eachval)(validateattributes(eachval,'numeric',{'nonnegative'})),x);
        end
        TF=true;
    end
end
function TF=l_checkRstDurs(x)
    TF=l_checkRstVals(x);
end
function TF=l_checkRstNames(x)
    if isempty(x)
        TF=true;
    else
        TF=iscell(x);
        if TF
            cellfun(@(eachval)(ischar(eachval)),x);
        end
        TF=true;
    end
end
function lval=l_langEnumVal(lang)
    switch(lang)
    case 'vlog',lval=0;
    case 'vhdl',lval=1;
    case 'svlog',lval=2;
    end
end
function tval=l_timePrecEnumVal(prec)
    tval=CosimWizardPkg.CosimWizardData.precStrToExp(prec);
end

function tval=l_typeEnumVal(type)
    switch(type)
    case 'Logic',tval=12;
    case 'Integer',tval=14;
    case 'Real',tval=15;
    otherwise,error('(internal) bad HDL signal type');
    end
end
