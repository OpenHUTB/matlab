classdef UserVisibleDataObjectStrategy<coderapp.internal.config.DataObjectStrategy



    properties(GetAccess=private,SetAccess=immutable)
ExplicitAttributes
    end

    methods
        function this=UserVisibleDataObjectStrategy(dataObjectClass,attrs)
            this@coderapp.internal.config.DataObjectStrategy(dataObjectClass);
            if nargin>1
                this.ExplicitAttributes=attrs;
            end
        end
    end

    methods
        function imported=import(this,attr,value)
            switch attr
            case 'Help'
                imported=this.toDocRef(value);
            otherwise
                imported=value;
            end
        end

        function varargout=fromSchema(this,attr,value,varargin)
            if any(strcmp(attr,this.MessageAttributes))
                [varargout{1:nargout}]=this.schemaImportPossibleMessage(value,varargin{:},attr);
            else
                varargout{1}=this.import(attr,value);
            end
        end

        function resolveMessages(~,dataObj,unresolvedMsgs)
            for unresolved=unresolvedMsgs
                if ischar(unresolved.Path)
                    switch unresolved.Path
                    case 'Name'
                        if isempty(dataObj.Name)
                            dataObj.Name=message(unresolved.MessageKey).getString();
                        end
                    case 'Description'
                        if isempty(dataObj.Description)
                            dataObj.Description=message(unresolved.MessageKey).getString();
                        end
                    end
                end
            end
        end
    end

    methods(Access=protected)
        function attrs=doGetAttributes(this)
            if iscell(this.ExplicitAttributes)
                attrs=this.ExplicitAttributes;
            else
                attrs=properties(this.DataObjectClass);
            end
        end

        function attrs=doGetMessageKeyAttributes(~)
            attrs={'Name','Description'};
        end
    end

    methods(Static)
        function[value,unresolved]=schemaImportPossibleMessage(value,mfzModel,escapeMode,attr)
            [value,isMsg]=coderapp.internal.config.DataObjectStrategy.unescapeString(value,escapeMode);
            if isMsg
                if nargin<4
                    attr='';
                end
                unresolved=coderapp.internal.config.schema.UnresolvedMessage(mfzModel,...
                struct('MessageKey',value,'Path',attr));
                value='';
            else
                unresolved=[];
            end
        end
    end
end
