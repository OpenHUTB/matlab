classdef DeviceProperties<dynamicprops&hgsetget





    properties(Hidden,Access=private)

VideoDeviceObject

VideoInputObject

Source


DevicePropertyValues

ObjectDestroyed
    end

    properties(AbortSet,Dependent,SetAccess=public)

        SourceName='Default';
    end

    methods

        function obj=DeviceProperties(vidDevice,vidInput)


            obj.VideoDeviceObject=vidDevice;
            obj.VideoInputObject=vidInput;
            obj.Source=getselectedsource(obj.VideoInputObject);


            allFieldsStruct=rmfield(get(obj.Source),{'Parent','Selected','SourceName','Tag','Type'});
            allFields=fieldnames(allFieldsStruct);


            settableFields=fieldnames(set(obj.Source));


            for idx=1:length(allFields)
                prop=addprop(obj,allFields{idx});

                obj.(allFields{idx})=obj.Source.(allFields{idx});


                if ismember(allFields{idx},settableFields)

                    prop.SetAccess='public';
                    prop.SetMethod=@(obj,value)obj.setDynamicProp(prop.Name,value);


                    prop.Dependent=true;


                    propMetaData=findprop(obj.Source,allFields{idx});
                    prop.AbortSet=propMetaData.AbortSet;

                else
                    prop.SetAccess='private';
                end


                prop.GetAccess='public';

                prop.GetMethod=@(obj)obj.getDynamicProp(prop.Name);
            end

            obj.DevicePropertyValues=[];
        end


        function set.SourceName(obj,inSource)

            if isLocked(obj.VideoDeviceObject)
                error(message('imaq:videodevice:incorrectSetObjectLocked'));
            end


            restoreIfObjDestroyed(obj.VideoDeviceObject);


            sources=obj.VideoInputObject.Source;
            sourceName=sources.SourceName;
            if length(sources)==1
                sourceName={sourceName};
            end
            sourceStr=validatestring(inSource,sourceName,...
            'SourceName','SOURCENAME');


            obj.VideoInputObject.SelectedSourceName=sourceStr;
            obj.Source=getselectedsource(obj.VideoInputObject);
        end


        function sourceName=get.SourceName(obj)

            restoreIfObjDestroyed(obj.VideoDeviceObject);
            sourceName=obj.Source.SourceName;
        end


        function disp(obj)







            assertValidity(obj);

            if obj.ObjectDestroyed
                allFields=fieldnames(obj.DevicePropertyValues);
                propContainer=obj.DevicePropertyValues;
            else
                propContainer=obj.Source;
                allFieldsStruct=rmfield(get(propContainer),{'Parent','Selected','Tag','Type'});
                allFields=fieldnames(allFieldsStruct);
            end
            imaq.internal.DeviceProperties.dispImpl(allFields,propContainer);
        end


        function setDynamicProp(obj,propName,value)

            if isLocked(obj.VideoDeviceObject)
                error(message('imaq:videodevice:incorrectSetObjectLocked'));
            end


            restoreIfObjDestroyed(obj.VideoDeviceObject);


            pInfo=propinfo(obj.Source,propName);
            try
                switch pInfo.Type
                case 'string'
                    if strcmpi(pInfo.Constraint,'enum')
                        if~ischar(value)
                            w=warning;
                            warning OFF BACKTRACE;
                            warning(message('imaq:videodevice:notAString',propName));
                            warning(w);
                            value=num2str(value);
                        end
                        enumList=set(obj,propName);
                        value=validatestring(value,enumList,...
                        'DeviceProperties',upper(propName));
                    elseif strcmpi(pInfo.Constraint,'none')
                        validateattributes(value,{'char'},{'nonempty'},mfilename);
                    else
                        assert(false,'Unknown constraint');
                    end
                case{'double','integer'}
                    if isscalar(pInfo.DefaultValue)
                        if strcmpi(pInfo.Constraint,'bounded')

                            validateattributes(value,{'numeric'},{'scalar','>=',pInfo.ConstraintValue(1),...
                            '<=',pInfo.ConstraintValue(2),'nonnan','finite'},'DeviceProperties',upper(propName));
                        else
                            validateattributes(value,{'numeric'},{'scalar','nonnan','finite'},'DeviceProperties',upper(propName));
                        end
                    else
                        if strcmpi(pInfo.Constraint,'bounded')

                            validateattributes(value,{'numeric'},{'>=',pInfo.ConstraintValue(1),...
                            '<=',pInfo.ConstraintValue(2),'nonnan','finite'},'DeviceProperties',upper(propName));
                        else
                            validateattributes(value,{'numeric'},{'nonnan','finite'},'DeviceProperties',upper(propName));
                        end
                    end
                otherwise
                end
            catch ME
                throwAsCaller(ME);
            end


            obj.Source.(propName)=value;
        end


        function outVal=getDynamicProp(obj,propName)

            restoreIfObjDestroyed(obj.VideoDeviceObject);


            outVal=obj.Source.(propName);
        end

        function varargout=get(obj,prop)












            if nargin>1&&~ischar(prop)&&~iscellstr(prop)

                error(message('imaq:videodevice:invalidArgGet'));
            end

            if(nargin==1)

                names=sortrows(fieldnames(obj));
                for ii=1:length(names)
                    out.(names{ii})=obj.(names{ii});
                end
                varargout={out};
            else
                if iscell(prop)

                    len=length(prop);
                    out=cell(len,1);
                    for ii=1:len
                        propInfo=findprop(obj,prop{ii});
                        if isempty(propInfo)
                            error(message('imaq:videodevice:invalidDeviceSpecificProperty',prop{ii}));
                        end
                        if(strcmpi(propInfo.GetAccess,'private')||propInfo.Hidden)
                            error(message('imaq:videodevice:propAccessRestricted',prop{ii},class(obj)));
                        end
                        out{ii}=obj.(prop{ii});
                    end
                    varargout={out};
                else

                    propInfo=findprop(obj,prop);
                    if isempty(propInfo)
                        error(message('imaq:videodevice:invalidDeviceSpecificProperty',prop));
                    end
                    if(strcmpi(propInfo.GetAccess,'private')||propInfo.Hidden)
                        error(message('imaq:videodevice:propAccessRestricted',prop,class(obj)));
                    end
                    varargout={obj.(prop)};
                end
            end
        end

        function varargout=set(obj,varargin)


























            restoreIfObjDestroyed(obj.VideoDeviceObject);


            if numel(obj)~=1
                error(message('imaq:videodevice:nonScalarSet'));
            end

            switch(nargin)
            case 1

                fn=sortrows(fieldnames(obj));

                for ii=1:length(fn)
                    dPropInfo=obj.findprop(fn{ii});
                    if~strcmp(dPropInfo.SetAccess,'public')
                        continue;
                    end
                    val={set(obj,fn{ii})};
                    if isempty(val{1})
                        st.(fn{ii})={};
                    else
                        st.(fn{ii})=val;
                    end
                end
                varargout={st};
            case 2
                if isstruct(varargin{1})

                    st=varargin{1};
                    stfn=fieldnames(st);
                    for ii=1:length(stfn)
                        prop=stfn{ii};
                        try
                            imaq.internal.setProp(obj,prop,st.(prop));
                        catch ME
                            throwAsCaller(ME);
                        end
                    end
                else


                    propName=varargin{1};


                    if strcmpi(propName,'SourceName')
                        sources=obj.VideoInputObject.Source;
                        sourceName=sources.SourceName;
                        if length(sources)==1
                            varargout={{sourceName}};
                        else
                            varargout={sourceName};
                        end
                        return;
                    end


                    prop=findprop(obj,propName);
                    if isempty(prop)
                        error(message('imaq:videodevice:invalidDeviceSpecificProperty',varargin{1}));
                    elseif strcmpi(prop.SetAccess,'private')
                        error(message('imaq:videodevice:readOnlyProperty',varargin{1}));
                    else

                        propenum=set(obj.Source,propName);
                        varargout={propenum};
                    end
                end
            otherwise
                if iscell(varargin{1})
                    if(numel(varargin{1})~=numel(varargin{2}))
                        error(message('imaq:videodevice:invalidPVPairs'));
                    end
                    props=varargin{1};
                    values=varargin{2};
                    for ii=1:numel(varargin{1})


                        try
                            imaq.internal.setProp(obj,props{ii},values{ii});
                        catch ME
                            throw(ME);
                        end
                    end
                    return;
                end

                if mod(length(varargin),2)
                    error(message('imaq:videodevice:invalidPVPairs'));
                end
                for ii=1:2:length(varargin)


                    try
                        imaq.internal.setProp(obj,varargin{ii},varargin{ii+1});
                    catch ME
                        throw(ME);
                    end
                end
                varargout={};
            end
        end
    end

    methods(Static,Access=private)


        function dispImpl(fields,propContainer)
            cr=sprintf('\n');
            deviceSpecificProperties=[sprintf('        %s: ''%s''','SourceName',num2str(propContainer.SourceName)),cr];

            for idx=1:length(fields)
                if strcmp(fields{idx},'SourceName')
                    continue;
                end
                if isscalar(propContainer.(fields{idx}))
                    strToDisp=[sprintf('        %s: %s',fields{idx},num2str(propContainer.(fields{idx}))),cr];
                elseif ischar(propContainer.(fields{idx}))
                    strToDisp=[sprintf('        %s: ''%s''',fields{idx},num2str(propContainer.(fields{idx}))),cr];
                elseif isempty(propContainer.(fields{idx}))
                    strToDisp=[sprintf('        %s: [%dx%d %s]',fields{idx},size(propContainer.(fields{idx})),class(propContainer.(fields{idx}))),cr];
                else
                    arrayStr=sprintf('%.5g ',propContainer.(fields{idx}));
                    strToDisp=[sprintf('        %s: [%s]',fields{idx},arrayStr(1:end-1)),cr];
                end
                deviceSpecificProperties=[deviceSpecificProperties,strToDisp];%#ok<AGROW>
            end
            fprintf('      Device Properties:%s%s%s',cr,deviceSpecificProperties,cr);
        end
    end
    methods(Access=private)
        function assertValidity(obj)

            if~isvalid(obj)

                msgObject=message('imaq:videodevice:invalidObject');
                throwAsCaller(MException('imaq:videodevice:invalidObject',msgObject.getString));
            end
        end
    end

    methods(Access={?imaq.internal.VideoDeviceInternal})
        function delete(~)
        end
    end

    methods(Hidden)

        function restoreDeviceProperties(obj,vidInputObject)

            obj.VideoInputObject=vidInputObject;


            set(obj.VideoInputObject,'SelectedSourceName',obj.DevicePropertyValues.SourceName);
            obj.Source=getselectedsource(obj.VideoInputObject);


            allFields=fieldnames(obj.DevicePropertyValues);

            settableFields=fieldnames(set(obj.Source));
            readOnlyFields=setdiff(allFields,settableFields);
            settableDevPropStruct=rmfield(obj.DevicePropertyValues,readOnlyFields);
            settableDevPropStructFields=fieldnames(settableDevPropStruct);
            for idx=1:length(settableDevPropStructFields)
                currentFieldName=settableDevPropStructFields{idx};

                set(obj.Source,currentFieldName,obj.DevicePropertyValues.(currentFieldName));
            end
            obj.ObjectDestroyed=false;
            obj.DevicePropertyValues=[];
        end


        function backupDeviceProperties(obj)

            allFieldsStruct=rmfield(get(obj.Source),{'Parent','Selected','Tag','Type'});
            allFields=fieldnames(allFieldsStruct);

            for idx=1:length(allFields)
                currentFieldName=allFields{idx};
                obj.DevicePropertyValues.(currentFieldName)=obj.Source.(currentFieldName);
            end
            obj.ObjectDestroyed=true;
        end

        function[videoinputObj]=getVideoInputObject(obj)
            videoinputObj=obj.VideoInputObject;
        end
    end
end
