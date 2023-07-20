classdef RungLexer<handle



























    properties
expr
        out(1,:)cell={};
        SimplOpenBrackCount(1,1)double=0;
        ArrOpenBrackCount(1,1)double=0;
    end

    methods
        function obj=RungLexer(expr)


            obj.expr=expr;
        end

        function process(obj)
            if~isempty(obj.expr)&&ischar(obj.expr)
                currentInstrStartIndex=1;
                obj.out={};
                obj.SimplOpenBrackCount=0;
                obj.ArrOpenBrackCount=0;
                for exprIndex=1:length(obj.expr)
                    switch obj.expr(exprIndex)
                    case '('
                        obj.SimplOpenBrackCount=obj.SimplOpenBrackCount+1;
                        if obj.SimplOpenBrackCount==1
                            if(exprIndex-1)-currentInstrStartIndex>=0
                                obj.out{end+1}=obj.expr(currentInstrStartIndex:exprIndex-1);
                            end
                            obj.out{end+1}=obj.expr(exprIndex);
                            currentInstrStartIndex=exprIndex+1;
                        end
                    case ')'
                        obj.SimplOpenBrackCount=obj.SimplOpenBrackCount-1;
                        if obj.SimplOpenBrackCount==0

                            if(exprIndex-1)-currentInstrStartIndex>=0
                                obj.out{end+1}=obj.expr(currentInstrStartIndex:exprIndex-1);
                            end
                            obj.out{end+1}=obj.expr(exprIndex);
                            currentInstrStartIndex=exprIndex+1;
                        end
                    case '['
                        if obj.SimplOpenBrackCount==0
                            obj.out{end+1}=obj.expr(exprIndex);
                            currentInstrStartIndex=exprIndex+1;
                        elseif obj.SimplOpenBrackCount>=1
                            obj.ArrOpenBrackCount=1;
                        else
                            assert(false,['Issue parsing rung',obj.expr]);
                        end
                    case ']'
                        if obj.SimplOpenBrackCount==0
                            obj.out{end+1}=obj.expr(exprIndex);
                            currentInstrStartIndex=exprIndex+1;
                        elseif obj.SimplOpenBrackCount>=1
                            assert(obj.ArrOpenBrackCount==1,'Array index closing bracket not found');
                            obj.ArrOpenBrackCount=0;
                        else
                            assert(false,['Issue parsing rung',obj.expr]);

                        end
                    case ','
                        if obj.ArrOpenBrackCount==0
                            if(exprIndex-1)-currentInstrStartIndex>=0
                                obj.out{end+1}=obj.expr(currentInstrStartIndex:exprIndex-1);
                            end
                            obj.out{end+1}=obj.expr(exprIndex);
                            currentInstrStartIndex=exprIndex+1;
                        end
                    case '"'
                    otherwise

                    end
                end
            end
        end
    end
end


