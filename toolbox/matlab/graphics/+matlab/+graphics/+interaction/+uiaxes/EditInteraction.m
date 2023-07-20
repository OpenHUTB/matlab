classdef EditInteraction<handle






    properties
Text
Figure
HitListener
MotionListener
EditingChangedListener
    end

    properties(Hidden)
HitObjectCache
MousePointerCache
OldString
    end

    methods
        function this=EditInteraction(t)
            this.Text=t;
            this.HitListener=event.listener(t,'Hit',@(t,~)this.textEditingFcn(t));

            fig=ancestor(t,'figure');
            this.HitObjectCache=fig;
            this.Figure=fig;

            this.MotionListener=event.listener(fig,'WindowMouseMotion',@(~,e)this.figureMotionFcn(e));

            this.EditingChangedListener=event.proplistener(t,...
            findprop(t,'Editing'),'PostSet',...
            @(~,~)this.editingChangedCallback());

            this.EditingChangedListener.Enabled=false;
        end

        function textEditingFcn(this,t)




            inPlotEditMode=isactiveuimode(this.Figure,'Standard.EditPlot');

            if(inPlotEditMode)
                return;
            end

            this.OldString=t.String;

            t.Editing='on';



            this.EditingChangedListener.Enabled=true;
        end

        function editingChangedCallback(this)

            if(isequal(this.Text.Editing_I,'on'))
                return;
            end




            this.EditingChangedListener.Enabled=false;

            localAddToUndoStack(this.Figure,this.Text,...
            this.OldString,this.Text.String);

        end

        function figureMotionFcn(this,e)




            inPlotEditMode=isactiveuimode(this.Figure,'Standard.EditPlot');

            if(inPlotEditMode)
                return;
            end

            if((this.HitObjectCache~=this.Text)&&...
                (e.HitObject==this.Text))






                if(strcmp(this.Figure.Pointer,'ibeam'))
                    return;
                end

                this.MousePointerCache=this.Figure.Pointer;
                this.Figure.Pointer='ibeam';
            end

            if((this.HitObjectCache==this.Text)&&...
                (e.HitObject~=this.Text))



                this.Figure.Pointer=this.MousePointerCache;
            end

            this.HitObjectCache=e.HitObject;

        end

    end
end

function localAddToUndoStack(fig,t,oldString,newString)


    if(isempty(fig))
        fig=ancestor(t,'figure');
    end


    textProxy=plotedit({'getProxyValueFromHandle',t});


    cmd.Name='Text Editing';


    cmd.Function=@localChangeString;
    cmd.Varargin={fig,textProxy,newString};


    cmd.InverseFunction=@localChangeString;
    cmd.InverseVarargin={fig,textProxy,oldString};



    uiundo(fig,'function',cmd);

end


function localChangeString(fig,textProxy,string)

    textObj=plotedit({'getHandleFromProxyValue',fig,textProxy});

    if(~ishghandle(textObj))
        return;
    end

    textObj.String=string;
end



