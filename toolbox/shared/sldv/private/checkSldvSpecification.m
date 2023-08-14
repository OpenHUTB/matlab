function[spec,errId]=checkSldvSpecification(spec)










    errId='';

    try
        if iscell(spec)
            for i=1:length(spec)
                spec{i}=checkElem(spec{i});
            end
        elseif isstruct(spec)
            spec=checkElemForStructs(spec);
        else
            spec={checkElem(spec)};
        end
    catch myException %#ok<NASGU>
        spec={};
        errId='Sldv:CheckSpec:SyntaxErrInParam';
    end
end

function elem=checkElemForStructs(spec)



    if slavteng('feature','BusParameterTuning')



        if isstruct(spec)
            fieldNames=fieldnames(spec);
            for idx=1:length(fieldNames)
                elem.(fieldNames{idx})=checkElemForStructs(spec.(fieldNames{idx}));
            end
        elseif iscell(spec)
            for i=1:length(spec)
                elem{i}=checkElem(spec{i});%#ok<AGROW>
            end
        else
            elem={checkElem(spec)};
        end

    end
end

function elem=checkElem(spec)
    if isa(spec,'Sldv.Point')||isa(spec,'Sldv.Interval')
        elem=spec;

    elseif isnumeric(spec)||islogical(spec)
        if isempty(spec)
            elem=[];
        elseif length(spec)==1
            elem=Sldv.Point(spec);
        elseif(length(spec)==2)
            elem=Sldv.Interval(spec(1),spec(2));
        else
            error(message('Sldv:CheckSpec:Syntax'));
        end

    else
        error(message('Sldv:CheckSpec:Syntax'));
    end
end
