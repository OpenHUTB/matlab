classdef(Sealed)AnnotatedValue




    properties(SetAccess=immutable)
        Value=codergui.internal.undefined()
        Annotations struct=struct('text',{},'type',{})
        IsDefined logical
    end

    methods
        function this=AnnotatedValue(value,varargin)
            if nargin>0
                this.Value=value;
                if~isempty(varargin)
                    if isstruct(varargin{1})||numel(varargin)==1
                        narginchk(2,2);
                        this.Annotations=validateAnnotationStruct(varargin{1});
                    else
                        this.Annotations=validateAnnotationStruct(cell2struct(...
                        [varargin(1:2:end);varargin(2:2:end)],{'text','type'},1));
                    end
                end
            end
            this.IsDefined=~codergui.internal.undefined(this.Value);
        end
    end
end


function arg=validateAnnotationStruct(arg)
    if isstruct(arg)
        if~isempty(setxor(fieldnames(arg),{'text','type'}))
            error('Annotation structs should have "text" and "type" fields');
        end
        if~iscellstr({arg.text})
            error('Annotation text must be char vectors');
        end
        for i=1:numel(arg)
            arg(i).type=validatestring(arg(i).type,{'info','warning','error'});
        end
    elseif isa(arg,'message')
        arg=struct('text',arg.getString(),'type','info');
    elseif ischar(arg)
        arg=struct('text',arg,'type','info');
    elseif iscell(arg)
        annotations=cell(1,numel(arg));
        for i=1:numel(arg)
            annotations{i}=validateAnnotationStruct(arg{i});
        end
        arg=[annotations{:}];
    else
        error('Annotations should be structs or char vectors');
    end
end
