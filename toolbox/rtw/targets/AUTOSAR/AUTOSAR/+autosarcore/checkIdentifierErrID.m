function[isValid,errId]=checkIdentifierErrID(str,idType,maxShortNameLength)


































    if nargin<2
        assert(false,'Expecting idType of shortName, absShortNamePath or absPath');
    end

    validShortNamePattern='[a-zA-Z]([a-zA-Z0-9]|_[a-zA-Z0-9])*_?';




    switch lower(idType)
    case 'shortname'

        validIdentPattern=sprintf('^%s$',validShortNamePattern);
    case 'abspathshortname'

        validIdentPattern=sprintf('^(/%s){2,}$',validShortNamePattern);
    case 'abspath'

        validIdentPattern=sprintf('^(/%s){1,}$',validShortNamePattern);
    otherwise
        DAStudio.error('RTW:autosar:wrongIdentifierType',idType);
    end


    isValid=~isempty(regexp(str,validIdentPattern,'ONCE'));

    out=regexp(str,'(?<shortname>[^/]*)','names');
    isValid=isValid&&all(cellfun('length',{out(:).shortname})<=maxShortNameLength);


    errId='';



    if~isValid
        switch lower(idType)

        case 'shortname'
            if checkInvalidStartCharacter(str)
                errId='RTW:autosar:invalidShortNameStart';
            elseif checkInvalidCharacters(str)
                errId='RTW:autosar:invalidShortNameCharacters';
            elseif checkInvalidUnderscores(str)
                errId='RTW:autosar:invalidShortNameUnderscores';
            elseif checkInvalidLength(str,maxShortNameLength)
                errId='RTW:autosar:invalidShortNameLength';


            else
                assert(false,'Could not find the error ID for the invalid shortname.');
            end

        case 'abspathshortname'

            charVectors=strsplit(str,'/');


            charVectorsNoEmpty=charVectors(~cellfun(@isempty,charVectors));



            maxShortNameLenthCell=num2cell(ones(1,length(charVectorsNoEmpty))*maxShortNameLength);



            if checkInvalidDelimiter(str,2)||isempty(charVectors{end})
                errId='RTW:autosar:invalidAbsPathShortNameDelimiter';



            elseif(any(cellfun(@checkInvalidStartCharacter,charVectorsNoEmpty))||checkInvalidStartDelimiter(str))
                errId='RTW:autosar:invalidAbsPathShortNameStart';


            elseif(any(cellfun(@checkInvalidCharacters,charVectorsNoEmpty))||checkInvalidDelimiters(str))
                errId='RTW:autosar:invalidAbsPathShortNameCharacters';
            elseif any(cellfun(@checkInvalidUnderscores,charVectorsNoEmpty))
                errId='RTW:autosar:invalidAbsPathShortNameUnderscores';
            elseif any(cellfun(@checkInvalidLength,charVectorsNoEmpty,maxShortNameLenthCell))
                errId='RTW:autosar:invalidAbsPathShortNameLength';


            else
                assert(false,'Could not find the error ID for the invalid abspathshortname.');
            end

        case 'abspath'

            charVectors=strsplit(str,'/');


            charVectorsNoEmpty=charVectors(~cellfun(@isempty,charVectors));



            maxShortNameLenthCell=num2cell(ones(1,length(charVectorsNoEmpty))*maxShortNameLength);



            if checkInvalidDelimiter(str,1)||isempty(charVectors{end})
                errId='RTW:autosar:invalidAbsPathDelimiter';



            elseif(any(cellfun(@checkInvalidStartCharacter,charVectorsNoEmpty))||checkInvalidStartDelimiter(str))
                errId='RTW:autosar:invalidAbsPathStart';


            elseif(any(cellfun(@checkInvalidCharacters,charVectorsNoEmpty))||checkInvalidDelimiters(str))
                errId='RTW:autosar:invalidAbsPathCharacters';
            elseif any(cellfun(@checkInvalidUnderscores,charVectorsNoEmpty))
                errId='RTW:autosar:invalidAbsPathUnderscores';
            elseif any(cellfun(@checkInvalidLength,charVectorsNoEmpty,maxShortNameLenthCell))
                errId='RTW:autosar:invalidAbsPathLength';


            else
                assert(false,'Could not find the error ID for the invalid abspath.');
            end

        otherwise
            DAStudio.error('RTW:autosar:wrongIdentifierType',idType);
        end
    end

end






function result=checkInvalidDelimiter(str,numDelimiters)
    result=(length(regexp(str,'[//]'))<numDelimiters);
end



function result=checkInvalidStartCharacter(str)
    if isempty(str)
        result=true;
    else
        result=(isempty(regexp(str(1),'[a-zA-Z]','ONCE')));
    end
end


function result=checkInvalidStartDelimiter(str)
    result=(isempty(regexp(str(1),'[//]','ONCE')));
end



function result=checkInvalidCharacters(str)
    result=false;
    for j=1:strlength(str)
        if isempty(regexp(str(j),'[a-zA-Z0-9\_]','ONCE'))
            result=true;
        end
    end
end


function result=checkInvalidUnderscores(str)
    result=(~isempty(regexp(str,'[/_]{2,}','ONCE'))&&length(regexp(str,'[/_]'))>1);
end


function result=checkInvalidDelimiters(str)
    result=(~isempty(regexp(str,'[//]{2,}','ONCE'))&&length(regexp(str,'[/_]'))>1);
end


function result=checkInvalidLength(str,maxShortNameLength)
    result=(strlength(str)>maxShortNameLength);
end



