classdef RLC<rf.internal.circuit.Element






    methods
        function obj=RLC(varargin)
            obj=obj@rf.internal.circuit.Element(varargin{:});
        end
    end


    methods(Hidden,Access=protected)
        function initializeTerminalsAndPorts(obj)
            obj.Terminals={'p','n'};
        end
    end
    methods(Hidden,Access={?capacitor,?inductor})
        function nodes=getStubNodes(obj,stubMode)

            if~isempty(obj.Parent)&&numel(obj.ParentNodes)==2
                ckt=obj.Parent;

                if length(ckt.TerminalNodes)==length(ckt.Terminals)
                    negPortTerm=unique(ckt.TerminalNodes(...
                    contains(ckt.Terminals,"-")));
                    if numel(negPortTerm)~=1
                        negPortTerm=-1;
                    end
                else
                    negPortTerm=-1;
                end
                if strcmpi(stubMode,'Series')
                    nodes=[obj.ParentNodes(1:2),negPortTerm,negPortTerm];
                else




                    nonNegNode=obj.ParentNodes~=negPortTerm;



                    if sum(nonNegNode)==1
                        nodes=[obj.ParentNodes(nonNegNode)...
                        ,max(ckt.Nodes)+1...
                        ,obj.ParentNodes(~nonNegNode)...
                        ,obj.ParentNodes(~nonNegNode)];
                    else
                        nodes=[];
                    end
                end
            else
                nodes=[];
            end
        end
    end

end