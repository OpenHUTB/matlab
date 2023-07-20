function out=getHyperlink(parameter,type,varargin)




























    if nargin<2
        type='sldiag';
    end

    cssd=configset.internal.getConfigSetStaticData;
    obj=cssd.getParam(parameter);
    if iscell(obj)
        obj=obj{1};
    end

    switch type
    case 'sldiag'
        out=getHyperlink(obj,varargin{:});
    case 'matlab'
        out=getMATLABHyperlink(obj,varargin{:});
    case 'suggestion'
        out=getSuggestionHyperlink(obj,varargin{:});
    case 'fixit'
        warnConstraints(obj);
        out=getFixItHyperlink(obj,varargin{:});
    case 'suppression'
        warnConstraints(obj);
        out=getSuppressionHyperlink(obj,varargin{:});
    end

    function out=getHyperlink(obj)
        text=regexprep(obj.getDescription,':$','');
        out=['<sldiag objui="configset" objparam="',obj.Name,'">',text,'</sldiag>'];
    end

    function out=getMATLABHyperlink(obj,model)
        text=regexprep(obj.getDescription,':$','');
        out=['<a href="matlab:configset.internal.open(''',model,''',''',obj.Name,''')">',text,'</a>'];
    end

    function out=getSuggestionHyperlink(obj,text)
        if nargin<2
            text=[' ',getHyperlink(obj)];
        end
        out=strrep(['<action cmd="matlab:configset.internal.open(''{0}'',''',obj.Name,''')" type="suggestion">',text,'</action>'],'''','''''');
    end

    function out=getFixItHyperlink(obj,text)
        if nargin<2
            text=[' ',getHyperlink(obj)];
            if~isempty(obj.ModelRef)
                text=[text,' (may impact referenced or referencing models)'];
            end
        end

        out=strrep(['<action cmd="matlab:configset.internal.fixIt(''{0}'',''',obj.Name,''',''%s'')" type="fixit">',text,'</action>'],'''','''''');
    end

    function out=getSuppressionHyperlink(obj,value)
        if nargin<2
            value='%s';
        end
        text=['Suppress this message by setting ',getHyperlink(obj),' to ''''',value,''''''];
        out=sprintf(getFixItHyperlink(obj,'%s'),value,text);
    end
end

function warnConstraints(obj)
    if~isempty(obj.ModelRef)
        warning('Parameter has model reference constraints.');
        disp(obj.ModelRef);
    end
    if~isempty(obj.Dependency)&&~isequal(obj.Dependency.Parent,{'IsERTTarget'})
        warning('Parameter has dependency.');
        disp(obj.Dependency.Parent)
    end
    if obj.isInvertValue
        warning('Command-line value is inverted.');
    end
end


