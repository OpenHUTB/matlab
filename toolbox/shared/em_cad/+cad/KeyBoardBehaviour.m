classdef KeyBoardBehaviour<handle




    properties
        KB_KeyStack={}
KB_ParentFig
KB_Listeners
        KB_SelectMultiple=0;
        KB_Up=0;
        KB_Down=0;
        KB_Left=0;
        KB_Right=0;
    end
    methods
        function set.KB_SelectMultiple(self,val)
            self.KB_SelectMultiple=val;
        end
        function initializeKeyBoardBehaviour(self)
            self.KB_ParentFig=getFigure(self);
            KB_addListeners(self)
        end

        function KB_addListeners(self)
            self.KB_ParentFig.WindowKeyPressFcn=@(src,evt)self.notifyKeyFunc(src,evt);
            self.KB_ParentFig.WindowKeyReleaseFcn=@(src,evt)self.notifyKeyFunc(src,evt);
        end
        function notifyKeyFunc(self,src,evt)

            if any(strcmpi(evt.EventName,{'KeyPress','WindowKeyPress'}))
                if~isempty(evt.Character)
                    self.KB_KeyStack=[evt.Modifier,{evt.Key}];
                else
                    self.KB_KeyStack=evt.Modifier;
                end
                if any(strcmpi(self.KB_KeyStack,'control'))

                    self.KB_SelectMultiple=1;
                    self.notify('SelectMultiple')
                else
                    self.KB_SelectMultiple=0;
                end


            elseif any(strcmpi(evt.EventName,{'KeyRelease','WindowKeyRelease'}))

                if~isempty(evt.Character)
                    self.KB_KeyStack=[evt.Modifier,{evt.Key}];
                else
                    self.KB_KeyStack={evt.Key};
                end
                triggerKey=strjoin(self.KB_KeyStack,'+');
                if strcmpi(triggerKey,'control')

                    self.KB_SelectMultiple=0;
                elseif strcmpi(triggerKey,'uparrow')

                    self.KB_Up=0;
                elseif strcmpi(triggerKey,'leftarrow')

                    self.KB_Left=0;
                elseif strcmpi(triggerKey,'rightarrow')

                    self.KB_Right=0;

                    self.KB_Up=0;
                elseif strcmpi(triggerKey,'downarrow')

                    self.KB_Down=0;
                end
                triggerEventsForKey(self);

            end


        end

        function pushKeyStack(self,KeyVal)



            if~isempty(self.KB_KeyStack)
                self.KB_KeyStack{end+1}=KeyVal;
            else
                self.KB_KeyStack{1}=KeyVal;
            end
        end

        function triggerEventsForKey(self)
            if numel(self.KB_KeyStack)==1
                triggerKey=self.KB_KeyStack{1};
            else
                triggerKey=strjoin(self.KB_KeyStack,'+');
            end

            if(strcmpi(triggerKey,'control+a'))

                self.notify('SelectAll')
                selectAll(self);
            elseif(strcmpi(triggerKey,'control+c'))


                copy(self);
            elseif(strcmpi(triggerKey,'control+x'))


                cut(self);
            elseif(strcmpi(triggerKey,'control+v'))


                paste(self);
            elseif(strcmpi(triggerKey,'control+z'))

                self.notify('Undo')
            elseif(strcmpi(triggerKey,'control+y'))

                self.notify('Redo')
            elseif strcmpi(triggerKey,'delete')

                deleteObj(self);
            elseif strcmpi(triggerKey,'leftarrow')

                self.KB_Left=1;
                self.notify('Left')
                left(self);
            elseif strcmpi(triggerKey,'rightarrow')

                self.KB_Right=1;
                self.notify('Right')
                right(self);
            elseif strcmpi(triggerKey,'uparrow')

                self.KB_Up=1;
                self.notify('Up')
                up(self);
            elseif strcmpi(triggerKey,'downarrow')

                self.KB_Down=1;
                self.notify('Down')
                down(self);
            elseif strcmpi(triggerKey,'escape')


                escape(self);
            end

        end
        function selectAll(self)
        end
        function left(self)
        end
        function right(self)
        end
        function up(self)
        end
        function down(self)
        end
        function cut(self)
        end

        function copy(self)
        end
        function paste(self)
        end

        function deleteObj(self)
        end

        function escape(self)
        end
    end
    events
SelectMultiple
SelectAll
Copy
Cut
Paste
Undo
Redo
Delete
Left
Right
Up
Down
Escape
    end
end
