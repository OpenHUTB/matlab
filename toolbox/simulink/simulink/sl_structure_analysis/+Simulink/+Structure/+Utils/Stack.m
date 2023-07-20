classdef Stack<handle

    properties(SetAccess=private,...
        GetAccess=private,...
        Hidden=true)
elements
    end

    methods
        function s=Stack()
            s.elements={};
        end
        function push(s,elt)
            s.elements{end+1}=elt;
        end
        function elt=pop(s)
            if length(s.elements)>0
                elt=s.elements{end};
                s.elements(end)=[];
            else
                me=MException('STACK:CannotPopEmptyStack',...
                'Cannot pop an empty stack!');
                throw(me);
            end
        end
        function elt=top(s)
            elt=s.elements{end};
        end
        function sz=size(s)
            sz=length(s.elements);
        end
        function ie=isempty(s)
            ie=isempty(s.elements);
        end
        function elts=getElements(s)
            elts=s.elements;
        end
        function delete(s)
            elements=[];
        end
    end

end
