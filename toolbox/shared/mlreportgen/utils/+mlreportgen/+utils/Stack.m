classdef Stack<handle













    properties


        Buffer cell={}

    end

    methods

        function push(stack,obj)


            stack.Buffer(end+1)={obj};
        end

        function obj=pop(stack)



            if~isempty(stack.Buffer)
                obj=stack.Buffer{end};
                stack.Buffer(end)=[];
            end
        end

        function obj=top(stack)





            obj=stack.Buffer{end};
        end

        function tf=isempty(stack)
            tf=isempty(stack.Buffer);
        end

        function tf=contains(stack,obj)

            tf=~isempty(find(stack.Buffer=={obj},1));
        end

        function clear(stack)
            stack.Buffer={};
        end

    end
end

