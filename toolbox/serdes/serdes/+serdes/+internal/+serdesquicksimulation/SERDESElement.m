classdef(Abstract)SERDESElement<serdes.internal.serdesquicksimulation.Element




    methods(Access=protected,Hidden)
        function p=makeInputParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',obj.DefaultName);
        end

        function setParsedProperties(obj,p)
            if~isvarname(p.Results.Name)
                error(message('serdes:serdesdesigner:ValidateMLNameNotAVarName',...
                'element name',p.Results.Name))
            end
            obj.Name=p.Results.Name;
        end
    end

    methods
        function obj=SERDESElement(varargin)

            narginchk(0,12)
            p=makeInputParser(obj);
            parse(p,varargin{:});
            setParsedProperties(obj,p);
        end
    end

    methods(Access=protected)
        function copyProperties(in,out)

            XTalkSpecificationIndex=0;
            if isempty(in.ParameterNames)
                out.ParameterNames=[];
            else
                for i=1:numel(in.ParameterNames)
                    out.ParameterNames{i}=in.ParameterNames{i};
                    if strcmpi(in.ParameterNames{i},'XTalkSpecification')&&isa(in,'serdes.internal.apps.serdesdesigner.channel')

                        XTalkSpecificationIndex=i;
                    end
                end
            end
            if isempty(in.ParameterValues)
                out.ParameterValues=[];
            else
                in.updateAmiParameterList();
                if XTalkSpecificationIndex>0

                    SavedXTalkSpecification=in.ParameterValues{XTalkSpecificationIndex};
                    in.ParameterValues{XTalkSpecificationIndex}='Custom';
                    out.XTalkSpecification='Custom';
                end
                for i=1:numel(in.ParameterValues)
                    out.ParameterValues{i}=in.ParameterValues{i};
                    if isa(out,'serdes.internal.apps.serdesdesigner.rcTx')||...
                        isa(out,'serdes.internal.apps.serdesdesigner.rcRx')||...
                        isa(out,'serdes.internal.apps.serdesdesigner.channel')
                        out.(out.ParameterNames{i})=in.ParameterValues{i};
                    elseif~isInactiveProperty(in,in.ParameterNames{i})
                        amiParameter=in.getAmiParameter(in.ParameterNames{i});
                        if~isempty(amiParameter)
                            out.(out.ParameterNames{i})=amiParameter.CurrentValue;
                        else
                            out.(out.ParameterNames{i})=in.ParameterValues{i};
                        end
                    end
                end
                if XTalkSpecificationIndex>0

                    in.ParameterValues{XTalkSpecificationIndex}=SavedXTalkSpecification;
                    out.XTalkSpecification=SavedXTalkSpecification;
                end
            end
        end
    end

    methods(Hidden)
        function exportScript(obj,sw,vn,useSerdesBlock)
            if useSerdesBlock

                if isa(obj,'serdes.internal.apps.serdesdesigner.agc')
                    block=serdes.AGC;
                elseif isa(obj,'serdes.internal.apps.serdesdesigner.ffe')
                    block=serdes.FFE;
                elseif isa(obj,'serdes.internal.apps.serdesdesigner.vga')
                    block=serdes.VGA;
                elseif isa(obj,'serdes.internal.apps.serdesdesigner.satAmp')
                    block=serdes.SaturatingAmplifier;
                elseif isa(obj,'serdes.internal.apps.serdesdesigner.dfeCdr')
                    block=serdes.DFECDR;
                elseif isa(obj,'serdes.internal.apps.serdesdesigner.cdr')
                    block=serdes.CDR;
                elseif isa(obj,'serdes.internal.apps.serdesdesigner.ctle')
                    block=serdes.CTLE;
                elseif isa(obj,'serdes.internal.apps.serdesdesigner.transparent')
                    block=serdes.PassThrough;
                else
                    block=obj;
                end
            else

                block=obj;
            end


            addcr(sw,'%s = %s;',vn,class(block));


            if isprop(block,'Name')
                addcr(sw,'%s.Name = ''%s'';',vn,block.Name);
            end

            if isprop(block,'BlockName')
                block.BlockName=obj.BlockName;
                addcr(sw,'%s.BlockName = ''%s'';',vn,block.BlockName);
            end


            if block~=obj
                props=properties(obj);
                if~isempty(props)
                    for i=1:numel(props)
                        if serdes.internal.apps.serdesdesigner.BlockDialog.hasSetAccess(obj,props{i})&&...
                            isprop(block,props{i})
                            block.(props{i})=obj.(props{i});
                        end
                    end
                end
            end


            op=properties(block);
            if numel(op)>0
                for i=1:numel(op)
                    if~isempty(block.(op{i}))&&...
                        (isa(block,'serdes.internal.apps.serdesdesigner.rcTx')||...
                        isa(block,'serdes.internal.apps.serdesdesigner.rcRx')||...
                        isa(block,'serdes.internal.apps.serdesdesigner.channel')||...
                        serdes.internal.apps.serdesdesigner.BlockDialog.hasSetAccess(block,op{i})&&...
                        ~serdes.internal.apps.serdesdesigner.BlockDialog.isNoDisplayInSerDesDesignerApp(block,op{i}))
                        if isnumeric(block.(op{i}))||islogical(block.(op{i}))
                            addcr(sw,'%s.%s = %s;',vn,op{i},...
                            serdes.internal.apps.serdesdesigner.BlockDialog.getStringValue(block.(op{i})));
                        else
                            addcr(sw,'%s.%s = ''%s'';',vn,op{i},block.(op{i}));
                        end
                    end
                end
            end
        end
    end

    methods(Hidden,Access=protected)
        function plist1=getLocalPropertyList(obj)
            plist1.Name=obj.Name;
            plist1.ParameterNames=obj;
        end

        function initializeTerminalsAndPorts(obj)
            obj.Ports={'p1','p2'};
            obj.Terminals={'p1+','p2+','p1-','p2-'};
        end
    end
end
