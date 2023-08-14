function out=utilhandler(action,varargin)

    switch(action)
    case 'buildAttributeStruct'
        out=buildAttributeStruct(varargin{:});
    case 'getAttribute'
        out=getAttribute(varargin{:});
    case 'getArrayValues'
        out=getArrayValues(varargin{:});
    case 'getExplorerSectionTemplate'
        out=getExplorerSectionTemplate;
    case 'getField'
        out=getField(varargin{:});
    case 'getInternalStructTemplate'
        out=getInternalStructTemplate;
    case 'getObject'
        out=getObject(varargin{:});
    case 'getVectorAttributes'
        out=getVectorAttributes(varargin{:});
    end


    function out=buildAttributeStruct(nodes,attributes,varargin)

        out='';

        if(nargin==1)||isempty(nodes)
            return;
        end

        jsAttributes=attributes;
        if(nargin==3)
            jsAttributes=varargin{1};
        end

        out=struct;
        for i=1:numel(nodes)
            for j=1:numel(attributes)
                out(i).(jsAttributes{j})=getAttribute(nodes(i),attributes{j});
            end
        end


        function out=getArrayValues(argNode,valueProp,projectVersion)

            out={};

            if strcmp(projectVersion,'4.1')
                values=getAttribute(argNode,'Value');
                values=values(2:end-1);

                if~isempty(values)
                    out=strsplit(values,',');
                    out=cellfun(@strtrim,out,'UniformOutput',false);
                end
            else
                count=getAttribute(argNode,sprintf('%sCount',valueProp));
                if~isempty(count)
                    out=cell(count,1);
                    for i=1:count
                        out{i}=getAttribute(argNode,sprintf('%s%d',valueProp,(i-1)));
                    end
                end
            end


            function out=getAttribute(node,attribute,varargin)

                out='';
                if nargin==3
                    out=varargin{1};
                end

                if isfield(node,[attribute,'Attribute'])
                    out=node.([attribute,'Attribute']);

                    if isstring(out)||isduration(out)
                        out=char(out);
                    end

                    if isa(out,'missing')
                        out='';
                    end

                    if strcmpi(out,'true')
                        out=true;
                    elseif strcmpi(out,'false')
                        out=false;
                    else


                        if ischar(out)&&~contains(out,',')
                            numValue=str2double(out);
                            if~isnan(numValue)
                                out=numValue;
                            end
                        end

                        if isinf(out)
                            out=num2str(out);
                        end

                        if strcmpi(out,'Infinity')
                            out='Inf';
                        elseif strcmpi(out,'-Infinity')
                            out='-Inf';
                        end
                    end
                end


                function explorerStep=getExplorerSectionTemplate


                    explorerStep=struct;
                    explorerStep.overlayState=false;
                    explorerStep.type='Explorer';
                    explorerStep.version=1;
                    explorerStep.internal=getInternalStructTemplate;
                    explorerStep.sliders=[];


                    function out=getField(node,field)

                        out='';

                        if~isempty(node)&&isfield(node,field)
                            out=node.(field);
                            if isstring(out)
                                out=char(out);
                            end
                        end

                        if isa(out,'missing')
                            out='';
                        end


                        function out=getInternalStructTemplate


                            out=struct;
                            out.activeStep=false;
                            out.id=-1;
                            out.isSetup=false;
                            out.outputArguments={};
                            out.args=struct;
                            out.argType='';


                            function obj=getObject(model,name)

                                if isempty(model)||isempty(name)
                                    obj=[];
                                    return;
                                end

                                obj=SimBiology.internal.getObjectFromPQN(model,name);

                                if isempty(obj)
                                    obj=sbioselect(model,'Name',name);
                                end

                                if numel(obj)>1
                                    obj=obj(1);
                                end


                                function out=getVectorAttributes(node,field)

                                    out=[];

                                    count=getAttribute(node,[field,'Count']);
                                    if~isempty(count)
                                        out=zeros(1,count);
                                        for i=1:count
                                            out(i)=getAttribute(node,[field,num2str(i-1)]);
                                        end
                                    end
