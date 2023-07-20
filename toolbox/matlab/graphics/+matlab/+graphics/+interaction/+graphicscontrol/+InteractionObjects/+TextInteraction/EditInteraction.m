classdef EditInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase







    properties
Canvas
Figure
    end

    properties(Access=private)
OldString
EditingChangedListener
    end

    methods
        function this=EditInteraction(hText)
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Click;
            this.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.IBeam;

            this.Object=hText;

            this.Canvas=ancestor(this.Object,...
            'matlab.graphics.primitive.canvas.HTMLCanvas',...
            'node');
            this.Figure=ancestor(this.Object,'figure','node');
            this.register();
        end

        function register(this)
            this.Canvas.InteractionsManager.registerInteraction(this.Object,this);
        end

        function unregister(this)
            this.Canvas.InteractionsManager.unregisterInteraction(this);
        end

        function preresponse(this,~)
            this.OldString=this.Object.String;
        end

        function response(this,~)




            fig=ancestor(this.Object,'figure');
            inPlotEditMode=isactiveuimode(fig,'Standard.EditPlot');

            if(inPlotEditMode)
                return;
            end

            this.Object.Editing='on';
        end

        function postresponse(this,~)
            this.EditingChangedListener=event.proplistener(this.Object,...
            findprop(this.Object,'Editing'),'PostSet',...
            @(~,~)this.doPostResponse());
        end

        function doPostResponse(this)






            if~this.stringCompare(this.OldString,this.Object.String)

                this.addToUndoStack(this.OldString,this.Object.String);

                matlab.graphics.interaction.generateLiveCode(this.Object,...
                matlab.internal.editor.figure.ActionID.TEXT_EDITED);
            end
        end

        function addToUndoStack(this,oldString,newString)


            this.EditingChangedListener=[];


            if(isempty(this.Figure))
                this.Figure=ancestor(this.Object,'figure');
            end


            textProxy=plotedit({'getProxyValueFromHandle',this.Object});


            cmd.Name='Text Editing';


            cmd.Function=@changeString;
            cmd.Varargin={this,this.Figure,textProxy,newString};


            cmd.InverseFunction=@changeString;
            cmd.InverseVarargin={this,this.Figure,textProxy,oldString};



            uiundo(this.Figure,'function',cmd);

        end

        function changeString(~,fig,textProxy,string)

            textObj=plotedit({'getHandleFromProxyValue',fig,textProxy});

            if(~ishghandle(textObj))
                return;
            end

            textObj.String=string;
        end

        function tf=stringCompare(~,str1,str2)





            if(~iscell(str1))
                str1={str1};
            end

            if(~iscell(str2))
                str2={str2};
            end



            if(~isequal(size(str1),size(str2)))
                tf=false;
                return;
            end



            tf_all=strcmp(str1,str2);
            tf=all(tf_all);

        end

        function delete(this)
            this.unregister();
        end

    end
end

