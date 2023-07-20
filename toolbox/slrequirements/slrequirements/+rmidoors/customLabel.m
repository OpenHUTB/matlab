function varargout=customLabel(varargin)
















































    try
        customFormat=rmi.settings_mgr('get','linkSettings','doorsLabelFormat');
    catch ME %#ok<NASGU>
        customFormat='';
    end

    switch nargin
    case 0
        varargout{1}=customFormat;
    case 1
        if strcmp(varargin{1},customFormat)
            varargout{1}=false;
        elseif isValidFormat(varargin{1})

            linkSettings=rmi.settings_mgr('get','linkSettings');
            linkSettings.doorsLabelFormat=varargin{1};
            rmi.settings_mgr('set','linkSettings',linkSettings);
            definedAttributeNames('clearall');
            varargout{1}=true;
        else
            warning(message('Slvnv:reqmgt:customLabel:InvalidLabelFormatString',varargin{1}));
            varargout{1}=false;
        end
    case 2
        if strcmp(varargin{2},'clear')
            varargout{1}=definedAttributeNames(varargin{1});
        else

            if isempty(customFormat)

                varargout{1}='';
            else

                varargout{1}=makeLabel(customFormat,varargin{:});
            end
        end
    otherwise
        error(message('Slvnv:reqmgt:customLabel:InvalidNumberOfArguments'));
    end
end

function result=isValidFormat(in)
    if isempty(in)
        result=true;
        return;
    end
    formatIdx=strfind(in,'%');
    if isempty(formatIdx)
        result=false;
    elseif formatIdx(end)==length(in)
        result=false;
    else
        result=true;
        for i=1:length(formatIdx)
            thisIdx=formatIdx(i);
            nextChar=in(thisIdx+1);
            if any(nextChar==double('htpnmPMU'))
                continue;
            elseif nextChar=='<'
                endIdx=thisIdx+strfind(in(thisIdx+1:end),'>');
                if isempty(endIdx)
                    result=false;
                    break;
                elseif i<length(formatIdx)&&endIdx(1)>formatIdx(i+1)
                    result=false;
                    break;
                elseif isempty(strtrim(in(thisIdx+2:endIdx(1)-1)))
                    result=false;
                    break;
                else
                    continue;
                end
            elseif any(nextChar==double('123456789'))

                limit=str2num(in(thisIdx+1:end));%#ok<ST2NM>
                if isempty(limit)
                    result=false;
                elseif limit>0
                    result=true;
                else
                    result=false;
                end
                break;
            else
                result=false;
                break;
            end
        end
    end
end

function label=makeLabel(formatString,module,object)
    if~isempty(object)
        if ischar(object)
            if object(1)=='#'
                object=object(2:end);
            end
        else
            object=num2str(object);
        end
    end
    label='';
    pos=1;
    while pos<=length(formatString)
        if formatString(pos)=='%'
            [data,pos]=getData(pos+1,formatString(pos+1:end),module,object);
            if isa(data,'double')

                if length(label)>data
                    label=[label(1:data),'...'];
                end
                return;
            else
                label=[label,data];%#ok<AGROW>
            end
        else
            label=[label,formatString(pos)];%#ok<AGROW>
            pos=pos+1;
        end
    end
end

function[data,pos]=getData(pos,format,module,object)
    data='';
    switch format(1)
    case 'h'
        if~isempty(object)
            data=rmidoors.getObjAttribute(module,object,'Object Heading');
            data=strrep(data,newline,'  ');
        end
        pos=pos+1;
    case 't'
        if~isempty(object)
            data=rmidoors.getObjAttribute(module,object,'Object Text');
            data=strrep(data,newline,'  ');
        end
        pos=pos+1;
    case 'p'
        data=rmidoors.getModulePrefix(module);
        pos=pos+1;
    case 'n'
        prefix=rmidoors.getModulePrefix(module);
        data=strrep(object,prefix,'');
        pos=pos+1;
    case 'm'
        data=module;
        pos=pos+1;
    case 'P'
        moduleFullName=rmidoors.getModuleAttribute(module,'FullName');
        [data,~]=fileparts(moduleFullName);
        pos=pos+1;
    case 'M'
        moduleFullName=rmidoors.getModuleAttribute(module,'FullName');
        [~,data]=fileparts(moduleFullName);
        pos=pos+1;
    case 'U'
        if~isempty(object)
            data=rmidoors.getObjAttribute(module,object,'URL');
        end
        pos=pos+1;
    case '<'
        shift=strfind(format,'>');
        pos=pos+shift(1);
        if~isempty(object)
            attrName=format(2:shift(1)-1);
            moduleAttributes=definedAttributeNames(module,object);
            if contains(moduleAttributes,['|',attrName,'|'])
                data=rmidoors.getObjAttribute(module,object,attrName);
            end
        end
    otherwise
        if format(1)>='1'&&format(1)<='9'
            data=str2num(format);%#ok<ST2NM>
            if isempty(data)
                error(message('Slvnv:reqmgt:customLabel:InvalidLabelFormatString',format));
            end
        else
            error(message('Slvnv:reqmgt:customLabel:InvalidLabelFormatString',format));
        end
    end
end

function result=definedAttributeNames(module,object)
    persistent allAttributesMap;
    mlock;
    if isempty(allAttributesMap)
        allAttributesMap=containers.Map('KeyType','char','ValueType','char');
    end
    if nargin==1
        if strcmp(module,'clearall')

            result=allAttributesMap.Count;
            if result>0
                allAttributesMap=containers.Map('KeyType','char','ValueType','char');
            end
        elseif isKey(allAttributesMap,module)

            remove(allAttributesMap,module);
            result=true;
        else

            result=false;
        end
    else
        if isKey(allAttributesMap,module)
            result=allAttributesMap(module);
        else
            attributesTable=rmidoors.getObjAttribute(module,object,'all attributes');
            result='|';
            for i=1:size(attributesTable,1)
                result=[result,attributesTable{i,1},'|'];%#ok<AGROW>
            end
            allAttributesMap(module)=result;
        end
    end
end

