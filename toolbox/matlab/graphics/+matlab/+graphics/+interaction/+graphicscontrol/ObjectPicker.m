classdef ObjectPicker<handle



    properties
    end

    methods
        function this=ObjectPicker()
        end
    end

    methods(Static)
        function response=getHierarchy(canvas,x,y)
            hierarchy={};


            if feature('NoFigureWindows')
                return;
            end

            hitTestResult=canvas.hittest(x,y);
            currentNode=hitTestResult;
            while(~isempty(currentNode)&&...
                ~isa(currentNode,'matlab.graphics.primitive.canvas.JavaCanvas')&&...
                ~isa(currentNode,'matlab.graphics.primitive.canvas.HTMLCanvas'))
                hierarchy{end+1}=currentNode.getObjectID();
                currentNode=currentNode.NodeParent;
            end

            response.data=hierarchy;
        end

        function response=getHitInfo(canvas,x,y)
            hitID={};


            if(~feature('HasDisplay'))
                return;
            end
            hitTestResult=canvas.hittest(x,y);
            node=hitTestResult;

            if~isempty(node)&&...
                ~isa(node,'matlab.graphics.primitive.canvas.JavaCanvas')&&...
                ~isa(node,'matlab.graphics.primitive.canvas.HTMLCanvas')
                hitID=node.getObjectID();
            end

            response.data.objectID=hitID;
        end

        function responseJSON=processMessage(canvas,message)
            responseJSON=struct;
            try
                messageJSON=jsondecode(message);
                response=struct;
                if isfield(messageJSON,'name')&&ischar(messageJSON.name)
                    switch messageJSON.name
                    case 'getHierarchy'
                        response=matlab.graphics.interaction.graphicscontrol.ObjectPicker.getHierarchy(canvas,messageJSON.x,messageJSON.y);
                    case 'getHitInfo'
                        response=matlab.graphics.interaction.graphicscontrol.ObjectPicker.getHitInfo(canvas,messageJSON.x,messageJSON.y);
                    end
                end
                retMessage.cmd='response';
                retMessage.data=response.data;
                retMessage.requestToken=messageJSON.requestToken;
                responseJSON=jsonencode(retMessage);
            catch err

            end
        end
    end
end
